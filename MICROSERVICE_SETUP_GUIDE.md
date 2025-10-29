# Guia de Setup para Microserviços com MicroK8s e CI/CD

Este guia detalha o processo completo para configurar um ambiente de produção para um microserviço Java/Spring Boot, utilizando MicroK8s em uma VPS e uma pipeline de CI/CD com GitHub Actions.

## Pré-requisitos

1.  **VPS Limpa:** Uma máquina virtual (VPS) com Ubuntu 22.04 LTS ou superior.
2.  **Repositório GitHub:** Um repositório para o seu microserviço.
3.  **Personal Access Token (PAT) do GitHub:** Um token com permissões de `read:packages` e `write:packages`. Este será o valor do segredo `GHCR_TOKEN`.

---

## Passo 1: Configuração do Ambiente na VPS

Acesse sua VPS via SSH e execute os scripts de setup na ordem correta. Eles são idempotentes, então podem ser executados novamente sem causar problemas.

### 1.1. Clonar o Repositório
Primeiro, clone o repositório do seu serviço na VPS.

```bash
git clone <URL_DO_SEU_REPOSITORIO>
cd <NOME_DO_SEU_REPOSITORIO>
```

### 1.2. Conceder Permissão de Execução
Conceda permissão de execução a todos os scripts de uma vez.

```bash
chmod +x scripts/*.sh
```

### 1.3. Executar Scripts de Instalação
Execute os scripts na sequência numérica.

```bash
# 1. Instala pré-requisitos como Docker e Git
./scripts/01-install-prereqs.sh
# IMPORTANTE: Após este script, faça logout e login novamente na VPS para aplicar as permissões do Docker.

# 2. Instala o MicroK8s
./scripts/02-install-microk8s.sh
# IMPORTANTE: Após este script, faça logout e login novamente para aplicar as permissões do MicroK8s.

# 3. Habilita add-ons do MicroK8s e configura credenciais do Docker Hub (opcional)
./scripts/03-configure-microk8s-addons-auth.sh

# 4. Instala o Kafka via Strimzi Operator
./scripts/04-deploy-kafka-strimzi.sh

# 5. Instala o PostgreSQL e o ConfigMap da aplicação
# Você será solicitado a criar uma senha para o banco de dados.
./scripts/05-deploy-postgres-and-app-config.sh

# 6. Cria o segredo para o Kubernetes puxar imagens do GHCR
# Você será solicitado a fornecer seu usuário GitHub e o PAT.
./scripts/06-configure-ghcr-secret.sh
```

Ao final deste passo, seu ambiente na VPS está **completamente configurado** e pronto para receber deploys.

---

## Passo 2: Configuração dos Segredos no GitHub Actions

A pipeline precisa de dois segredos para funcionar. Vá para o seu repositório no GitHub, em `Settings` > `Secrets and variables` > `Actions` e crie os seguintes "Repository secrets":

### 2.1. `GHCR_TOKEN`
*   **Nome:** `GHCR_TOKEN`
*   **Valor:** Cole o seu Personal Access Token do GitHub (o mesmo que você usou no script `06`).

### 2.2. `KUBE_CONFIG_B64`
*   **Nome:** `KUBE_CONFIG_B64`
*   **Valor:** Na sua VPS, execute o comando abaixo. Ele gera a configuração de acesso ao cluster e a codifica em Base64, que é um formato seguro para ser transportado.
    ```bash
    sudo microk8s config | base64 -w 0
    ```
*   Copie a longa string resultante e cole-a como o valor deste segredo.

---

## Passo 3: Entendendo e Adaptando a Pipeline

O arquivo `.github/workflows/main-pipeline.yml` está pronto para uso, mas aqui estão os pontos-chave para adaptar para outro microserviço:

*   **`env.IMAGE_NAME`:** A pipeline usa `github.repository` (ex: `seu-usuario/seu-repo`) como o nome da imagem. Isso geralmente não precisa ser alterado.
*   **Nomes de Serviços/Deployments:** Se o seu novo microserviço não se chama `student-service`, você precisará atualizar os nomes nos seguintes locais:
    *   Nos seus arquivos Kubernetes em `k8s/` (ex: `deployment.yaml`, `service.yaml`).
    *   Nos comandos `kubectl` dentro da pipeline. Por exemplo, em `rollout-update`, a linha `sudo microk8s.kubectl set image deployment/student-service ...` precisaria ser alterada para `sudo microk8s.kubectl set image deployment/meu-novo-servico ...`.

Com os segredos configurados, qualquer `push` na branch `main` irá automaticamente acionar a pipeline e fazer o deploy da nova versão do seu microserviço.
