#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "--------------------------------------------------"
echo "Configurando o ImagePullSecret para o GitHub Container Registry (GHCR)..."
echo "Isso permitirá que o Kubernetes puxe as imagens privadas/públicas do seu repositório."
echo "--------------------------------------------------"

# Solicita o nome de usuário e o token de acesso do GitHub
# O token precisa ter a permissão 'read:packages'
read -p "Digite seu nome de usuário do GitHub: " GITHUB_USERNAME
read -s -p "Digite seu GitHub Personal Access Token (o mesmo do GHCR_TOKEN): " GITHUB_TOKEN
echo

# Validação básica
if [ -z "$GITHUB_USERNAME" ] || [ -z "$GITHUB_TOKEN" ]; then
  echo "Erro: Nome de usuário e Token não podem ser vazios."
  exit 1
fi

# Cria o segredo 'ghcr-secret' no namespace 'default'.
# Este segredo será usado pelo Deployment para puxar a imagem do GHCR.
# Usar 'dry-run' e 'apply' torna o comando idempotente: se o segredo já existir, ele será atualizado.
echo "Criando/Atualizando o segredo 'ghcr-secret' no namespace 'default'வுகளை"
sudo microk8s kubectl create secret docker-registry ghcr-secret \
  --namespace=default \
  --docker-server=ghcr.io \
  --docker-username="$GITHUB_USERNAME" \
  --docker-password="$GITHUB_TOKEN" \
  --dry-run=client -o yaml | sudo microk8s kubectl apply -f -

echo "--------------------------------------------------"
echo "Segredo 'ghcr-secret' configurado com sucesso!"
echo "Seu cluster agora pode puxar imagens do GHCR."
echo "--------------------------------------------------"
