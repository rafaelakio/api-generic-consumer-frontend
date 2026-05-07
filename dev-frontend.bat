@echo off
REM Script para desenvolvimento apenas do frontend

echo 🎨 Iniciando Frontend em modo desenvolvimento...
echo ============================================

cd /d "%~dp0"

REM Verificar se node_modules existe
if not exist "node_modules" (
    echo [INFO] Instalando dependências...
    npm install
)

REM Copiar configuração de teste
if exist ".env.test" (
    copy .env.test .env.local >nul
    echo [INFO] Configuração de teste copiada para .env.local
)

REM Iniciar frontend
echo [INFO] Iniciando servidor de desenvolvimento...
echo [INFO] Frontend estará disponível em http://localhost:3000
echo.
npm run dev

pause
