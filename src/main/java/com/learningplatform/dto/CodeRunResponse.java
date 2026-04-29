package com.learningplatform.dto;

public class CodeRunResponse {
    private String stdout;
    private String stderr;
    private Integer exitCode;
    private String compileError;

    public String getStdout() { return stdout; }
    public void setStdout(String stdout) { this.stdout = stdout; }
    public String getStderr() { return stderr; }
    public void setStderr(String stderr) { this.stderr = stderr; }
    public Integer getExitCode() { return exitCode; }
    public void setExitCode(Integer exitCode) { this.exitCode = exitCode; }
    public String getCompileError() { return compileError; }
    public void setCompileError(String compileError) { this.compileError = compileError; }
}
