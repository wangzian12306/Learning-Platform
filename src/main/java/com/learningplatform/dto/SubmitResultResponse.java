package com.learningplatform.dto;

import lombok.Data;

import java.util.List;

@Data
public class SubmitResultResponse {
    private boolean correct;
    private String correctAnswer;
    private String analysis;
    private Double passRate;
    private Long exerciseId;
    private List<BlankResult> blankResults;

    @Data
    public static class BlankResult {
        private int index;
        private boolean correct;
        private String userAnswer;
        private String correctAnswer;

        public BlankResult(int index, boolean correct, String userAnswer, String correctAnswer) {
            this.index = index;
            this.correct = correct;
            this.userAnswer = userAnswer;
            this.correctAnswer = correctAnswer;
        }
    }
}