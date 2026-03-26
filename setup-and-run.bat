@echo off
setlocal enabledelayedexpansion
REM Setup and Run script for Spring PetClinic REST Application
REM Usage: setup-and-run.bat

echo ============================================
echo   Spring PetClinic REST - Setup ^& Run
echo ============================================

REM Check Java is installed
echo.
echo [1/3] Checking prerequisites...
java -version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: Java is not installed or not in PATH.
    echo This project requires Java 17+.
    echo Download from: https://adoptium.net/
    exit /b 1
)
for /f "tokens=3" %%a in ('java -version 2^>^&1 ^| findstr /i "version"') do (
    echo   Java version: %%a
)

REM Auto-detect JAVA_HOME if not set
if "%JAVA_HOME%"=="" (
    echo   JAVA_HOME is not set. Auto-detecting...
    for /d %%d in ("C:\Program Files\Java\jdk-*") do set "JAVA_HOME=%%d"
    if "!JAVA_HOME!"=="" (
        for /d %%d in ("C:\Program Files\Eclipse Adoptium\jdk-*") do set "JAVA_HOME=%%d"
    )
    if "!JAVA_HOME!"=="" (
        for /d %%d in ("C:\Program Files\Microsoft\jdk-*") do set "JAVA_HOME=%%d"
    )
    if "!JAVA_HOME!"=="" (
        echo ERROR: Could not auto-detect JAVA_HOME.
        echo Please set JAVA_HOME manually, e.g.:
        echo   set JAVA_HOME=C:\Program Files\Java\jdk-24
        exit /b 1
    )
    echo   JAVA_HOME set to: !JAVA_HOME!
    setx JAVA_HOME "!JAVA_HOME!" >nul 2>&1
    if !ERRORLEVEL! equ 0 (
        echo   JAVA_HOME saved for future sessions.
    )
)

REM Build the project
echo.
echo [2/3] Building the application (skipping tests for faster startup)...
call mvnw.cmd clean install -DskipTests
if %ERRORLEVEL% neq 0 (
    echo ERROR: Build failed. Check the output above for details.
    exit /b 1
)

REM Run the application
echo.
echo [3/3] Starting Spring PetClinic REST application...
echo.
echo   Application URL : http://localhost:9966/petclinic/
echo   Swagger UI      : http://localhost:9966/petclinic/swagger-ui.html
echo   Health Check    : http://localhost:9966/petclinic/actuator/health
echo.
echo   Press Ctrl+C to stop the application.
echo ============================================
echo.

call mvnw.cmd spring-boot:run
