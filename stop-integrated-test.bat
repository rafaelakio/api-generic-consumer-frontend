@echo off
REM Script para parar ambiente de teste integrado (Windows)

echo 🛑 Parando ambiente de teste integrado...
echo ======================================

REM Mudar para o diretório raiz
cd /d "%~dp0"

REM Parar containers Docker
echo [INFO] Parando containers Docker...
docker-compose -f docker-compose.integrated.yml down -v --remove-orphans >nul 2>&1

REM Matar processos que possam estar usando as portas
echo [INFO] Limpando processos nas portas...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :3000') do (
    taskkill /f /pid %%a >nul 2>&1
)
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :8080') do (
    taskkill /f /pid %%a >nul 2>&1
)
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :4566') do (
    taskkill /f /pid %%a >nul 2>&1
)

REM Limpar arquivos temporários
echo [INFO] Limpando arquivos temporários...
del /f /q ..\api-generic-consumer-backend\.env.test >nul 2>&1
del /f /q .env.test >nul 2>&1
del /f /q .env.local >nul 2>&1

echo [SUCCESS] Ambiente de teste integrado parado com sucesso!
pause
