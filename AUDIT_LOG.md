# Log de Auditoria de Modificações - 29/10/2025

Este documento registra as mudanças significativas realizadas no projeto `ds6-student-service` para corrigir problemas de deploy e alinhar a configuração com as melhores práticas de ambientes conteinerizados (Kubernetes).

## Sumário das Modificações

1.  **Infraestrutura como Código (Kubernetes YAMLs):**
    *   Corrigido um erro fatal de parsing no `deployment.yaml`.
    *   Padronizados os nomes dos recursos (`student-service`, `student-service-config`, etc.) para consistência.
    *   Melhorada a robustez do `service.yaml` ao referenciar portas por nome (`http`).

2.  **Configuração da Aplicação (Spring Boot):**
    *   Externalizadas as configurações de banco de dados e mensageria (Kafka), removendo endereços `localhost` fixos.
    *   A aplicação agora lê essas configurações de variáveis de ambiente, tornando-a portátil.
    *   Resolvido o conflito de gerenciamento de schema entre Hibernate (`ddl-auto`) e Flyway.

3.  **Pipeline de CI/CD (GitHub Actions):**
    *   Corrigido o comando `sed` no workflow que estava corrompendo o `deployment.yaml` durante o deploy.
    *   Ajustado o comando `rollout status` para usar o novo nome padronizado do deployment.

## Detalhes por Arquivo

### 1. `.github/workflows/main-pipeline.yml`

*   **Alteração Crítica:** O comando de substituição da imagem foi corrigido.
    *   **Antes:** `sed -i "s|image:.*|$NEW_IMAGE|g"`
    *   **Depois:** `sed -i "s|image: .*|image: $NEW_IMAGE|g"`
*   **Motivo:** A versão anterior removia a chave `image:`, causando um erro de parsing de YAML no `kubectl`. A nova versão preserva a chave, corrigindo o deploy.
*   **Outra Alteração:** O comando `rollout status` foi atualizado para `deployment/student-service`.

### 2. `src/main/resources/application.properties`

*   **Alteração:** Endereços de banco de dados e Kafka foram substituídos por placeholders de variáveis de ambiente.
    *   `spring.datasource.url=jdbc:postgresql://localhost:5432/...` -> `spring.datasource.url=${DB_URL}`
    *   `spring.kafka.producer.bootstrap-servers=localhost:9092` -> `spring.kafka.producer.bootstrap-servers=${KAFKA_BOOTSTRAP_SERVERS}`
*   **Alteração:** `spring.jpa.hibernate.ddl-auto` foi alterado de `update` para `validate`.
*   **Motivo:** Preparar a aplicação para rodar em qualquer ambiente, lendo a configuração externamente e evitando conflitos entre Hibernate e Flyway.

### 3. `k8s/configmap.yaml`

*   **Alteração:** O ConfigMap foi atualizado para fornecer os valores reais para as novas variáveis de ambiente (`DB_URL`, `KAFKA_BOOTSTRAP_SERVERS`, etc.).
*   **Motivo:** Centralizar a configuração do ambiente de produção em um único lugar, seguindo as melhores práticas do Kubernetes.
*   **Detalhe Técnico:** Utilizado o endereço `172.17.0.1` para se referir à máquina host (VPS) de dentro do contêiner.

### 4. `k8s/deployment.yaml`

*   **Alteração:** Nomes de recursos (`metadata.name`, `container.name`) foram padronizados para `student-service` e `student-service-container`.
*   **Alteração:** A porta do contêiner recebeu um nome: `name: http`.
*   **Alteração:** As `livenessProbe` e `readinessProbe` foram atualizadas para usar `port: http`.
*   **Alteração:** A referência a `secretRef` foi removida para evitar erros de deploy, pois nenhum Secret foi definido.
*   **Motivo:** Melhorar a legibilidade, consistência e robustez da definição do deployment.

### 5. `k8s/service.yaml`

*   **Alteração:** O `metadata.name` foi padronizado.
*   **Alteração:** O `targetPort` foi alterado para `http`.
*   **Motivo:** Desacoplar o Service da porta numérica do contêiner, tornando a configuração mais resiliente a futuras mudanças.
