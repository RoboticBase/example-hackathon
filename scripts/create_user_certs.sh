#!/bin/bash
shopt -s expand_aliases

if [ $# -ne 1 ]; then
  echo "Usage: ${0} USER_NAME"
  exit 1
fi

cd $(dirname ${0})

if [ "$(uname)" == 'Darwin' ]; then
  alias b64decode='base64 --decode '
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
  alias b64decode='base64 -d '
else
  echo "Your platform ($(uname -a)) is not supported."
  exit 1
fi

USER_NAME=${1}

CERT_DIR="../certs"
K8S_DIR="../k8s"

# create private key
echo "### create private key & csr for ${USER_NAME} ###"
openssl genrsa -out ${CERT_DIR}/${USER_NAME}.pem 2048
openssl req -new -key ${CERT_DIR}/${USER_NAME}.pem -out ${CERT_DIR}/${USER_NAME}.csr -subj "/CN=${USER_NAME}"

# register csr to k8s
echo "### register csr of ${USER_NAME} to k8s ###"
CSR=$(cat ${CERT_DIR}/${USER_NAME}.csr | base64 | tr -d '\n')
USER_NAME=${USER_NAME} CSR=${CSR} envsubst < ${K8S_DIR}/user-request-csr.yaml | kubectl create -f -
kubectl describe csr user-request-${USER_NAME}

# approve csr
echo "### approve csr of ${USER_NAME} to k8s ###"
kubectl certificate approve user-request-${USER_NAME}
kubectl describe csr user-request-${USER_NAME}

# generate crt
echo "### generate cert file of ${USER_NAME} ###"
kubectl get csr user-request-${USER_NAME} -o jsonpath='{.status.certificate}' | b64decode > ${CERT_DIR}/${USER_NAME}.crt
