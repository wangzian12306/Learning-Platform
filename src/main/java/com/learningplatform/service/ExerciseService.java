package com.learningplatform.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.learningplatform.common.BusinessException;
import com.learningplatform.dto.*;
import com.learningplatform.entity.Exercise;
import com.learningplatform.entity.KnowledgePoint;
import com.learningplatform.entity.UserExerciseRecord;
import com.learningplatform.repository.ExerciseRepository;
import com.learningplatform.repository.KnowledgePointRepository;
import com.learningplatform.repository.UserExerciseRecordRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Slf4j
@Transactional(value = "transactionManager")
public class ExerciseService {

    @Autowired
    private ExerciseRepository exerciseRepository;

    @Autowired
    private UserExerciseRecordRepository userExerciseRecordRepository;

    @Autowired
    private KnowledgePointRepository knowledgePointRepository;

    @Autowired
    private CodeExecutionService codeExecutionService;

    /**
     * 获取习题列表（带分页和筛选）
     */
    public ExerciseListResponse getExerciseList(ExerciseQueryRequest request) {
        QueryWrapper<Exercise> queryWrapper = new QueryWrapper<>();

        // 构建查询条件
        if (request.getKnowledgeId() != null) {
            queryWrapper.eq("knowledge_point_id", request.getKnowledgeId());
        }
        if (StringUtils.hasText(request.getDifficulty())) {
            queryWrapper.eq("difficulty", request.getDifficulty());
        }
        if (StringUtils.hasText(request.getType())) {
            queryWrapper.eq("type", request.getType());
        }
        if (StringUtils.hasText(request.getKeyword())) {
            queryWrapper.like("title", request.getKeyword())
                    .or()
                    .like("description", request.getKeyword());
        }
        queryWrapper.orderByAsc("sort_order");

        // 分页查询
        Page<Exercise> page = new Page<>(request.getPage(), request.getPageSize());
        Page<Exercise> exercisePage = exerciseRepository.selectPage(page, queryWrapper);

        // 构建响应
        ExerciseListResponse response = new ExerciseListResponse();
        response.setPage(request.getPage());
        response.setPageSize(request.getPageSize());
        response.setTotal(exercisePage.getTotal());

        List<ExerciseResponse> records = exercisePage.getRecords().stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
        response.setRecords(records);

        return response;
    }

    /**
     * 获取习题详情
     */
    public ExerciseDetailResponse getExerciseDetail(Long exerciseId) {
        Exercise exercise = exerciseRepository.selectById(exerciseId);
        if (exercise == null) {
            throw new BusinessException("习题不存在");
        }

        ExerciseDetailResponse response = convertToDetailResponse(exercise);

        // 获取知识点名称
        KnowledgePoint knowledgePoint = knowledgePointRepository.selectById(exercise.getKnowledgePointId());
        if (knowledgePoint != null) {
            response.setKnowledgeName(knowledgePoint.getName());
        }

        return response;
    }

    /**
     * 创建习题
     */
    public Long createExercise(CreateExerciseRequest request) {
        // 验证知识点是否存在
        KnowledgePoint knowledgePoint = knowledgePointRepository.selectById(request.getKnowledgePointId());
        if (knowledgePoint == null) {
            throw new BusinessException("知识点不存在");
        }

        // 创建习题
        Exercise exercise = new Exercise();
        BeanUtils.copyProperties(request, exercise);

        // 设置默认值
        exercise.setPassRate(0.0);
        exercise.setTotalAttempts(0);
        exercise.setCorrectAttempts(0);

        exerciseRepository.insert(exercise);

        return exercise.getId();
    }

    /**
     * 更新习题
     */
    public Boolean updateExercise(UpdateExerciseRequest request) {
        Exercise existingExercise = exerciseRepository.selectById(request.getId());
        if (existingExercise == null) {
            throw new BusinessException("习题不存在");
        }

        // 更新字段
        Exercise exercise = new Exercise();
        BeanUtils.copyProperties(request, exercise);

        int result = exerciseRepository.updateById(exercise);
        return result > 0;
    }

