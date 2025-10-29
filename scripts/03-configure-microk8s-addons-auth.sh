#!/bin/bash
#
# Script 03: Configura Add-ons Essenciais e Autenticação Docker Hub
# Idempotente: Verifica status dos addons, existência do segredo e patch na SA.
# REQUER INTERAÇÃO MANUAL PARA LOGIN NO DOCKER HUB.
#

set -e

echo "--- [Script 03] Configurando Add-ons e Autenticação ---"
echo "(Este script pode ser executado várias vezes sem problemas)"

echo ""
echo "--> Etapa 1/3: Garantindo que MicroK8s está pronto..."
sudo microk8s status --wait-ready

echo ""
echo "--> Etapa 2/3: Verificando/Habilitando Add-ons Essenciais e Recomendados..."
echo "   Atualizando repositório 'community' (para garantir a lista mais recente)..."
sudo microk8s disable community > /dev/null 2>&1 || true # Ignora erro se já desabilitado
sudo microk8s enable community

STATUS=$(sudo microk8s status) # Pega o status após habilitar community

enable_addon() {
    local addon_name=$1
    echo ""
    # Verifica se a linha exata do addon existe na seção 'enabled:'
    if echo "$STATUS" | awk '/addons:/{flag=1; next} /enabled:/{if(flag) eflag=1; next} /disabled:/{if(flag) eflag=0; next} {if(eflag) print}' | grep -qE "^\s+$addon_name\s"; then
        echo "   ✅ Add-on '$addon_name' já está HABILITADO. (Passei reto)"
    else
        echo "   ⏳ Habilitando add-on '$addon_name'..."
        sudo microk8s enable "$addon_name"
        echo "   ✅ Add-on '$addon_name' foi HABILITADO."
    fi
}

# Add-ons essenciais + recomendados
enable_addon "dns"
enable_addon "storage"
enable_addon "helm3"
enable_addon "ingress"
enable_addon "registry"
enable_addon "metrics-server"

echo ""
echo "--> Etapa 3/3: Configurando Autenticação Docker Hub..."
echo "   !!! AÇÃO MANUAL NECESSÁRIA !!!"
echo "   O comando 'sudo docker login' será executado."
echo "   Por favor, insira seu nome de usuário e senha do Docker Hub quando solicitado."
read -p "   Pressione Enter para continuar..."

# Tenta login (pode já estar logado)
if sudo docker login; then
    echo "   ✅ Login no Docker Hub bem-sucedido (ou já estava logado)."
else
    echo "   ❌ ERRO: Falha no login do Docker Hub. Abortando."
    exit 1
fi

# Cria o segredo (ignora erro se já existir)
echo "   Criando/Verificando segredo 'docker-hub-creds' no Kubernetes..."
if ! sudo microk8s kubectl get secret docker-hub-creds > /dev/null 2>&1; then
    sudo microk8s kubectl create secret generic docker-hub-creds \
      --from-file=.dockerconfigjson=/root/.docker/config.json \
      --type=kubernetes.io/dockerconfigjson
    echo "   ✅ Segredo 'docker-hub-creds' criado."
else
    echo "   ✅ Segredo 'docker-hub-creds' já existe. (Passei reto)"
fi

# Anexa o segredo à service account 'default' (ignora erro se já anexado)
echo "   Anexando/Verificando segredo na Service Account 'default'..."
# Verifica se o imagePullSecrets já contém o nome do nosso segredo
if sudo microk8s kubectl get serviceaccount default -o jsonpath='{.imagePullSecrets[*].name}' | grep -q "docker-hub-creds"; then
    echo "   ✅ Segredo já anexado à SA 'default'. (Passei reto)"
else
    # Usa patch --type=json para adicionar à lista existente sem sobrescrever outros segredos
    sudo microk8s kubectl patch serviceaccount default --type=json -p='[{"op": "add", "path": "/imagePullSecrets/-", "value": {"name": "docker-hub-creds"}}]'
    echo "   ✅ Segredo anexado à SA 'default'."
fi

# NOTA: Não anexamos à SA 'kafka' aqui porque ela é criada pelo Strimzi depois
# e usa imagens do quay.io que não precisam de login.

echo ""
echo "--- [Script 03] Add-ons e autenticação verificados/configurados! ---"