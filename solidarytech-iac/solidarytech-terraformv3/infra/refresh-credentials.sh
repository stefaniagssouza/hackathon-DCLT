#!/bin/bash
set -e

NAMESPACE="velero"

echo "==> Coletando credenciais AWS das variáveis de ambiente..."

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  echo "ERRO: variável AWS_ACCESS_KEY_ID não encontrada."
  exit 1
fi

echo "==> Atualizando Secret no Kubernetes..."
kubectl create secret generic velero-aws-credentials \
  --namespace ${NAMESPACE} \
  --from-literal=cloud="[default]
aws_access_key_id=${AWS_ACCESS_KEY_ID}
aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}
aws_session_token=${AWS_SESSION_TOKEN}" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "==> Reiniciando pod do Velero para carregar novas credenciais..."
kubectl rollout restart deployment/velero -n ${NAMESPACE}
kubectl rollout status deployment/velero -n ${NAMESPACE} --timeout=60s

echo ""
echo "✅ Credenciais atualizadas com sucesso!"
echo ""
echo "Verifique o status com:"
echo "  velero backup-location get"