    /**
     * 删除习题（逻辑删除）
     */
    public Boolean deleteExercise(Long exerciseId) {
        Exercise exercise = exerciseRepository.selectById(exerciseId);
        if (exercise == null) {
            throw new BusinessException("习题不存在");
        }

        int result = exerciseRepository.deleteById(exerciseId);
        return result > 0;
    }

    /**
     * 提交答案
     */
    public SubmitResultResponse submitAnswer(SubmitAnswerRequest request, Long userId) {
        Exercise exercise = exerciseRepository.selectById(request.getExerciseId());
        if (exercise == null) {
            throw new BusinessException("习题不存在");
        }

        boolean isCorrect = false;
        String correctAnswer = exercise.getAnswer();
        String analysis = exercise.getAnalysis();
        List<SubmitResultResponse.BlankResult> blankResults = null;

        switch (exercise.getType()) {
            case "SINGLE_CHOICE":
            case "MULTIPLE_CHOICE":
                isCorrect = correctAnswer.equalsIgnoreCase(request.getUserAnswer());
                break;
            case "FILL_BLANK":
                blankResults = checkFillBlankAnswers(correctAnswer, request.getUserAnswer(), exercise.getDescription(), exercise.getTitle());
                isCorrect = blankResults != null && blankResults.stream().allMatch(SubmitResultResponse.BlankResult::isCorrect);
                break;
            case "PROGRAMMING":
                isCorrect = runTestCases(request.getCode(), exercise.getTestCases());
                analysis = isCorrect ? "恭喜，所有测试用例都通过了！" : "部分测试用例未通过，请检查代码逻辑。";
                break;
            default:
                throw new BusinessException("不支持的题型");
        }

        // 更新习题统计
        updateExerciseStatistics(exercise, isCorrect);

        // 记录用户答题记录
        saveUserExerciseRecord(userId, exercise.getId(), request.getUserAnswer(), isCorrect);

        SubmitResultResponse response = new SubmitResultResponse();
        response.setCorrect(isCorrect);
        response.setCorrectAnswer(isCorrect ? null : correctAnswer);
        response.setAnalysis(analysis);
        response.setPassRate(exercise.getPassRate());
        response.setExerciseId(exercise.getId());
        response.setBlankResults(blankResults);

        return response;
    }

    /**
     * 获取错题列表
     */
    public ExerciseListResponse getWrongExercises(Long userId, ExerciseQueryRequest request) {
        // 查询用户的错题ID列表
        List<Long> wrongExerciseIds = userExerciseRecordRepository.findWrongExerciseIds(userId);

        if (wrongExerciseIds.isEmpty()) {
            ExerciseListResponse response = new ExerciseListResponse();
            response.setRecords(List.of());
            response.setTotal(0L);
            response.setPage(request.getPage());
            response.setPageSize(request.getPageSize());
            return response;
        }

        // 查询错题详情
        QueryWrapper<Exercise> queryWrapper = new QueryWrapper<>();
        queryWrapper.in("id", wrongExerciseIds);

        if (request.getKnowledgeId() != null) {
            queryWrapper.eq("knowledge_point_id", request.getKnowledgeId());
        }
        if (StringUtils.hasText(request.getDifficulty())) {
            queryWrapper.eq("difficulty", request.getDifficulty());
        }

        // 分页查询
        Page<Exercise> page = new Page<>(request.getPage(), request.getPageSize());
        Page<Exercise> exercisePage = exerciseRepository.selectPage(page, queryWrapper);

        ExerciseListResponse response = new ExerciseListResponse();
        response.setPage(request.getPage());
        response.setPageSize(request.getPageSize());
        response.setTotal(exercisePage.getTotal());

        List<ExerciseResponse> records = exercisePage.getRecords().stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
        response.setRecords(records);

        return response;
    }

