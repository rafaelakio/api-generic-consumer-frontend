#!/bin/bash

# Script para iniciar ambiente de teste integrado completo
# Backend (Spring Boot) + Frontend (Next.js) + LocalStack (AWS Services)

set -e

echo "🚀 Iniciando ambiente de teste integrado..."
echo "========================================"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funções de utilidade
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

# Verificar pré-requisitos
check_prerequisites() {
    log_info "Verificando pré-requisitos..."
    
    # Verificar Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker não encontrado. Por favor, instale o Docker."
        exit 1
    fi
    
    # Verificar Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose não encontrado. Por favor, instale o Docker Compose."
        exit 1
    fi
    
    # Verificar Node.js (para frontend)
    if ! command -v node &> /dev/null; then
        log_error "Node.js não encontrado. Por favor, instale o Node.js 20+."
        exit 1
    fi
    
    # Verificar Java (para backend)
    if ! command -v java &> /dev/null; then
        log_error "Java não encontrado. Por favor, instale o Java 21+."
        exit 1
    fi
    
    log_success "Pré-requisitos verificados com sucesso!"
}

# Limpar ambiente anterior
cleanup() {
    log_info "Limpando ambiente anterior..."
    
    # Parar containers
    docker-compose -f docker-compose.integrated.yml down -v --remove-orphans 2>/dev/null || true
    
    # Matar processos que possam estar usando as portas
    lsof -ti:3000 | xargs kill -9 2>/dev/null || true
    lsof -ti:8080 | xargs kill -9 2>/dev/null || true
    lsof -ti:4566 | xargs kill -9 2>/dev/null || true
    
    log_success "Ambiente limpo!"
}

# Criar arquivos de configuração
create_config_files() {
    log_info "Criando arquivos de configuração..."
    
    # Configuração para backend
    cat > ../api-generic-consumer-backend/.env.test << EOF
# Configurações de teste integrado
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=test
AWS_SECRET_ACCESS_KEY=test
AWS_DYNAMODB_ENDPOINT=http://localhost:4566
AWS_DYNAMODB_TABLE_NAME=audit-logs
SPRING_PROFILES_ACTIVE=test

# ServiceNow (desabilitado para testes)
SERVICENOW_ENABLED=false

# Admin
ADMIN_USERNAME=admin
ADMIN_PASSWORD=admin
ADMIN_JWT_SECRET=test-secret-key-for-integration-testing-only
ADMIN_JWT_EXPIRATION_MS=86400000

# CORS
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:3001
EOF

    # Configuração para frontend
    cat > .env.test << EOF
# Configurações de teste integrado
NEXT_PUBLIC_BACKEND_URL=http://localhost:8080
NEXT_PUBLIC_AZURE_CLIENT_ID=test-client-id
NEXT_PUBLIC_AZURE_TENANT_ID=test-tenant-id
NEXT_PUBLIC_AZURE_REDIRECT_URI=http://localhost:3000
EOF

    log_success "Arquivos de configuração criados!"
}

# Criar Docker Compose para teste integrado
create_docker_compose() {
    log_info "Criando Docker Compose para teste integrado..."
    
    cat > docker-compose.integrated.yml << EOF
version: '3.8'

services:
  # LocalStack - Simulação de serviços AWS
  localstack:
    image: localstack/localstack:latest
    container_name: api-consumer-localstack
    ports:
      - "4566:4566"
      - "4510-4559:4510-4559"
    environment:
      - DEBUG=1
      - SERVICES=dynamodb,secretsmanager
      - DEFAULT_REGION=us-east-1
      - AWS_ACCESS_KEY_ID=test
      - AWS_SECRET_ACCESS_KEY=test
      - DOCKER_HOST=unix:///var/run/docker.sock
    volumes:
      - "./localstack-init:/docker-entrypoint-initaws.d"
      - "../api-generic-consumer-backend/localstack-init:/docker-entrypoint-initaws.d"
    networks:
      - api-consumer-network

  # Backend - Spring Boot API
  backend:
    build:
      context: ../api-generic-consumer-backend
      dockerfile: Dockerfile
    container_name: api-consumer-backend
    ports:
      - "8080:8080"
    environment:
      - AWS_REGION=us-east-1
      - AWS_ACCESS_KEY_ID=test
      - AWS_SECRET_ACCESS_KEY=test
      - AWS_DYNAMODB_ENDPOINT=http://localstack:4566
      - AWS_DYNAMODB_TABLE_NAME=audit-logs
      - SPRING_PROFILES_ACTIVE=test
      - SERVICENOW_ENABLED=false
      - ADMIN_USERNAME=admin
      - ADMIN_PASSWORD=admin
      - ADMIN_JWT_SECRET=test-secret-key-for-integration-testing-only
      - CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:3001
    depends_on:
      - localstack
    networks:
      - api-consumer-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 60s

networks:
  api-consumer-network:
    driver: bridge

volumes:
  localstack-data:
EOF

    log_success "Docker Compose criado!"
}

