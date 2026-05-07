# Arquitetura Completa - API Generic Consumer

## 📋 Visão Geral

Este documento apresenta a arquitetura completa do sistema API Generic Consumer, mostrando a interação entre Frontend (Next.js), API Gateway (AWS), Backend (Spring Boot) e serviços AWS.

## 🏗️ Arquitetura Geral

```mermaid
graph TB
    subgraph "Client Layer"
        USER[👤 Usuário]
        BROWSER[🌐 Navegador Web]
    end
    
    subgraph "Frontend - Next.js"
        NEXTJS[Next.js Application]
        PAGES[Pages/Components]
        SERVICES[Services Layer]
        AUTH[Azure AD Auth]
    end
    
    subgraph "AWS Cloud"
        subgraph "Edge Services"
            CF[☁️ CloudFront<br/>CDN]
            S3[📦 S3 Bucket<br/>Static Assets]
        end
        
        subgraph "API Layer"
            APIGW[🚪 API Gateway<br/>REST API]
            WAF[🛡️ AWS WAF<br/>Security]
            COGNITO[🔐 Cognito<br/>User Pool]
        end
        
        subgraph "Compute Layer"
            ALB[⚖️ Application<br/>Load Balancer]
            ECS[🐳 ECS/Fargate<br/>Container Service]
            BACKEND[🔧 Spring Boot<br/>Backend API]
        end
        
        subgraph "Data Layer"
            DYNAMO[💾 DynamoDB<br/>Audit Logs]
            SECRETS[🔑 Secrets Manager<br/>API Credentials]
            PARAM[⚙️ Parameter Store<br/>Configuration]
        end
        
        subgraph "Monitoring"
            CW[📊 CloudWatch<br/>Logs & Metrics]
            XRAY[🔍 X-Ray<br/>Tracing]
        end
    end
    
    subgraph "External Services"
        EXTAPI[🌍 External APIs<br/>Third-party Services]
    end
    
    USER --> BROWSER
    BROWSER --> CF
    CF --> S3
    CF --> NEXTJS
    NEXTJS --> PAGES
    PAGES --> SERVICES
    SERVICES --> AUTH
    SERVICES --> APIGW
    
    APIGW --> WAF
    WAF --> ALB
    ALB --> ECS
    ECS --> BACKEND
    
    BACKEND --> SECRETS
    BACKEND --> DYNAMO
    BACKEND --> PARAM
    BACKEND --> EXTAPI
    
    BACKEND --> CW
    BACKEND --> XRAY
    APIGW --> CW
    
    AUTH -.->|OAuth2| COGNITO
    
    style USER fill:#e1f5ff
    style BROWSER fill:#e1f5ff
    style NEXTJS fill:#61dafb
    style BACKEND fill:#6db33f
    style APIGW fill:#ff9900
    style DYNAMO fill:#ff9900
    style SECRETS fill:#ff9900
    style CW fill:#ff9900
```

## 🔄 Fluxo de Requisição Completo