    /**
     * 根据知识点获取习题
     */
    public List<ExerciseResponse> getExercisesByKnowledge(Long knowledgeId) {
        QueryWrapper<Exercise> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("knowledge_point_id", knowledgeId);
        queryWrapper.orderByAsc("sort_order");

        List<Exercise> exercises = exerciseRepository.selectList(queryWrapper);

        return exercises.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    /**
     * 运行测试用例（编程题）
     */
    private boolean runTestCases(String code, String testCasesJson) {
        if (!StringUtils.hasText(testCasesJson)) {
            return false;
        }

        try {
            ObjectMapper objectMapper = new ObjectMapper();
            List<TestCase> testCases = objectMapper.readValue(testCasesJson, new TypeReference<List<TestCase>>() {});
            CodeSubmitResponse response = codeExecutionService.submit("c++", code, testCases);
            return "ACCEPTED".equals(response.getStatus());
        } catch (Exception e) {
            log.error("运行测试用例失败", e);
            return false;
        }
    }

    /**
     * 更新习题统计信息
     */
    private void updateExerciseStatistics(Exercise exercise, boolean isCorrect) {
        int totalAttempts = exercise.getTotalAttempts() + 1;
        int correctAttempts = exercise.getCorrectAttempts() + (isCorrect ? 1 : 0);
        double passRate = (double) correctAttempts / totalAttempts * 100;

        exercise.setTotalAttempts(totalAttempts);
        exercise.setCorrectAttempts(correctAttempts);
        exercise.setPassRate(passRate);

        exerciseRepository.updateById(exercise);
    }

    /**
     * 保存用户答题记录
     */
    private void saveUserExerciseRecord(Long userId, Long exerciseId, String userAnswer, boolean isCorrect) {
        UserExerciseRecord record = new UserExerciseRecord();
        record.setUserId(userId);
        record.setExerciseId(exerciseId);
        record.setUserAnswer(userAnswer);
        record.setIsCorrect(isCorrect);

        userExerciseRecordRepository.insert(record);
    }

    /**
     * 转换Exercise为ExerciseResponse
     */
    private ExerciseResponse convertToResponse(Exercise exercise) {
        ExerciseResponse response = new ExerciseResponse();
        BeanUtils.copyProperties(exercise, response);

        // 获取知识点名称
        KnowledgePoint knowledgePoint = knowledgePointRepository.selectById(exercise.getKnowledgePointId());
        if (knowledgePoint != null) {
            response.setKnowledgeName(knowledgePoint.getName());
        }

        return response;
    }

    /**
     * 转换Exercise为ExerciseDetailResponse
     */
    private ExerciseDetailResponse convertToDetailResponse(Exercise exercise) {
        ExerciseDetailResponse response = new ExerciseDetailResponse();
        BeanUtils.copyProperties(exercise, response);
        return response;
    }

    private List<SubmitResultResponse.BlankResult> checkFillBlankAnswers(String correctAnswer, String userAnswer, String description, String title) {
        if (!StringUtils.hasText(correctAnswer) || !StringUtils.hasText(userAnswer)) {
            return null;
        }

        int blankCount = 0;
        if (StringUtils.hasText(description)) {
            java.util.regex.Matcher matcher = java.util.regex.Pattern.compile("_{2,}").matcher(description);
            while (matcher.find()) {
                blankCount++;
            }
        }
        if (blankCount == 0 && StringUtils.hasText(title)) {
            java.util.regex.Matcher matcher = java.util.regex.Pattern.compile("_{2,}").matcher(title);
            while (matcher.find()) {
                blankCount++;
            }
        }

        String[] correctParts = parseAnswerParts(correctAnswer, blankCount);
        String[] userParts = parseAnswerParts(userAnswer, blankCount);

        int maxLen = Math.max(correctParts.length, userParts.length);
        List<SubmitResultResponse.BlankResult> results = new ArrayList<>();

        for (int i = 0; i < maxLen; i++) {
            String correct = i < correctParts.length ? correctParts[i].trim() : "";
            String user = i < userParts.length ? userParts[i].trim() : "";
            boolean match = correct.equalsIgnoreCase(user);
            results.add(new SubmitResultResponse.BlankResult(i + 1, match, user, correct));
        }

        return results;
    }

    private String[] parseAnswerParts(String answer, int blankCount) {
        if (answer.contains("|")) {
            return answer.split("\\|");
        }
        if (blankCount > 1 && answer.contains(",")) {
            return answer.split(",");
        }
        return new String[]{answer};
    }
}
