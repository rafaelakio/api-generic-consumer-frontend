@echo off
setlocal

echo Starting integrated test environment...
echo ========================================

cd /d "%~dp0"

echo Checking prerequisites...

set PREREQ_ERRORS=0

echo Checking Docker...
docker --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker not found. Please install Docker Desktop.
    set /a PREREQ_ERRORS+=1
) else (
    echo SUCCESS: Docker found
)

echo Checking Docker Compose...
docker-compose --version >nul 2>&1
if errorlevel 1 (
    docker compose version >nul 2>&1
    if errorlevel 1 (
        echo ERROR: Docker Compose not found. Please install Docker Compose.
        set /a PREREQ_ERRORS+=1
    ) else (
        echo SUCCESS: Docker Compose found
    )
) else (
    echo SUCCESS: Docker Compose found
)

echo Checking Node.js...
node --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Node.js not found. Please install Node.js 20+.
    set /a PREREQ_ERRORS+=1
) else (
    for /f "tokens=*" %%i in ('node --version') do echo SUCCESS: Node.js found: %%i
)

echo Checking Java...
java -version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Java not found. Please install Java 21+.
    set /a PREREQ_ERRORS+=1
) else (
    for /f "tokens=3" %%i in ('java -version 2^>^&1 ^| findstr "version"') do echo SUCCESS: Java found: %%i
)

echo Checking project structure...
if not exist "..\api-generic-consumer-backend" (
    echo ERROR: api-generic-consumer-backend directory not found.
    set /a PREREQ_ERRORS+=1
) else (
    echo SUCCESS: Backend directory found
)

if not exist "package.json" (
    echo ERROR: Frontend package.json not found.
    set /a PREREQ_ERRORS+=1
) else (
    echo SUCCESS: Frontend package.json found
)

if not exist "..\api-generic-consumer-backend\Dockerfile" (
    echo ERROR: Backend Dockerfile not found.
    set /a PREREQ_ERRORS+=1
) else (
    echo SUCCESS: Backend Dockerfile found
)

echo Checking if Docker is running...
docker info >nul 2>&1
set DOCKER_EC=%errorlevel%
if "%DOCKER_EC%"=="0" goto docker_ok
echo.
echo ============================================
echo ERROR: Docker Desktop is not running or not ready! (exit code: %DOCKER_EC%)
echo ============================================
echo.
echo Please follow these steps:
echo   1. Open Docker Desktop and wait for the whale icon to be stable
echo   2. Run this script again
echo.
set /a PREREQ_ERRORS+=1
goto docker_done
:docker_ok
echo SUCCESS: Docker is running and ready
:docker_done

echo DEBUG: PREREQ_ERRORS=%PREREQ_ERRORS%
if "%PREREQ_ERRORS%"=="0" goto prereqs_ok
echo.
echo ERROR: %PREREQ_ERRORS% prerequisite(s) not met. Please fix the errors above and try again.
echo.
pause
exit /b 1

:prereqs_ok
echo SUCCESS: All prerequisites verified!

echo Cleaning previous environment...
docker-compose -f docker-compose.integrated.yml down -v --remove-orphans >nul 2>&1
docker rm -f api-consumer-localstack >nul 2>&1
docker rm -f api-consumer-backend >nul 2>&1
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :3000') do taskkill /f /pid %%a >nul 2>&1
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :8080') do taskkill /f /pid %%a >nul 2>&1
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :4566') do taskkill /f /pid %%a >nul 2>&1
if exist .next rmdir /s /q .next >nul 2>&1
echo SUCCESS: Environment cleaned!

echo Creating configuration files...

echo Creating backend configuration...
(
echo AWS_REGION=us-east-1
echo AWS_ACCESS_KEY_ID=test
echo AWS_SECRET_ACCESS_KEY=test
echo AWS_DYNAMODB_ENDPOINT=http://localhost:4566
echo AWS_DYNAMODB_TABLE_NAME=audit-logs
echo SPRING_PROFILES_ACTIVE=test
echo SERVICENOW_ENABLED=false
echo ADMIN_USERNAME=admin
echo ADMIN_PASSWORD=admin
echo ADMIN_JWT_SECRET=test-secret-key-for-integration-testing-only
echo ADMIN_JWT_EXPIRATION_MS=86400000
echo CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:3001
) > ..\api-generic-consumer-backend\.env.test

echo Creating frontend configuration...
(
echo NEXT_PUBLIC_BACKEND_URL=http://localhost:8080
echo NEXT_PUBLIC_AZURE_CLIENT_ID=test-client-id
echo NEXT_PUBLIC_AZURE_TENANT_ID=test-tenant-id
echo NEXT_PUBLIC_AZURE_REDIRECT_URI=http://localhost:3000
) > .env.test