```mermaid
sequenceDiagram
    autonumber
    participant User as 👤 Usuário
    participant Browser as 🌐 Browser
    participant NextJS as Next.js Frontend
    participant CloudFront as ☁️ CloudFront
    participant APIGateway as 🚪 API Gateway
    participant WAF as 🛡️ WAF
    participant ALB as ⚖️ ALB
    participant Backend as 🔧 Spring Boot
    participant Secrets as 🔑 Secrets Manager
    participant DynamoDB as 💾 DynamoDB
    participant ExtAPI as 🌍 External API
    participant CloudWatch as 📊 CloudWatch

    User->>Browser: Acessa aplicação
    Browser->>CloudFront: GET /
    CloudFront->>NextJS: Serve static assets
    NextJS-->>Browser: Renderiza UI
    
    User->>Browser: Preenche formulário<br/>e clica "Enviar"
    Browser->>NextJS: Submit form data
    
    Note over NextJS: Valida dados<br/>Prepara requisição
    
    NextJS->>APIGateway: POST /api/proxy<br/>Authorization: Bearer token<br/>Body: {url, method, headers}
    
    APIGateway->>WAF: Valida requisição
    WAF->>WAF: Check rate limits<br/>SQL injection<br/>XSS attacks
    
    WAF->>APIGateway: ✅ Request válido
    APIGateway->>CloudWatch: Log access
    
    APIGateway->>ALB: Forward request
    ALB->>Backend: Route to healthy instance
    
    Note over Backend: 📝 LOG: Request recebido<br/>ChangeNumber: CHG123456
    
    Backend->>Secrets: GetSecretValue<br/>(api-credentials)
    Secrets-->>Backend: {clientId, clientSecret, tokenUrl}
    
    Note over Backend: 📝 LOG: Credenciais obtidas
    
    Backend->>ExtAPI: POST /oauth/token<br/>(client_credentials)
    ExtAPI-->>Backend: {access_token, expires_in}
    
    Note over Backend: 📝 LOG: Token OAuth obtido
    
    Backend->>ExtAPI: HTTP Request<br/>Authorization: Bearer token
    ExtAPI-->>Backend: HTTP Response
    
    Note over Backend: 📝 LOG: Response recebido<br/>Status: 200, Duration: 450ms
    
    Backend->>DynamoDB: PutItem (audit log)
    DynamoDB-->>Backend: Success
    
    Note over Backend: 📝 LOG: Auditoria gravada
    
    Backend->>CloudWatch: Send metrics & logs
    Backend-->>ALB: HTTP Response
    ALB-->>APIGateway: Forward response
    APIGateway-->>NextJS: HTTP Response
    
    Note over NextJS: 📝 LOG: Response recebido<br/>Total duration: 1.2s
    
    NextJS-->>Browser: Update UI
    Browser-->>User: Exibe resultado
```

## 🎯 Componentes Detalhados

### 1. Frontend (Next.js)

```mermaid
graph TB
    subgraph "Next.js Application"
        subgraph "Pages"
            HOME[🏠 Home Page]
            PROXY[📡 Proxy Page]
            AUDIT[📊 Audit Logs Page]
        end
        
        subgraph "Components"
            FORM[📝 API Request Form]
            TABLE[📋 Results Table]
            ALERT[⚠️ Alert Component]
            LOADING[⏳ Loading Spinner]
        end
        
        subgraph "Services"
            BACKEND_SVC[Backend Service]
            AUTH_SVC[Auth Service]
            STORAGE_SVC[Storage Service]
        end
        
        subgraph "State Management"
            CONTEXT[React Context]
            HOOKS[Custom Hooks]
        end
        
        subgraph "Utils"
            LOGGER[Logger Utility]
            VALIDATOR[Validator]
            FORMATTER[Formatter]
        end
    end
    
    HOME --> FORM
    PROXY --> FORM
    PROXY --> TABLE
    AUDIT --> TABLE
    
    FORM --> BACKEND_SVC
    TABLE --> BACKEND_SVC
    
    BACKEND_SVC --> AUTH_SVC
    BACKEND_SVC --> LOGGER
    
    FORM --> VALIDATOR
    TABLE --> FORMATTER
    
    CONTEXT --> HOOKS
    HOOKS --> BACKEND_SVC
    
    style HOME fill:#61dafb
    style PROXY fill:#61dafb
    style BACKEND_SVC fill:#4caf50
    style AUTH_SVC fill:#ff9800
```

#### Estrutura de Arquivos Frontend

```
api-generic-consumer-frontend/
├── src/
│   ├── app/                    # Next.js App Router
│   │   ├── page.tsx           # Home page
│   │   ├── proxy/
│   │   │   └── page.tsx       # Proxy page
│   │   └── audit/
│   │       └── page.tsx       # Audit logs page
│   │
│   ├── components/            # React Components
│   │   ├── ApiRequestForm.tsx
│   │   ├── ResultsTable.tsx
│   │   ├── AlertMessage.tsx
│   │   └── LoadingSpinner.tsx
│   │
│   ├── services/              # API Services
│   │   ├── backend.service.ts # Backend API calls
│   │   ├── auth.service.ts    # Authentication
│   │   └── storage.service.ts # Local storage
│   │
│   ├── hooks/                 # Custom React Hooks
│   │   ├── useApi.ts
│   │   ├── useAuth.ts
│   │   └── useLogger.ts
│   │
│   ├── utils/                 # Utilities
│   │   ├── logger.ts          # Logging utility
│   │   ├── validator.ts       # Input validation
│   │   └── formatter.ts       # Data formatting
│   │
│   └── types/                 # TypeScript types
│       ├── api.types.ts
│       └── auth.types.ts
│
├── public/                    # Static assets
├── .env.local                 # Environment variables
└── package.json
```

