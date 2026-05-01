package com.learningplatform.dto;

import java.util.List;

public class CodeSubmitResponse {
    private String status;
    private Integer passCount;
    private Integer totalCount;
    private List<TestCaseResult> testResults;
    private String errorMessage;

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Integer getPassCount() { return passCount; }
    public void setPassCount(Integer passCount) { this.passCount = passCount; }
    public Integer getTotalCount() { return totalCount; }
    public void setTotalCount(Integer totalCount) { this.totalCount = totalCount; }
    public List<TestCaseResult> getTestResults() { return testResults; }
    public void setTestResults(List<TestCaseResult> testResults) { this.testResults = testResults; }
    public String getErrorMessage() { return errorMessage; }
    public void setErrorMessage(String errorMessage) { this.errorMessage = errorMessage; }
}