echo SUCCESS: Configuration files created!

echo Starting services...

echo Starting LocalStack and Backend...
docker-compose -f docker-compose.integrated.yml up -d localstack backend

echo Waiting for LocalStack to be ready...
set /a WAIT_COUNT=0
set /a MAX_WAIT=90

:wait_localstack
timeout /t 2 >nul
set /a WAIT_COUNT+=1
echo WAIT: Waiting for LocalStack... %WAIT_COUNT%/%MAX_WAIT%

docker ps --filter "name=api-consumer-localstack" --filter "status=running" -q | findstr . >nul 2>&1
if errorlevel 1 goto localstack_container_down

docker exec api-consumer-localstack curl -s -o /dev/null http://localhost:4566/_localstack/health >nul 2>&1
if not errorlevel 1 goto localstack_success

if %WAIT_COUNT% GEQ %MAX_WAIT% goto localstack_timeout
goto wait_localstack

:localstack_container_down
echo ERROR: LocalStack container stopped unexpectedly
docker-compose -f docker-compose.integrated.yml logs localstack
goto localstack_failed

:localstack_timeout
echo ERROR: Timeout waiting for LocalStack after %MAX_WAIT% checks
docker-compose -f docker-compose.integrated.yml logs localstack
goto localstack_failed

:localstack_failed
echo.
echo Possible solutions:
echo   1. Check if Docker Desktop is running
echo   2. Run: docker-compose -f docker-compose.integrated.yml down -v
echo   3. Restart Docker Desktop
pause
exit /b 1

:localstack_success
echo SUCCESS: LocalStack is ready!

echo Waiting for Backend to be ready...
:wait_backend
timeout /t 2 >nul
curl -s http://localhost:8080/actuator/health >nul 2>&1
if errorlevel 1 (
    echo .
    goto wait_backend
)
echo SUCCESS: Backend is ready!

echo Starting Frontend...

if not exist "node_modules" (
    echo Installing frontend dependencies...
    npm install
)

copy .env.test .env.local >nul
start /B npm run dev > frontend.log 2>&1

echo Waiting for Frontend to be ready (compiling Next.js)...
set /a FRONTEND_COUNT=0
set /a FRONTEND_MAX=60

:wait_frontend
timeout /t 3 >nul
set /a FRONTEND_COUNT+=1
echo WAIT: Waiting for Frontend... %FRONTEND_COUNT%/%FRONTEND_MAX%

netstat -an | findstr ":3000 " | findstr "LISTENING" >nul 2>&1
if not errorlevel 1 goto frontend_success

if %FRONTEND_COUNT% GEQ %FRONTEND_MAX% goto frontend_timeout
goto wait_frontend

:frontend_timeout
echo ERROR: Frontend did not start within timeout
echo Check frontend.log for details
pause
exit /b 1

:frontend_success
echo SUCCESS: Frontend is ready!

echo Setting up test data...

aws dynamodb create-table ^
    --table-name audit-logs ^
    --attribute-definitions AttributeName=changeNumber,AttributeType=S AttributeName=timestamp,AttributeType=S ^
    --key-schema AttributeName=changeNumber,KeyType=HASH AttributeName=timestamp,KeyType=RANGE ^
    --billing-mode PAY_PER_REQUEST ^
    --endpoint-url http://localhost:4566 ^
    --region us-east-1 >nul 2>&1

aws secretsmanager create-secret ^
    --name api-consumer/api-credentials ^
    --secret-string "{\"username\":\"test\",\"password\":\"test\",\"clientId\":\"test\",\"clientSecret\":\"test\",\"tokenUrl\":\"https://httpbin.org/post\"}" ^
    --endpoint-url http://localhost:4566 ^
    --region us-east-1 >nul 2>&1

echo SUCCESS: Test data configured!

echo.
echo Integrated test environment is ready!
echo ==========================================
echo.
echo Applications:
echo    Frontend: http://localhost:3000
echo    Backend:  http://localhost:8080
echo    LocalStack: http://localhost:4566
echo.
echo Useful endpoints:
echo    Health Backend: http://localhost:8080/actuator/health
echo    Admin Token: POST http://localhost:8080/auth/token
echo    Proxy API: POST http://localhost:8080/api/proxy
echo    ServiceNow Validation: POST http://localhost:8080/api/servicenow/validate
echo.
echo To stop the environment:
echo    stop-integrated-test.bat
echo.
echo To test:
echo    1. Access http://localhost:3000
echo    2. Use admin/admin to get token
echo    3. Test APIs through frontend
echo.

echo SUCCESS: Setup complete! Environment ready for testing.
pause
