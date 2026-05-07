# Guia de Troubleshooting - API Generic Consumer

## 🔧 Problemas Comuns e Soluções

### 1. Docker Desktop Não Conecta ao Engine

#### Erro
```
error during connect: Get "http://%2F%2F.%2Fpipe%2FdockerDesktopLinuxEngine/v1.51/...":
open //./pipe/dockerDesktopLinuxEngine: The system cannot find the file specified.

Client:
 Version:           28.5.1
 ...
error during connect: Get "http://%2F%2F.%2Fpipe%2FdockerDesktopLinuxEngine/v1.51/version":
open //./pipe/dockerDesktopLinuxEngine: The system cannot find the file specified.
```

#### Causa
O Docker Client está instalado mas não consegue se conectar ao Docker Engine. Isso geralmente acontece quando:
- Docker Desktop não terminou de inicializar completamente
- Docker Engine travou ou está em estado inconsistente
- Serviço do Docker Desktop não está rodando

#### Solução Completa

**Passo 1: Reiniciar Docker Desktop Completamente**
1. Clique com botão direito no ícone da baleia na bandeja do sistema (system tray)
2. Selecione "Quit Docker Desktop"
3. Aguarde 10-15 segundos
4. Abra Docker Desktop novamente (menu Iniciar)
5. Aguarde até o ícone da baleia ficar estável (não animado)
6. Clique no ícone e verifique se mostra "Docker Desktop is running"

**Passo 2: Verificar se está funcionando**
```bash
docker info
```

Se ainda mostrar erro, continue para o Passo 3.

**Passo 3: Verificar Serviços do Windows**
1. Pressione `Win + R`
2. Digite `services.msc` e pressione Enter
3. Procure por "Docker Desktop Service"
4. Se estiver parado, clique com botão direito e selecione "Iniciar"
5. Procure também por "com.docker.service"
6. Certifique-se que ambos estão "Em execução"

**Passo 4: Reiniciar Computador**
Se os passos anteriores não funcionarem:
1. Feche Docker Desktop completamente
2. Reinicie o computador
3. Após reiniciar, abra Docker Desktop
4. Aguarde inicialização completa
5. Teste: `docker info`

**Passo 5: Reinstalar Docker Desktop (último recurso)**
1. Desinstale Docker Desktop:
   - Painel de Controle → Programas → Desinstalar
2. Reinicie o computador
3. Baixe a versão mais recente: https://www.docker.com/products/docker-desktop
4. Instale seguindo as instruções
5. Reinicie novamente se solicitado
6. Abra Docker Desktop e aguarde inicialização

**Passo 6: Verificar WSL2 (Windows)**
Docker Desktop no Windows usa WSL2. Verifique se está configurado:
```bash
# Verificar versão do WSL
wsl --list --verbose

# Atualizar WSL se necessário
wsl --update

# Definir WSL2 como padrão
wsl --set-default-version 2
```

**Se Docker Desktop não estiver instalado:**
1. Baixe em: https://www.docker.com/products/docker-desktop
2. Instale seguindo as instruções
3. Reinicie o computador se solicitado
4. Inicie o Docker Desktop
5. Aguarde a inicialização completa

**Linux:**
```bash
# Verificar status do Docker
sudo systemctl status docker

# Iniciar Docker se não estiver rodando
sudo systemctl start docker

# Habilitar Docker para iniciar automaticamente
sudo systemctl enable docker
```

**Mac:**
1. Abra Docker Desktop da pasta Applications
2. Aguarde o ícone da baleia aparecer na barra de menu
3. Clique no ícone e verifique se mostra "Docker Desktop is running"

---

### 2. Portas Já Estão em Uso

#### Erro
```
Error starting userland proxy: listen tcp4 0.0.0.0:3000: bind: address already in use
Error starting userland proxy: listen tcp4 0.0.0.0:8080: bind: address already in use
```

#### Causa
Outro processo está usando as portas 3000, 8080 ou 4566.

#### Solução

**Windows:**
```bash
# Verificar qual processo está usando a porta
netstat -aon | findstr :3000
netstat -aon | findstr :8080
netstat -aon | findstr :4566

# Matar o processo (substitua PID pelo número encontrado)
taskkill /f /pid PID
```

**Linux/Mac:**
```bash
# Verificar qual processo está usando a porta
lsof -i :3000
lsof -i :8080
lsof -i :4566

# Matar o processo
kill -9 PID
```