### 2. Backend (Spring Boot)

```mermaid
graph TB
    subgraph "Spring Boot Backend - Hexagonal Architecture"
        subgraph "Infrastructure Layer"
            subgraph "Input Adapters"
                CTRL_PROXY[ProxyController]
                CTRL_AUTH[AuthController]
                CTRL_AUDIT[AuditController]
            end
            
            subgraph "Output Adapters"
                HTTP_ADAPTER[OkHttpClientAdapter]
                OAUTH_ADAPTER[OAuthTokenAdapter]
                SECRETS_ADAPTER[AwsSecretsAdapter]
                DYNAMO_ADAPTER[DynamoDbAuditAdapter]
            end
            
            subgraph "Configuration"
                AWS_CONFIG[AwsConfig]
                SECURITY_CONFIG[SecurityConfig]
                WEB_CONFIG[WebConfig]
            end
        end
        
        subgraph "Application Layer"
            PROXY_SVC[ProxyService]
            AUDIT_SVC[AuditLogService]
            TOKEN_SVC[TokenService]
        end
        
        subgraph "Domain Layer"
            MODELS[Domain Models]
            PORTS[Ports/Interfaces]
            USECASES[Use Cases]
        end
    end
    
    CTRL_PROXY --> PROXY_SVC
    CTRL_AUTH --> TOKEN_SVC
    CTRL_AUDIT --> AUDIT_SVC
    
    PROXY_SVC --> PORTS
    AUDIT_SVC --> PORTS
    
    PORTS --> HTTP_ADAPTER
    PORTS --> OAUTH_ADAPTER
    PORTS --> SECRETS_ADAPTER
    PORTS --> DYNAMO_ADAPTER
    
    PROXY_SVC --> MODELS
    AUDIT_SVC --> MODELS
    
    AWS_CONFIG -.-> SECRETS_ADAPTER
    AWS_CONFIG -.-> DYNAMO_ADAPTER
    SECURITY_CONFIG -.-> CTRL_PROXY
    
    style CTRL_PROXY fill:#6db33f
    style PROXY_SVC fill:#4caf50
    style MODELS fill:#7c4dff
    style PORTS fill:#7c4dff
```

#### Estrutura de Arquivos Backend

```
api-generic-consumer-backend/
├── src/main/kotlin/com/apiconsumer/
│   ├── domain/                          # Domain Layer
│   │   ├── model/
│   │   │   ├── ApiRequest.kt
│   │   │   ├── ApiResponse.kt
│   │   │   ├── ApiCredentials.kt
│   │   │   └── AuditLogEntry.kt
│   │   └── port/
│   │       ├── input/
│   │       │   ├── ExecuteProxyUseCase.kt
│   │       │   └── WriteAuditLogUseCase.kt
│   │       └── output/
│   │           ├── HttpClientPort.kt
│   │           ├── TokenProviderPort.kt
│   │           ├── SecretsManagerPort.kt
│   │           └── AuditLogRepositoryPort.kt
│   │
│   ├── application/                     # Application Layer
│   │   └── service/
│   │       ├── ProxyService.kt
│   │       ├── AuditLogService.kt
│   │       └── TokenService.kt
│   │
│   └── infrastructure/                  # Infrastructure Layer
│       ├── adapter/
│       │   ├── input/
│       │   │   └── web/
│       │   │       ├── ProxyController.kt
│       │   │       ├── AuthController.kt
│       │   │       └── AuditLogController.kt
│       │   └── output/
│       │       ├── http/
│       │       │   └── OkHttpClientAdapter.kt
│       │       ├── oauth/
│       │       │   └── OAuthTokenAdapter.kt
│       │       ├── aws/
│       │       │   └── AwsSecretsAdapter.kt
│       │       └── dynamodb/
│       │           └── DynamoDbAuditLogAdapter.kt
│       └── config/
│           ├── AwsConfig.kt
│           ├── DynamoDbConfig.kt
│           ├── SecurityConfig.kt
│           └── WebConfig.kt
│
├── src/main/resources/
│   ├── application.yml
│   └── application-prod.yml
│
└── build.gradle.kts
```

