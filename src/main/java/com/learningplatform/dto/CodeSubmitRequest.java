package com.learningplatform.dto;

import java.util.List;

public class CodeSubmitRequest {
    private String language;
    private String code;
    private List<TestCase> testCases;

    public String getLanguage() { return language; }
    public void setLanguage(String language) { this.language = language; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public List<TestCase> getTestCases() { return testCases; }
    public void setTestCases(List<TestCase> testCases) { this.testCases = testCases; }
}
