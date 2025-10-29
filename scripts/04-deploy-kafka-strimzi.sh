#!/bin/bash
#
# Script 04: Instala o Kafka via Strimzi Operator
# Idempotente: Usa 'kubectl get || create' para namespace e 'kubectl apply' para os recursos.
#

set -e

echo "--- [Script 04] Iniciando deploy/verificação do Kafka via Strimzi ---"
echo "(Este script pode ser executado várias vezes sem problemas)"

KAFKA_NAMESPACE="kafka"
STRIMZI_VERSION="0.42.0" # Use a versão mais recente que testamos

echo ""
echo "--> Etapa 1/4: Garantindo namespace '$KAFKA_NAMESPACE'..."
if ! sudo microk8s kubectl get namespace "$KAFKA_NAMESPACE" > /dev/null 2>&1; then
  echo "   Criando namespace '$KAFKA_NAMESPACE'..."
  sudo microk8s kubectl create namespace "$KAFKA_NAMESPACE"
  echo "   ✅ Namespace '$KAFKA_NAMESPACE' criado."
else
    echo "   ✅ Namespace '$KAFKA_NAMESPACE' já existe. (Passei reto)"
fi

echo ""
echo "--> Etapa 2/4: Aplicando/Verificando Strimzi Operator (Versão $STRIMZI_VERSION)..."
# 'apply' já é idempotente. Ele criará ou atualizará o operador se necessário.
sudo microk8s kubectl apply -f "https://github.com/strimzi/strimzi-kafka-operator/releases/download/${STRIMZI_VERSION}/strimzi-cluster-operator-${STRIMZI_VERSION}.yaml" -n "$KAFKA_NAMESPACE"
echo "   Aguardando Strimzi Operator ficar pronto..."
# Espera o deployment do operador estar disponível e pronto
sudo microk8s kubectl wait deployment -n "$KAFKA_NAMESPACE" strimzi-cluster-operator --for condition=Available --timeout=5m
echo "   ✅ Strimzi Operator está pronto."

echo ""
echo "--> Etapa 3/4: Aplicando/Verificando definição do Cluster Kafka (my-cluster)..."
# Usamos um Here Document para criar o arquivo YAML dinamicamente
# 'apply' também é idempotente para o recurso Kafka.
cat <<EOF | sudo microk8s kubectl apply -n "$KAFKA_NAMESPACE" -f -
apiVersion: kafka.strimzi.io/v1beta2
kind: Kafka
metadata:
  name: my-cluster
spec:
  kafka:
    version: 3.7.0
    replicas: 1
    listeners:
      - name: plain
        port: 9092
        type: internal
        tls: false
    storage:
      type: jbod
      volumes:
      - id: 0
        type: persistent-claim
        class: microk8s-hostpath # StorageClass correta
        size: 5Gi
        deleteClaim: false
  zookeeper:
    replicas: 1
    storage:
      type: persistent-claim
      class: microk8s-hostpath # StorageClass correta
      size: 5Gi
      deleteClaim: false
EOF
echo "   ✅ Definição do Cluster Kafka aplicada/verificada."

echo ""
echo "--> Etapa 4/4: Aguardando Cluster Kafka 'my-cluster' ficar pronto..."
# Espera o recurso Kafka 'my-cluster' atingir a condição 'Ready'
# Isso pode levar vários minutos na primeira vez. Em execuções futuras, será rápido.
sudo microk8s kubectl wait kafka -n "$KAFKA_NAMESPACE" my-cluster --for condition=Ready --timeout=15m # Aumentado timeout
echo "   ✅ Cluster Kafka 'my-cluster' está pronto."

echo ""
echo "--- [Script 04] Kafka (via Strimzi) verificado/instalado e pronto! ---"