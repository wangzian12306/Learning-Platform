package com.learningplatform.service;

import com.learningplatform.dto.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.*;

@Service
public class CodeExecutionService {

    @Value("${piston.url:http://localhost:2000}")
    private String pistonUrl;

    private final RestTemplate restTemplate = new RestTemplate();

    // 前端传来的语言名 -> [Piston语言名, 文件名, Piston版本]
    // gcc 8.3.0 是系统级安装，使用 -B 标志指定工具路径
    private static final Map<String, String[]> LANG_MAP = Map.of(
        "c++",    new String[]{"c++",    "main.cpp", "8.3.0"},
        "c",      new String[]{"c",      "main.c",   "8.3.0"},
        "python", new String[]{"python", "main.py",  "3.7.3"}
    );

    public CodeRunResponse run(String language, String code, String stdin) {
        String[] cfg = LANG_MAP.getOrDefault(language.toLowerCase(), new String[]{"c++", "main.cpp", "8.3.0"});

        Map<String, Object> file = Map.of("name", cfg[1], "content", code);
        Map<String, Object> req = new HashMap<>();
        req.put("language", cfg[0]);
        req.put("version", cfg[2]);
        req.put("files", List.of(file));
        req.put("stdin", stdin != null ? stdin : "");

        @SuppressWarnings("unchecked")
        Map<String, Object> resp = restTemplate.postForObject(
            pistonUrl + "/api/v2/execute", req, Map.class);

        CodeRunResponse result = new CodeRunResponse();

        @SuppressWarnings("unchecked")
        Map<String, Object> compile = (Map<String, Object>) resp.get("compile");
        @SuppressWarnings("unchecked")
        Map<String, Object> run = (Map<String, Object>) resp.get("run");

        // 编译失败：compile.code != 0 且 stderr 非空
        if (compile != null) {
            Object code0 = compile.get("code");
            String compileStderr = (String) compile.get("stderr");
            if (code0 != null && (Integer) code0 != 0 && compileStderr != null && !compileStderr.isBlank()) {
                result.setCompileError(compileStderr);
                result.setStdout("");
                result.setStderr(compileStderr);
                result.setExitCode((Integer) code0);
                return result;
            }
        }

        result.setStdout(run != null ? (String) run.get("stdout") : "");
        result.setStderr(run != null ? (String) run.get("stderr") : "");
        result.setExitCode(run != null ? (Integer) run.get("code") : -1);
        return result;
    }

    public CodeSubmitResponse submit(String language, String code, List<TestCase> testCases) {
        CodeSubmitResponse response = new CodeSubmitResponse();
        List<TestCaseResult> results = new ArrayList<>();
        int passCount = 0;

        for (TestCase tc : testCases) {
            CodeRunResponse runResult = run(language, code, tc.getInput());

            // 编译错误：直接返回，无需继续跑剩余用例
            if (runResult.getCompileError() != null) {
                response.setStatus("COMPILE_ERROR");
                response.setErrorMessage(runResult.getCompileError());
                response.setPassCount(0);
                response.setTotalCount(testCases.size());
                response.setTestResults(results);
                return response;
            }

            TestCaseResult tcResult = new TestCaseResult();
            tcResult.setInput(tc.getInput());
            tcResult.setExpectedOutput(tc.getExpectedOutput().trim());
            String actual = runResult.getStdout() != null ? runResult.getStdout().trim() : "";
            tcResult.setActualOutput(actual);
            tcResult.setPassed(actual.equals(tc.getExpectedOutput().trim()));
            if (Boolean.TRUE.equals(tcResult.getPassed())) passCount++;
            results.add(tcResult);
        }

        response.setPassCount(passCount);
        response.setTotalCount(testCases.size());
        response.setTestResults(results);
        response.setStatus(passCount == testCases.size() ? "ACCEPTED" : "WRONG_ANSWER");
        return response;
    }
}
