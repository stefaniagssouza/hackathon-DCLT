#!/bin/bash
set -e

BUCKET_NAME="solidarytech-velero-914963610886"
REGION="us-east-1"
NAMESPACE="velero"

echo "==> Coletando credenciais AWS das variáveis de ambiente..."

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  echo "ERRO: variável AWS_ACCESS_KEY_ID não encontrada."
  exit 1
fi

echo "==> Limpando instalação anterior (se existir)..."
helm uninstall velero -n velero 2>/dev/null || true
kubectl delete job -n velero --all 2>/dev/null || true
kubectl delete namespace velero 2>/dev/null || true
kubectl wait --for=delete namespace/velero --timeout=60s 2>/dev/null || true

echo "==> Adicionando repositório Helm do Velero..."
helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts
helm repo update

echo "==> Criando namespace ${NAMESPACE}..."
kubectl create namespace ${NAMESPACE}

echo "==> Criando Secret com credenciais AWS..."
kubectl create secret generic velero-aws-credentials \
  --namespace ${NAMESPACE} \
  --from-literal=cloud="[default]
aws_access_key_id=${AWS_ACCESS_KEY_ID}
aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}
aws_session_token=${AWS_SESSION_TOKEN}"

echo "==> Gerando values.yaml..."
cat <<YAML > /tmp/velero-values.yaml
configuration:
  backupStorageLocation:
    - name: aws-s3
      provider: aws
      bucket: ${BUCKET_NAME}
      config:
        region: ${REGION}
  volumeSnapshotLocation:
    - name: aws-ebs
      provider: aws
      config:
        region: ${REGION}

credentials:
  useSecret: true
  existingSecret: velero-aws-credentials

initContainers:
  - name: velero-plugin-for-aws
    image: velero/velero-plugin-for-aws:v1.9.0
    volumeMounts:
      - mountPath: /target
        name: plugins

deployNodeAgent: true
YAML

echo "==> Instalando Velero via Helm..."
helm upgrade --install velero vmware-tanzu/velero \
  --namespace ${NAMESPACE} \
  --version 6.0.0 \
  --values /tmp/velero-values.yaml \
  --set upgradeCRDs=false \
  --set cleanUpCRDs=false \
  --set configuration.defaultBackupStorageLocation=aws-s3

echo "==> Aguardando Velero ficar pronto..."
kubectl rollout status deployment/velero -n ${NAMESPACE} --timeout=180s

echo ""
echo "✅ Velero instalado com sucesso!"
echo ""
echo "Verifique o status com:"
echo "  kubectl get pods -n velero"
echo "  velero backup-location get"