## 🔐 Fluxo de Autenticação

```mermaid
sequenceDiagram
    participant User as 👤 Usuário
    participant Frontend as Next.js
    participant AzureAD as Azure AD
    participant APIGateway as API Gateway
    participant Backend as Spring Boot
    participant Cognito as AWS Cognito

    Note over User,Cognito: Opção 1: Azure AD (Corporativo)
    
    User->>Frontend: Clica "Login"
    Frontend->>AzureAD: Redirect to login
    AzureAD->>User: Exibe tela de login
    User->>AzureAD: Credenciais
    AzureAD->>Frontend: Redirect com code
    Frontend->>AzureAD: Exchange code for token
    AzureAD-->>Frontend: JWT Token
    Frontend->>APIGateway: Request com Bearer token
    APIGateway->>APIGateway: Valida JWT (JWKS)
    APIGateway->>Backend: Forward request
    
    Note over User,Cognito: Opção 2: Admin Token (Desenvolvimento)
    
    User->>Frontend: Username/Password
    Frontend->>Backend: POST /auth/token
    Backend->>Backend: Valida credenciais
    Backend-->>Frontend: Admin JWT Token
    Frontend->>APIGateway: Request com Bearer token
    APIGateway->>Backend: Forward request
```

## 📊 Fluxo de Dados e Auditoria

```mermaid
graph LR
    subgraph "Request Flow"
        A[Frontend Request] --> B[API Gateway]
        B --> C[Backend]
        C --> D[External API]
    end
    
    subgraph "Audit Flow"
        C --> E[Audit Service]
        E --> F[DynamoDB]
        F --> G[Audit Logs Table]
    end
    
    subgraph "Monitoring Flow"
        B --> H[CloudWatch Logs]
        C --> H
        D --> H
        H --> I[CloudWatch Metrics]
        I --> J[CloudWatch Alarms]
        J --> K[SNS Notifications]
    end
    
    style A fill:#61dafb
    style C fill:#6db33f
    style F fill:#ff9900
    style H fill:#ff9900
```

## 🗄️ Modelo de Dados DynamoDB

```mermaid
erDiagram
    AUDIT_LOGS {
        string changeNumber PK
        string timestamp SK
        string level
        string message
        string tableData
        number ttl
        string requestId
        string userId
        string method
        string url
        number statusCode
        number duration
    }
    
    AUDIT_LOGS ||--o{ SESSION : "belongs to"
    
    SESSION {
        string changeNumber
        datetime openedAt
        datetime closedAt
        number totalCalls
        number successCalls
        number errorCalls
    }
```

### Estrutura da Tabela audit-logs

| Campo | Tipo | Descrição | Exemplo |
|-------|------|-----------|---------|
| **changeNumber** | String (PK) | Identificador da sessão | CHG123456 |
| **timestamp** | String (SK) | ISO 8601 timestamp | 2026-05-07T12:00:00.000Z |
| **level** | String | Nível do log | SESSION_OPEN, CALL, SESSION_CLOSE |
| **message** | String | Mensagem descritiva | "Requisição executada com sucesso" |
| **tableData** | String (JSON) | Dados estruturados | {"url": "...", "status": 200} |
| **ttl** | Number | Time to live (30 dias) | 1715097600 |
| **requestId** | String | ID único da requisição | uuid-v4 |
| **userId** | String | ID do usuário | user@example.com |
| **method** | String | Método HTTP | GET, POST, PUT, DELETE |
| **url** | String | URL da API externa | https://api.example.com/v1/resource |
| **statusCode** | Number | Status HTTP | 200, 404, 500 |
| **duration** | Number | Duração em ms | 450 |

