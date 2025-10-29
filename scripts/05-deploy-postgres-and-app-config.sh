#!/bin/bash
#
# Script 05: Instala Postgres e Configurações da Aplicação
# Idempotente: Verifica segredo, usa 'kubectl apply' para o resto.
#

set -e

echo "--- [Script 05] Iniciando deploy/verificação do Postgres e Configs da App ---"
echo "(Este script pode ser executado várias vezes sem problemas)"

APP_NAMESPACE="default" # Assumindo que App e Postgres rodam no namespace 'default'
DB_NAME="distrischool_students" # Nome do banco de dados a ser usado

# --- Segredo do Postgres ---
POSTGRES_SECRET_NAME="postgres-secret"
POSTGRES_USER="postgres"

echo ""
echo "--> Etapa 1/5: Criando/Verificando segredo '$POSTGRES_SECRET_NAME'..."
# Apenas cria o segredo se ele não existir para evitar sobrescrever uma senha existente.
if ! sudo microk8s kubectl get secret "$POSTGRES_SECRET_NAME" -n "$APP_NAMESPACE" > /dev/null 2>&1; then
    echo "   O segredo do Postgres não foi encontrado."
    read -s -p "   Digite a senha que deseja usar para o usuário '$POSTGRES_USER' do banco de dados: " POSTGRES_PASSWORD
    echo
    if [ -z "$POSTGRES_PASSWORD" ]; then
      echo "   ERRO: A senha não pode ser vazia."
      exit 1
    fi

    echo "   Criando segredo '$POSTGRES_SECRET_NAME'..."
    sudo microk8s kubectl create secret generic "$POSTGRES_SECRET_NAME" \
      --from-literal=POSTGRES_USER="$POSTGRES_USER" \
      --from-literal=POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
      -n "$APP_NAMESPACE"
    echo "   ✅ Segredo '$POSTGRES_SECRET_NAME' criado."
else
    echo "   ✅ Segredo '$POSTGRES_SECRET_NAME' já existe. (Passei reto)"
fi

# --- ConfigMap da Aplicação ---
echo ""
echo "--> Etapa 2/5: Aplicando/Verificando ConfigMap 'student-service-config'..."
# Referência correta ao serviço Kafka do Strimzi: <cluster-name>-kafka-bootstrap.<namespace>.svc:<port>
KAFKA_STRIMZI_URL="my-cluster-kafka-bootstrap.kafka.svc:9092"

# 'apply' é idempotente
cat <<EOF | sudo microk8s kubectl apply -n "$APP_NAMESPACE" -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: student-service-config #
data:
  SPRING_PROFILES_ACTIVE: "prod"
  LOGGING_LEVEL_ROOT: "INFO"
  # URL do Postgres dentro do cluster (usando FQDN para robustez)
  DB_URL: "jdbc:postgresql://postgres-service.${APP_NAMESPACE}.svc:5432/${DB_NAME}" # (Ajustado para FQDN e variável DB_NAME)
  # URL do Kafka (Strimzi) dentro do cluster (usando FQDN)
  KAFKA_BOOTSTRAP_SERVERS: "${KAFKA_STRIMZI_URL}" # (Ajustado para Strimzi FQDN)
EOF
echo "   ✅ ConfigMap 'student-service-config' aplicado/verificado."

# --- Deploy do Postgres ---
echo ""
echo "--> Etapa 3/5: Aplicando/Verificando PVC do Postgres 'postgres-pvc'..."
# 'apply' é idempotente
cat <<EOF | sudo microk8s kubectl apply -n "$APP_NAMESPACE" -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc #
spec:
  storageClassName: microk8s-hostpath # (Corrigido)
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi #
EOF
echo "   ✅ PVC 'postgres-pvc' aplicado/verificado."

echo ""
echo "--> Etapa 4/5: Aplicando/Verificando Serviço do Postgres 'postgres-service'..."
# 'apply' é idempotente
cat <<EOF | sudo microk8s kubectl apply -n "$APP_NAMESPACE" -f -
apiVersion: v1
kind: Service
metadata:
  name: postgres-service #
spec:
  type: ClusterIP
  ports:
  - port: 5432
    targetPort: 5432
  selector:
    app: postgres #
EOF
echo "   ✅ Serviço 'postgres-service' aplicado/verificado."

echo ""
echo "--> Etapa 5/5: Aplicando/Verificando StatefulSet do Postgres 'postgres'..."
# 'apply' é idempotente
cat <<EOF | sudo microk8s kubectl apply -n "$APP_NAMESPACE" -f -
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres #
spec:
  serviceName: "postgres-service"
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres #
    spec:
      containers:
      - name: postgres
        image: postgres:15-alpine #
        ports:
        - containerPort: 5432 #
        envFrom:
        - secretRef:
            name: ${POSTGRES_SECRET_NAME} #
        volumeMounts:
        - name: postgres-data
          mountPath: /var/lib/postgresql/data #
      volumes:
      - name: postgres-data
        persistentVolumeClaim:
          claimName: postgres-pvc #
EOF
echo "   Aguardando Postgres ficar pronto..."
# Espera o statefulset estar pronto (será rápido se já estiver rodando)
sudo microk8s kubectl wait statefulset -n "$APP_NAMESPACE" postgres --for condition=Ready --timeout=5m
echo "   ✅ Postgres está pronto."

echo ""
echo "--- [Script 05] Postgres e Configs da App verificados/instalados! ---"