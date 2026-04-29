package com.learningplatform.controller;

import com.learningplatform.common.Result;
import com.learningplatform.dto.*;
import com.learningplatform.service.CodeExecutionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/code")
public class CodeController {

    @Autowired
    private CodeExecutionService codeExecutionService;

    @PostMapping("/run")
    public Result<CodeRunResponse> run(@RequestBody CodeRunRequest request) {
        return Result.success(
            codeExecutionService.run(request.getLanguage(), request.getCode(), request.getStdin())
        );
    }

    @PostMapping("/submit")
    public Result<CodeSubmitResponse> submit(@RequestBody CodeSubmitRequest request) {
        return Result.success(
            codeExecutionService.submit(request.getLanguage(), request.getCode(), request.getTestCases())
        );
    }
}