# Iniciar serviços
start_services() {
    log_info "Iniciando serviços..."
    
    # Iniciar backend e LocalStack via Docker Compose
    log_info "Iniciando LocalStack e Backend..."
    docker-compose -f docker-compose.integrated.yml up -d localstack backend
    
    # Aguardar LocalStack estar pronto
    log_info "Aguardando LocalStack estar pronto..."
    for i in {1..30}; do
        if curl -s http://localhost:4566/_localstack/health > /dev/null 2>&1; then
            log_success "LocalStack está pronto!"
            break
        fi
        echo -n "."
        sleep 2
    done
    
    # Aguardar backend estar pronto
    log_info "Aguardando Backend estar pronto..."
    for i in {1..60}; do
        if curl -s http://localhost:8080/actuator/health > /dev/null 2>&1; then
            log_success "Backend está pronto!"
            break
        fi
        echo -n "."
        sleep 2
    done
    
    # Iniciar frontend (localmente, fora do Docker para melhor desenvolvimento)
    log_info "Iniciando Frontend..."
    
    # Verificar se node_modules existe
    if [ ! -d "node_modules" ]; then
        log_info "Instalando dependências do frontend..."
        npm install
    fi
    
    # Iniciar frontend em background
    cp .env.test .env.local
    npm run dev > frontend.log 2>&1 &
    FRONTEND_PID=$!
    echo $FRONTEND_PID > frontend.pid
    
    # Aguardar frontend estar pronto
    log_info "Aguardando Frontend estar pronto..."
    for i in {1..30}; do
        if curl -s http://localhost:3000 > /dev/null 2>&1; then
            log_success "Frontend está pronto!"
            break
        fi
        echo -n "."
        sleep 2
    done
}

# Configurar dados de teste
setup_test_data() {
    log_info "Configurando dados de teste..."
    
    # Criar tabela DynamoDB
    aws dynamodb create-table \
        --table-name audit-logs \
        --attribute-definitions AttributeName=changeNumber,AttributeType=S AttributeName=timestamp,AttributeType=S \
        --key-schema AttributeName=changeNumber,KeyType=HASH AttributeName=timestamp,KeyType=RANGE \
        --billing-mode PAY_PER_REQUEST \
        --endpoint-url http://localhost:4566 \
        --region us-east-1 2>/dev/null || log_warning "Tabela audit-logs já existe"
    
    # Criar secret de teste
    aws secretsmanager create-secret \
        --name api-consumer/api-credentials \
        --secret-string '{"username":"test","password":"test","clientId":"test","clientSecret":"test","tokenUrl":"https://httpbin.org/post"}' \
        --endpoint-url http://localhost:4566 \
        --region us-east-1 2>/dev/null || log_warning "Secret já existe"
    
    log_success "Dados de teste configurados!"
}

# Exibir informações de acesso
show_access_info() {
    echo ""
    echo "🎉 Ambiente de teste integrado está pronto!"
    echo "=========================================="
    echo ""
    echo "📱 Aplicações:"
    echo "   Frontend: http://localhost:3000"
    echo "   Backend:  http://localhost:8080"
    echo "   LocalStack: http://localhost:4566"
    echo ""
    echo "🔧 Endpoints úteis:"
    echo "   Health Backend: http://localhost:8080/actuator/health"
    echo "   Admin Token: POST http://localhost:8080/auth/token"
    echo "   Proxy API: POST http://localhost:8080/api/proxy"
    echo "   ServiceNow Validation: POST http://localhost:8080/api/servicenow/validate"
    echo ""
    echo "📝 Logs:"
    echo "   Frontend: tail -f frontend.log"
    echo "   Backend: docker-compose -f docker-compose.integrated.yml logs -f backend"
    echo "   LocalStack: docker-compose -f docker-compose.integrated.yml logs -f localstack"
    echo ""
    echo "🛑 Para parar o ambiente:"
    echo "   ./stop-integrated-test.sh"
    echo ""
    echo "🧪 Para testar:"
    echo "   1. Acesse http://localhost:3000"
    echo "   2. Use admin/admin para obter token"
    echo "   3. Teste as APIs através do frontend"
    echo ""
}

# Função principal
main() {
    echo "🚀 Script de Teste Integrado - API Generic Consumer"
    echo "================================================="
    echo ""
    
    # Mudar para o diretório raiz
    cd "$(dirname "$0")"
    
    # Executar etapas
    check_prerequisites
    cleanup
    create_config_files
    create_docker_compose
    start_services
    setup_test_data
    show_access_info
    
    log_success "Setup completo! Ambiente pronto para testes."
}

# Trap para cleanup em caso de interrupção
trap cleanup EXIT

# Executar função principal
main "$@"
