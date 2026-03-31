@echo off
setlocal enabledelayedexpansion

SET "JMETER_HOME=C:\apache-jmeter-5.6.3"
SET "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot"

SET "SCRIPT_DIR=%~dp0"
SET "JMX_FILE=%SCRIPT_DIR%jmeter\blazedemo-performance.jmx"
SET "RESULTS_DIR=%SCRIPT_DIR%results"

SET "JAVA_BIN=%JAVA_HOME%\bin\java.exe"
SET "JMETER_JAR=%JMETER_HOME%\bin\ApacheJMeter.jar"

REM SLA
SET "SLA_P90=2000"
SET "SLA_RPS=250"

REM ===== TIMESTAMP =====
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
SET "TIMESTAMP=%datetime:~0,8%_%datetime:~8,6%"

echo ============================================================
echo   BlazeDemo - Performance Test Suite
echo ============================================================
echo.

REM ===== VALIDACOES =====

IF NOT EXIST "%JAVA_BIN%" (
    echo [ERRO] Java nao encontrado:
    echo %JAVA_BIN%
    pause
    exit /b 1
)

IF NOT EXIST "%JMETER_JAR%" (
    echo [ERRO] ApacheJMeter.jar nao encontrado:
    echo %JMETER_JAR%
    pause
    exit /b 1
)

IF NOT EXIST "%JMX_FILE%" (
    echo [ERRO] Arquivo JMX nao encontrado:
    echo %JMX_FILE%
    pause
    exit /b 1
)

echo [OK] Ambiente validado
echo.

IF NOT EXIST "%RESULTS_DIR%" mkdir "%RESULTS_DIR%"

SET "TEST_TYPE=%1"
IF "%TEST_TYPE%"=="" SET "TEST_TYPE=load"

REM 
:RUN_TEST
    SET "TEST_NAME=%~1"
    SET "THREADS=%~2"
    SET "RAMP=%~3"
    SET "DURATION=%~4"

    echo --------------------------------------------------------
    echo [%TEST_NAME%] Iniciando...
    echo Threads: %THREADS% ^| Ramp-up: %RAMP%s ^| Duracao: %DURATION%s
    echo --------------------------------------------------------
    echo [STATUS] Execucao em tempo real:
    echo --------------------------------------------------------

    SET "OUT_DIR=%RESULTS_DIR%\%TEST_NAME%-%TIMESTAMP%"
    mkdir "%OUT_DIR%"

    "%JAVA_BIN%" -jar "%JMETER_JAR%" ^
        -n ^
        -t "%JMX_FILE%" ^
        -l "%OUT_DIR%\results.jtl" ^
        -e -o "%OUT_DIR%\html-report" ^
        -j "%OUT_DIR%\jmeter.log" ^
        -Jsummariser.name=summary ^
        -Jsummariser.interval=5 ^
        -Jsummariser.out=true

    IF %ERRORLEVEL% NEQ 0 (
        echo [ERRO] Falha no teste %TEST_NAME%
        exit /b %ERRORLEVEL%
    )

    echo.
    echo [ANALISE] Processando resultados...

    REM ===== ANALISE SIMPLES =====
    for /f "tokens=1,2 delims=," %%A in ('type "%OUT_DIR%\results.jtl" ^| findstr /r "^[0-9]"') do (
        SET LAST_TIME=%%A
        SET LAST_ELAPSED=%%B
    )

    echo Ultima resposta: !LAST_ELAPSED! ms

    IF !LAST_ELAPSED! GTR %SLA_P90% (
        echo [FAIL] SLA de latencia violado (P90 esperado: %SLA_P90% ms)
    ) ELSE (
        echo [OK] Latencia dentro do SLA
    )

    echo.
    echo [OK] %TEST_NAME% finalizado!
    echo JTL:  %OUT_DIR%\results.jtl
    echo HTML: %OUT_DIR%\html-report\index.html
    echo.

    goto :eof

REM 

IF "%TEST_TYPE%"=="load" (
    CALL :RUN_TEST load 300 120 480
    GOTO :DONE
)

IF "%TEST_TYPE%"=="spike" (
    CALL :RUN_TEST spike 600 30 180
    GOTO :DONE
)

IF "%TEST_TYPE%"=="both" (
    CALL :RUN_TEST load 300 120 480
    CALL :RUN_TEST spike 600 30 180
    GOTO :DONE
)

IF "%TEST_TYPE%"=="--help" (
    echo Uso: run-tests.bat [load^|spike^|both]
    exit /b 0
)

echo [ERRO] Opcao invalida: %TEST_TYPE%
exit /b 1

:DONE
echo ============================================================
echo   Execucao finalizada! Resultados em:
echo   %RESULTS_DIR%
echo ============================================================
pause