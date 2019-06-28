#!/bin/bash

if [ $# -ne 3 ]; then
  echo "Usage: ${0} API_SERVER_URL CLUSTER_NAME USER_NAME"
  exit 1
fi

cd $(dirname ${0})

API_SERVER_URL=${1}
CLUSTER_NAME=${2}
USER_NAME=${3}

CERT_DIR="../certs"
DIST_DIR="../dist"

# generate user's work dir
echo "### generate user's work dir ###"
rm -rf ${DIST_DIR}/${USER_NAME}
mkdir ${DIST_DIR}/${USER_NAME}

# copy private key and crt file of user to work dir
echo "### copy private key and cert file of user to work dir ###"
for ext in "pem" "crt"; do
  cp ${CERT_DIR}/${USER_NAME}.${ext} ${DIST_DIR}/${USER_NAME}
done

# generate script file
echo "### generate script file ###"
cat << '__EOSA__' > ${DIST_DIR}/${USER_NAME}/configure_${USER_NAME}.sh
#!/bin/sh
cd `dirname ${0}`
__EOSA__
cat << __EOSB__ >> ${DIST_DIR}/${USER_NAME}/configure_${USER_NAME}.sh
kubectl config set-cluster ${CLUSTER_NAME} --insecure-skip-tls-verify=true --server=${API_SERVER_URL}
kubectl config set-credentials ${USER_NAME} --client-certificate=${USER_NAME}.crt --client-key=${USER_NAME}.pem --embed-certs=true
kubectl config set-context ${CLUSTER_NAME} --cluster=${CLUSTER_NAME} --user=${USER_NAME}
kubectl config set-context ${CLUSTER_NAME} --namespace=${USER_NAME}
kubectl config use-context ${CLUSTER_NAME}
__EOSB__

# freeze files
echo "### freeze files ###"
tar cvfz ${DIST_DIR}/${USER_NAME}.certs.tar.gz -C ${DIST_DIR} ./${USER_NAME}

# delte work dir
echo "### delete work dir"
rm -rf ${DIST_DIR}/${USER_NAME}
