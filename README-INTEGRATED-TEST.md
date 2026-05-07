# Teste Integrado - API Generic Consumer

Guia completo para executar o ambiente de teste integrado completo com backend, frontend e serviços AWS simulados.

## 🚀 Início Rápido

### Windows
```bash
# Iniciar ambiente completo
start-integrated-test.bat

# Parar ambiente
stop-integrated-test.bat
```

### Linux/Mac
```bash
# Dar permissão de execução (Linux/Mac)
chmod +x start-integrated-test.sh stop-integrated-test.sh

# Iniciar ambiente completo
./start-integrated-test.sh

# Parar ambiente
./stop-integrated-test.sh
```

## 🏗️ Arquitetura do Ambiente

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │    Backend      │    │   LocalStack    │
│  (Next.js)     │◄──►│ (Spring Boot)  │◄──►│   (AWS Sim)     │
│  :3000         │    │    :8080       │    │    :4566        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📋 Pré-requisitos

### Obrigatórios
- **Docker Desktop** (para LocalStack e Backend)
- **Node.js 20+** (para Frontend)
- **Java 21+** (incluído no Docker do Backend)
- **Git** (para clonar repositórios)

### Verificação
```bash
# Verificar Docker
docker --version
docker-compose --version

# Verificar Node.js
node --version
npm --version

# Verificar Java
java -version
```

## 🔧 Componentes do Ambiente

### 1. **LocalStack** (Porta 4566)
- Simula serviços AWS localmente
- **DynamoDB**: Armazenamento de logs de auditoria
- **Secrets Manager**: Gerenciamento de credenciais
- **Endpoint**: `http://localhost:4566`

### 2. **Backend** (Porta 8080)
- API Spring Boot com Docker
- **Health Check**: `http://localhost:8080/actuator/health`
- **Admin Token**: `POST http://localhost:8080/auth/token`
- **Proxy API**: `POST http://localhost:8080/api/proxy`
- **ServiceNow**: `POST http://localhost:8080/api/servicenow/validate`

### 3. **Frontend** (Porta 3000)
- Interface Next.js
- **Acesso**: `http://localhost:3000`
- **Login**: admin/admin (para desenvolvimento)

## 🧪 Fluxo de Teste

### 1. Iniciar Ambiente
```bash
# Windows
start-integrated-test.bat

# Linux/Mac
./start-integrated-test.sh
```

### 2. Aguardar Setup Completo
O script irá:
- ✅ Verificar pré-requisitos
- ✅ Limpar ambiente anterior
- ✅ Criar configurações
- ✅ Iniciar LocalStack
- ✅ Iniciar Backend
- ✅ Iniciar Frontend
- ✅ Configurar dados de teste

### 3. Acessar Aplicações
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8080
- **LocalStack Console**: http://localhost:4566

### 4. Testar Funcionalidades

#### Obter Token Admin
```bash
curl -X POST http://localhost:8080/auth/token \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin"}'
```

#### Testar Proxy API
```bash
curl -X POST http://localhost:8080/api/proxy \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SEU_TOKEN" \
  -d '{
    "url": "https://httpbin.org/get",
    "method": "GET",
    "changeNumber": "INC123456"
  }'
```

#### Testar Validação ServiceNow
```bash
curl -X POST http://localhost:8080/api/servicenow/validate \
  -H "Content-Type: application/json" \
  -d '{
    "changeNumber": "CHG123456",
    "apiUrl": "https://instance.service-now.com/api/now/table/incident"
  }'
```

## 📊 Logs e Monitoramento

### Logs em Tempo Real
```bash
# Logs do Backend
docker-compose -f docker-compose.integrated.yml logs -f backend

# Logs do LocalStack
docker-compose -f docker-compose.integrated.yml logs -f localstack

# Logs do Frontend (Windows)
type frontend.log

# Logs do Frontend (Linux/Mac)
tail -f frontend.log
```

### Health Checks
```bash
# Backend Health
curl http://localhost:8080/actuator/health

# LocalStack Health
curl http://localhost:4566/_localstack/health

# Frontend Health
curl http://localhost:3000
```

## 🔧 Configurações