**Ou use o script de parada:**
```bash
# Windows
cd api-generic-consumer-frontend
stop-integrated-test.bat

# Linux/Mac
cd api-generic-consumer-frontend
./stop-integrated-test.sh
```

---

### 3. Node Modules Não Encontrados

#### Erro
```
Error: Cannot find module 'next'
Module not found: Can't resolve 'react'
```

#### Causa
Dependências do Node.js não foram instaladas.

#### Solução
```bash
cd api-generic-consumer-frontend
rm -rf node_modules package-lock.json  # Limpar instalação anterior
npm install                             # Reinstalar dependências
```

---

### 4. Java Não Encontrado

#### Erro
```
ERROR: Java not found. Please install Java 21+.
```

#### Causa
Java não está instalado ou não está no PATH.

#### Solução

**Windows:**
1. Baixe Java 21+ de: https://adoptium.net/
2. Instale seguindo as instruções
3. Adicione ao PATH:
   - Painel de Controle → Sistema → Configurações Avançadas
   - Variáveis de Ambiente
   - Adicione `C:\Program Files\Eclipse Adoptium\jdk-21.x.x\bin` ao PATH
4. Abra um novo terminal e verifique:
   ```bash
   java -version
   ```

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install openjdk-21-jdk
java -version
```

**Mac:**
```bash
brew install openjdk@21
java -version
```

---

### 5. LocalStack Não Inicia

#### Erro
```
ERROR: Timeout waiting for LocalStack (60s)
LocalStack container is not running
```

#### Causa
LocalStack demorou muito para iniciar ou falhou ao iniciar.

#### Solução

**1. Verificar logs do LocalStack:**
```bash
cd api-generic-consumer-frontend
docker-compose -f docker-compose.integrated.yml logs localstack
```

**2. Aumentar memória do Docker:**
- Docker Desktop → Settings → Resources
- Aumentar Memory para pelo menos 4GB
- Aplicar e reiniciar

**3. Limpar containers antigos:**
```bash
docker-compose -f docker-compose.integrated.yml down -v
docker system prune -a
```

**4. Tentar iniciar manualmente:**
```bash
cd api-generic-consumer-frontend
docker-compose -f docker-compose.integrated.yml up localstack
```

---

### 6. Backend Não Conecta ao LocalStack

#### Erro
```
Unable to execute HTTP request: Connect to localhost:4566 failed
```

#### Causa
Backend tentando conectar ao LocalStack antes dele estar pronto.

#### Solução

**1. Aguardar mais tempo:**
O script já aguarda, mas pode precisar de mais tempo em máquinas lentas.

**2. Verificar se LocalStack está rodando:**
```bash
curl http://localhost:4566/_localstack/health
```

**3. Verificar variáveis de ambiente:**
```bash
# No backend, verificar se está configurado corretamente
AWS_DYNAMODB_ENDPOINT=http://localhost:4566
```

---

### 7. Erro de Permissão em Scripts .sh

#### Erro
```
Permission denied: ./start-integrated-test.sh
```

#### Causa
Script não tem permissão de execução.

#### Solução
```bash
chmod +x start-integrated-test.sh
chmod +x stop-integrated-test.sh
./start-integrated-test.sh
```

---

### 8. Frontend Não Carrega

#### Erro
```
Error: EADDRINUSE: address already in use :::3000
```

#### Causa
Porta 3000 já está em uso.

#### Solução

**Opção 1: Matar processo na porta 3000**
```bash
# Windows
netstat -aon | findstr :3000
taskkill /f /pid PID

# Linux/Mac
lsof -i :3000
kill -9 PID
```

**Opção 2: Usar outra porta**
```bash
# Editar package.json
"dev": "next dev -p 3001"
```

---

### 9. Erro ao Criar Tabela DynamoDB

#### Erro
```
ResourceInUseException: Table already exists: audit-logs
```

#### Causa
Tabela já existe de execução anterior.

#### Solução

**Não é um erro crítico**, o script continua normalmente. Mas se quiser limpar:

```bash
# Deletar tabela existente
aws dynamodb delete-table \
    --table-name audit-logs \
    --endpoint-url http://localhost:4566 \
    --region us-east-1