## 🌍 Ambientes de Deployment

### Ambiente Local (Desenvolvimento)

```mermaid
graph TB
    subgraph "Local Development"
        DEV_BROWSER[Browser<br/>localhost:3000]
        DEV_NEXT[Next.js Dev Server<br/>Port 3000]
        DEV_LOCALSTACK[LocalStack<br/>Port 4566]
        DEV_BACKEND[Spring Boot<br/>Port 8080]
        DEV_DYNAMO[DynamoDB Local]
        DEV_SECRETS[Secrets Manager Local]
    end
    
    DEV_BROWSER --> DEV_NEXT
    DEV_NEXT --> DEV_LOCALSTACK
    DEV_LOCALSTACK --> DEV_BACKEND
    DEV_BACKEND --> DEV_DYNAMO
    DEV_BACKEND --> DEV_SECRETS
    
    style DEV_NEXT fill:#61dafb
    style DEV_BACKEND fill:#6db33f
    style DEV_LOCALSTACK fill:#ff9900
```

### Ambiente AWS (Produção)

```mermaid
graph TB
    subgraph "AWS Production"
        subgraph "Edge"
            PROD_CF[CloudFront CDN]
            PROD_S3[S3 Static Hosting]
        end
        
        subgraph "API Layer"
            PROD_APIGW[API Gateway]
            PROD_WAF[WAF]
        end
        
        subgraph "Compute"
            PROD_ALB[Application Load Balancer]
            PROD_ECS[ECS Fargate]
            PROD_BACKEND[Spring Boot Containers]
        end
        
        subgraph "Data"
            PROD_DYNAMO[DynamoDB]
            PROD_SECRETS[Secrets Manager]
            PROD_PARAM[Parameter Store]
        end
        
        subgraph "Monitoring"
            PROD_CW[CloudWatch]
            PROD_XRAY[X-Ray]
        end
    end
    
    PROD_CF --> PROD_S3
    PROD_CF --> PROD_APIGW
    PROD_APIGW --> PROD_WAF
    PROD_WAF --> PROD_ALB
    PROD_ALB --> PROD_ECS
    PROD_ECS --> PROD_BACKEND
    PROD_BACKEND --> PROD_DYNAMO
    PROD_BACKEND --> PROD_SECRETS
    PROD_BACKEND --> PROD_PARAM
    PROD_BACKEND --> PROD_CW
    PROD_BACKEND --> PROD_XRAY
    
    style PROD_CF fill:#ff9900
    style PROD_APIGW fill:#ff9900
    style PROD_BACKEND fill:#6db33f
```

## 🔄 Integração com APIs Externas

```mermaid
sequenceDiagram
    participant Backend as Spring Boot
    participant Secrets as Secrets Manager
    participant OAuth as OAuth Provider
    participant ExtAPI as External API
    participant Cache as Token Cache

    Backend->>Cache: Check cached token
    alt Token válido em cache
        Cache-->>Backend: Return cached token
    else Token expirado ou não existe
        Backend->>Secrets: Get credentials
        Secrets-->>Backend: {clientId, clientSecret}
        Backend->>OAuth: POST /oauth/token
        OAuth-->>Backend: {access_token, expires_in}
        Backend->>Cache: Store token
    end
    
    Backend->>ExtAPI: HTTP Request + Bearer token
    ExtAPI-->>Backend: HTTP Response
    
    alt Token expirado (401)
        Backend->>Cache: Invalidate token
        Backend->>OAuth: Request new token
        OAuth-->>Backend: New access_token
        Backend->>Cache: Store new token
        Backend->>ExtAPI: Retry request
        ExtAPI-->>Backend: HTTP Response
    end
```

## 📈 Métricas e Monitoramento

### CloudWatch Dashboards