### Variáveis de Ambiente

#### Backend (.env.test)
```bash
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=test
AWS_SECRET_ACCESS_KEY=test
AWS_DYNAMODB_ENDPOINT=http://localhost:4566
SPRING_PROFILES_ACTIVE=test
SERVICENOW_ENABLED=false
ADMIN_USERNAME=admin
ADMIN_PASSWORD=admin
```

#### Frontend (.env.test)
```bash
NEXT_PUBLIC_BACKEND_URL=http://localhost:8080
NEXT_PUBLIC_AZURE_CLIENT_ID=test-client-id
NEXT_PUBLIC_AZURE_TENANT_ID=test-tenant-id
```

### Personalização
Para customizar o ambiente:

1. **Editar configurações** nos arquivos `.env.test`
2. **Modificar Docker Compose** em `docker-compose.integrated.yml`
3. **Ajustar scripts** de startup conforme necessário

## 🐛 Troubleshooting

### Problemas Comuns

#### Portas Ocupadas
```bash
# Verificar processos nas portas
netstat -aon | findstr :3000
netstat -aon | findstr :8080
netstat -aon | findstr :4566

# Matar processos (Windows)
taskkill /f /pid PID

# Matar processos (Linux/Mac)
kill -9 PID
```

#### Docker Issues
```bash
# Reiniciar Docker Desktop
# Limpar containers
docker system prune -a

# Verificar status
docker ps
docker-compose -f docker-compose.integrated.yml ps
```

#### Frontend Não Inicia
```bash
# Reinstalar dependências
cd api-generic-consumer-frontend
rm -rf node_modules package-lock.json
npm install

# Limpar cache
npm cache clean --force
```

#### Backend Não Inicia
```bash
# Verificar logs
docker-compose -f docker-compose.integrated.yml logs backend

# Rebuildar imagem
docker-compose -f docker-compose.integrated.yml build --no-cache backend
```

### Logs de Erro

#### ServiceNow Validation
```bash
# Testar validação diretamente
curl -X POST http://localhost:8080/api/servicenow/validate \
  -H "Content-Type: application/json" \
  -d '{"changeNumber":"INVALID","apiUrl":"http://test.com"}'
```

#### AWS Services
```bash
# Verificar LocalStack
curl http://localhost:4566/_localstack/health

# Listar tabelas DynamoDB
aws dynamodb list-tables --endpoint-url http://localhost:4566 --region us-east-1

# Listar secrets
aws secretsmanager list-secrets --endpoint-url http://localhost:4566 --region us-east-1
```

## 🔄 Ciclo de Desenvolvimento

### 1. Desenvolvimento Local
```bash
# Iniciar ambiente
start-integrated-test.bat

# Desenvolver com hot reload
# Frontend: http://localhost:3000 (auto-reload)
# Backend: Rebuild Docker manualmente
```

### 2. Testes Automatizados
```bash
# Testes unitários (se Gradle disponível)
cd api-generic-consumer-backend
gradle test

# Testes frontend
cd api-generic-consumer-frontend
npm test
```

### 3. Limpeza
```bash
# Parar ambiente completo
stop-integrated-test.bat

# Limpar manualmente se necessário
docker-compose -f docker-compose.integrated.yml down -v
docker system prune -a
```

## 📚 Documentação Adicional

- [Backend README](api-generic-consumer-backend/README.md)
- [Frontend README](api-generic-consumer-frontend/README.md)
- [Git Flow](api-generic-consumer-backend/docs/GIT_FLOW.md)
- [ServiceNow Integration](api-generic-consumer-backend/docs/SERVICENOW_INTEGRATION.md)

## 🆘 Suporte

### Issues Comuns
1. **Porta 3000 ocupada**: Fechar outras aplicações Node.js
2. **Docker não inicia**: Verificar Docker Desktop
3. **LocalStack erro**: Aguardar mais tempo no startup
4. **Frontend não conecta**: Verificar CORS no backend

### Contato
- Issues: [GitHub Issues](https://github.com/rafaelakio/api-generic-consumer-backend/issues)
- Documentação: [docs/](api-generic-consumer-backend/docs/)
