@echo off
REM Installation script for Windows
REM This script sets up the Promptfoo test package in your project

setlocal enabledelayedexpansion

echo ================================
echo 🚀 Promptfoo LLM Test Package Installer
echo ================================

REM Check if we're in a project directory
if not exist "package.json" (
    if not exist "requirements.txt" (
        if not exist "Gemfile" (
            echo ⚠️  Warning: No package.json, requirements.txt, or Gemfile found.
            echo    Are you in your project root directory?
            set /p continue="Continue anyway? (y/N): "
            if /i not "!continue!"=="y" exit /b 1
        )
    )
)

REM Configuration
set PACKAGE_NAME=promptfoo-llm-tests
set SOURCE_PATH=%~dp0

echo 📁 Creating test directory...
mkdir "%PACKAGE_NAME%" 2>nul

echo 📋 Copying test files...
xcopy "%SOURCE_PATH%*" "%PACKAGE_NAME%\" /E /I /Y >nul

REM Navigate to test directory
cd "%PACKAGE_NAME%"

REM Remove installer script from copied files
del install.bat 2>nul
del install.sh 2>nul

echo 📦 Installing dependencies...
where npm >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ npm not found. Please install Node.js first.
    exit /b 1
)

npm install

echo ⚙️  Setting up environment...
if not exist ".env" (
    copy .env.example .env >nul
    echo 📝 Please edit .env file with your API keys
)

REM Go back to parent directory
cd ..

REM Create integration examples
echo 📄 Creating integration examples...

REM Python integration for Windows
echo #!/usr/bin/env python3 > "%PACKAGE_NAME%\python_integration.py"
echo """ >> "%PACKAGE_NAME%\python_integration.py"
echo Python integration example for Promptfoo LLM tests >> "%PACKAGE_NAME%\python_integration.py"
echo """ >> "%PACKAGE_NAME%\python_integration.py"
echo. >> "%PACKAGE_NAME%\python_integration.py"
echo import subprocess >> "%PACKAGE_NAME%\python_integration.py"
echo import os >> "%PACKAGE_NAME%\python_integration.py"
echo import sys >> "%PACKAGE_NAME%\python_integration.py"
echo from pathlib import Path >> "%PACKAGE_NAME%\python_integration.py"
echo. >> "%PACKAGE_NAME%\python_integration.py"
echo class LLMTester: >> "%PACKAGE_NAME%\python_integration.py"
echo     def __init__(self, config_file="promptfooconfig.yaml"): >> "%PACKAGE_NAME%\python_integration.py"
echo         self.config_file = config_file >> "%PACKAGE_NAME%\python_integration.py"
echo         self.test_dir = Path(__file__).parent >> "%PACKAGE_NAME%\python_integration.py"
echo. >> "%PACKAGE_NAME%\python_integration.py"
echo     def run_tests(self, config="basic"): >> "%PACKAGE_NAME%\python_integration.py"
echo         """Run LLM tests with specified configuration""" >> "%PACKAGE_NAME%\python_integration.py"
echo         config_map = { >> "%PACKAGE_NAME%\python_integration.py"
echo             "basic": "promptfooconfig.yaml", >> "%PACKAGE_NAME%\python_integration.py"
echo             "advanced": "advanced-config.yaml", >> "%PACKAGE_NAME%\python_integration.py"
echo             "quick": "quick-test.yaml" >> "%PACKAGE_NAME%\python_integration.py"
echo         } >> "%PACKAGE_NAME%\python_integration.py"
echo. >> "%PACKAGE_NAME%\python_integration.py"
echo         config_file = config_map.get(config, config) >> "%PACKAGE_NAME%\python_integration.py"
echo. >> "%PACKAGE_NAME%\python_integration.py"
echo         try: >> "%PACKAGE_NAME%\python_integration.py"
echo             result = subprocess.run([ >> "%PACKAGE_NAME%\python_integration.py"
echo                 "npm", "run", f"test -- -c {config_file}" >> "%PACKAGE_NAME%\python_integration.py"
echo             ], cwd=self.test_dir, check=True) >> "%PACKAGE_NAME%\python_integration.py"
echo             return True >> "%PACKAGE_NAME%\python_integration.py"
echo         except subprocess.CalledProcessError: >> "%PACKAGE_NAME%\python_integration.py"
echo             return False >> "%PACKAGE_NAME%\python_integration.py"