```
┌─────────────────────────────────────────────────────────────┐
│ API Generic Consumer - Production Dashboard                 │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│ 📊 API Gateway Metrics                                      │
│   • Requests/min: 1,250                                     │
│   • 4XX Errors: 2.1%                                        │
│   • 5XX Errors: 0.3%                                        │
│   • Latency P50: 180ms | P95: 450ms | P99: 850ms          │
│                                                              │
│ 🔧 Backend Metrics                                          │
│   • Active Instances: 4                                     │
│   • CPU Utilization: 45%                                    │
│   • Memory Usage: 62%                                       │
│   • Request Duration: 320ms avg                             │
│                                                              │
│ 💾 DynamoDB Metrics                                         │
│   • Read Capacity: 125 RCU                                  │
│   • Write Capacity: 85 WCU                                  │
│   • Throttled Requests: 0                                   │
│   • Item Count: 1.2M                                        │
│                                                              │
│ 🌍 External API Metrics                                     │
│   • Success Rate: 98.7%                                     │
│   • Avg Response Time: 280ms                                │
│   • Timeout Rate: 0.5%                                      │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## 🚨 Alertas Configurados

| Alerta | Condição | Ação |
|--------|----------|------|
| **High Error Rate** | 5XX > 5% por 5 min | SNS → Email + Slack |
| **High Latency** | P95 > 2s por 5 min | SNS → Email |
| **DynamoDB Throttling** | Throttled > 10 por min | SNS → Email |
| **Backend Unhealthy** | Health check fail > 3 | Auto-scaling + SNS |
| **External API Down** | Failures > 50% por 2 min | SNS → PagerDuty |

## 🔒 Segurança

### Camadas de Segurança

```mermaid
graph TB
    subgraph "Security Layers"
        L1[1. WAF - Web Application Firewall]
        L2[2. API Gateway - Rate Limiting]
        L3[3. JWT Validation - Authentication]
        L4[4. Spring Security - Authorization]
        L5[5. Secrets Manager - Credentials]
        L6[6. VPC - Network Isolation]
        L7[7. Encryption - Data at Rest/Transit]
    end
    
    L1 --> L2
    L2 --> L3
    L3 --> L4
    L4 --> L5
    L5 --> L6
    L6 --> L7
    
    style L1 fill:#ff5252
    style L4 fill:#ff5252
    style L5 fill:#ff5252
```

### Práticas de Segurança Implementadas

1. **HTTPS Everywhere**: Todas as comunicações via TLS 1.2+
2. **Token-based Auth**: JWT com Azure AD ou Admin tokens
3. **Secrets Management**: Credenciais em AWS Secrets Manager
4. **Rate Limiting**: Proteção contra DDoS
5. **Input Validation**: Validação de todos os inputs
6. **CORS**: Configuração restritiva de origens permitidas
7. **Audit Logging**: Registro de todas as operações
8. **Encryption**: Dados em repouso e em trânsito criptografados

## 📚 Documentação Adicional

- [Backend Architecture](../api-generic-consumer-backend/docs/ARCHITECTURE.md)
- [Backend Logging Guide](../api-generic-consumer-backend/docs/LOGGING.md)
- [Integrated Testing Guide](./README-INTEGRATED-TEST.md)
- [API Documentation](../api-generic-consumer-backend/docs/API.md)

## 🚀 Quick Start

### Desenvolvimento Local
```bash
# Frontend
cd api-generic-consumer-frontend
npm install
npm run dev

# Backend
cd api-generic-consumer-backend
./gradlew bootRun

# Testes Integrados
cd api-generic-consumer-frontend
./start-integrated-test.bat  # Windows
./start-integrated-test.sh   # Linux/Mac
```

### Deploy AWS
```bash
# Frontend (S3 + CloudFront)
npm run build
aws s3 sync out/ s3://your-bucket/
aws cloudfront create-invalidation --distribution-id XXX --paths "/*"

# Backend (ECS)
docker build -t api-consumer-backend .
docker tag api-consumer-backend:latest ECR_URI:latest
docker push ECR_URI:latest
aws ecs update-service --cluster prod --service api-consumer --force-new-deployment
```

---

**Última atualização**: 2026-05-07  
**Versão**: 1.0.0  
**Autor**: Equipe de Desenvolvimento