#!/bin/bash

# Script para parar ambiente de teste integrado

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo "🛑 Parando ambiente de teste integrado..."
echo "======================================"

# Mudar para o diretório raiz
cd "$(dirname "$0")"

# Parar containers Docker
log_info "Parando containers Docker..."
docker-compose -f docker-compose.integrated.yml down -v --remove-orphans 2>/dev/null || log_warning "Docker Compose não encontrado ou já parado"

# Matar processo do frontend
if [ -f "frontend.pid" ]; then
    FRONTEND_PID=$(cat frontend.pid)
    if ps -p $FRONTEND_PID > /dev/null 2>&1; then
        log_info "Parando frontend (PID: $FRONTEND_PID)..."
        kill $FRONTEND_PID
    fi
    rm frontend.pid
fi

# Matar processos que possam estar usando as portas
log_info "Limpando processos nas portas..."
lsof -ti:3000 | xargs kill -9 2>/dev/null || true
lsof -ti:8080 | xargs kill -9 2>/dev/null || true
lsof -ti:4566 | xargs kill -9 2>/dev/null || true

# Limpar arquivos temporários
log_info "Limpando arquivos temporários..."
rm -f frontend.log
rm -f ../api-generic-consumer-backend/.env.test
rm -f .env.test
rm -f .env.local

log_success "Ambiente de teste integrado parado com sucesso!"