REM Windows batch integration
echo @echo off > "%PACKAGE_NAME%\run_tests.bat"
echo REM Windows batch script to run LLM tests >> "%PACKAGE_NAME%\run_tests.bat"
echo. >> "%PACKAGE_NAME%\run_tests.bat"
echo set CONFIG=%%1 >> "%PACKAGE_NAME%\run_tests.bat"
echo if "%%CONFIG%%"=="" set CONFIG=basic >> "%PACKAGE_NAME%\run_tests.bat"
echo. >> "%PACKAGE_NAME%\run_tests.bat"
echo echo 🧪 Running %%CONFIG%% LLM tests... >> "%PACKAGE_NAME%\run_tests.bat"
echo. >> "%PACKAGE_NAME%\run_tests.bat"
echo if "%%CONFIG%%"=="basic" ( >> "%PACKAGE_NAME%\run_tests.bat"
echo     npm run test:basic >> "%PACKAGE_NAME%\run_tests.bat"
echo ) else if "%%CONFIG%%"=="advanced" ( >> "%PACKAGE_NAME%\run_tests.bat"
echo     npm run test:advanced >> "%PACKAGE_NAME%\run_tests.bat"
echo ) else if "%%CONFIG%%"=="quick" ( >> "%PACKAGE_NAME%\run_tests.bat"
echo     npm run test -- -c quick-test.yaml >> "%PACKAGE_NAME%\run_tests.bat"
echo ) else ( >> "%PACKAGE_NAME%\run_tests.bat"
echo     npm run test -- -c %%CONFIG%% >> "%PACKAGE_NAME%\run_tests.bat"
echo ) >> "%PACKAGE_NAME%\run_tests.bat"
echo. >> "%PACKAGE_NAME%\run_tests.bat"
echo if %%errorlevel%% equ 0 ( >> "%PACKAGE_NAME%\run_tests.bat"
echo     echo ✅ LLM tests passed! >> "%PACKAGE_NAME%\run_tests.bat"
echo ) else ( >> "%PACKAGE_NAME%\run_tests.bat"
echo     echo ❌ LLM tests failed! >> "%PACKAGE_NAME%\run_tests.bat"
echo     exit /b 1 >> "%PACKAGE_NAME%\run_tests.bat"
echo ) >> "%PACKAGE_NAME%\run_tests.bat"

REM Check and update package.json
if exist "package.json" (
    echo 📝 Please manually add these scripts to your package.json:
    echo.
    echo "scripts": {
    echo   "test:llm": "cd %PACKAGE_NAME% && npm run test:basic",
    echo   "test:llm:advanced": "cd %PACKAGE_NAME% && npm run test:advanced",
    echo   "test:llm:quick": "cd %PACKAGE_NAME% && npm run test -- -c quick-test.yaml",
    echo   "view:llm": "cd %PACKAGE_NAME% && npm run view",
    echo   "setup:llm": "cd %PACKAGE_NAME% && npm install"
    echo }
    echo.
)

echo ✅ Installation complete!
echo.
echo 📋 Next steps:
echo 1. Edit %PACKAGE_NAME%\.env with your API keys
echo 2. Run a quick test: cd %PACKAGE_NAME% && npm run test -- -c quick-test.yaml
echo 3. Run full tests from project root (after adding scripts to package.json)
echo.
echo 📚 Available commands (from %PACKAGE_NAME% directory):
echo   npm run test:basic     - Run basic LLM tests
echo   npm run test:advanced  - Run advanced LLM tests  
echo   npm run test -- -c quick-test.yaml - Run quick tests
echo   npm run view           - View test results in browser
echo.
echo 📖 Documentation:
echo   See %PACKAGE_NAME%\README.md for detailed usage
echo   See %PACKAGE_NAME%\INTEGRATION_GUIDE.md for integration examples
echo.
echo 💡 Don't forget to set your OPENAI_API_KEY in %PACKAGE_NAME%\.env

pause