# Recriar
aws dynamodb create-table \
    --table-name audit-logs \
    --attribute-definitions AttributeName=changeNumber,AttributeType=S AttributeName=timestamp,AttributeType=S \
    --key-schema AttributeName=changeNumber,KeyType=HASH AttributeName=timestamp,KeyType=RANGE \
    --billing-mode PAY_PER_REQUEST \
    --endpoint-url http://localhost:4566 \
    --region us-east-1
```

---

### 10. Gradle Build Falha

#### Erro
```
FAILURE: Build failed with an exception.
Could not resolve all dependencies
```

#### Causa
Dependências do Gradle não foram baixadas ou há problema de rede.

#### Solução

**1. Limpar cache do Gradle:**
```bash
cd api-generic-consumer-backend
./gradlew clean
./gradlew build --refresh-dependencies
```

**2. Verificar conexão com internet:**
Gradle precisa baixar dependências do Maven Central.

**3. Configurar proxy (se necessário):**
```bash
# gradle.properties
systemProp.http.proxyHost=proxy.company.com
systemProp.http.proxyPort=8080
systemProp.https.proxyHost=proxy.company.com
systemProp.https.proxyPort=8080
```

---

## 🔍 Comandos Úteis para Diagnóstico

### Verificar Status dos Serviços

```bash
# Docker
docker ps                                    # Containers rodando
docker-compose -f docker-compose.integrated.yml ps  # Status do compose

# Portas
netstat -an | findstr "3000 8080 4566"      # Windows
lsof -i :3000 -i :8080 -i :4566             # Linux/Mac

# Logs
docker-compose -f docker-compose.integrated.yml logs -f localstack
docker-compose -f docker-compose.integrated.yml logs -f backend
tail -f frontend.log                         # Linux/Mac
type frontend.log                            # Windows
```

### Health Checks

```bash
# LocalStack
curl http://localhost:4566/_localstack/health

# Backend
curl http://localhost:8080/actuator/health

# Frontend
curl http://localhost:3000
```

### Limpar Ambiente Completamente

```bash
# Parar tudo
cd api-generic-consumer-frontend
./stop-integrated-test.bat  # Windows
./stop-integrated-test.sh   # Linux/Mac

# Limpar Docker
docker-compose -f docker-compose.integrated.yml down -v
docker system prune -a

# Limpar Node modules
cd api-generic-consumer-frontend
rm -rf node_modules package-lock.json .next

# Limpar Gradle
cd ../api-generic-consumer-backend
./gradlew clean
rm -rf .gradle build
```

---

## 📞 Suporte Adicional

### Logs Detalhados

Para obter logs mais detalhados, execute:

```bash
# Backend com debug
cd api-generic-consumer-backend
SPRING_PROFILES_ACTIVE=debug ./gradlew bootRun

# Frontend com debug
cd api-generic-consumer-frontend
DEBUG=* npm run dev
```

### Reportar Problemas

Se o problema persistir, colete as seguintes informações:

1. **Sistema Operacional e Versão**
   ```bash
   # Windows
   systeminfo | findstr /B /C:"OS Name" /C:"OS Version"
   
   # Linux
   uname -a
   cat /etc/os-release
   
   # Mac
   sw_vers
   ```

2. **Versões das Ferramentas**
   ```bash
   docker --version
   docker-compose --version
   node --version
   npm --version
   java -version
   ```

3. **Logs de Erro Completos**
   - Copie toda a saída do terminal
   - Inclua logs do Docker: `docker-compose logs`

4. **Configuração**
   - Conteúdo dos arquivos `.env.test` (sem senhas!)
   - Configuração do Docker Desktop (memória, CPU)

### Links Úteis

- [Docker Desktop Documentation](https://docs.docker.com/desktop/)
- [LocalStack Documentation](https://docs.localstack.cloud/)
- [Next.js Documentation](https://nextjs.org/docs)
- [Spring Boot Documentation](https://docs.spring.io/spring-boot/docs/current/reference/html/)

---

## ✅ Checklist de Verificação

Antes de executar os testes integrados, verifique:

- [ ] Docker Desktop está rodando
- [ ] Portas 3000, 8080 e 4566 estão livres
- [ ] Node.js 20+ está instalado
- [ ] Java 21+ está instalado
- [ ] Conexão com internet está funcionando
- [ ] Memória disponível: mínimo 4GB
- [ ] Espaço em disco: mínimo 10GB

---

**Última atualização**: 2026-05-07  
**Versão**: 1.0.0