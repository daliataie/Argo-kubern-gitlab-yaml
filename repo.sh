#!/bin/sh
set -x

echo "AWSCLI Installation"
apk add --no-cache git openssh-client python3 py3-pip && pip3 install --upgrade pip && pip3 install --no-cache-dir awscli && rm -rf /var/cache/apk/*
aws --version

IMAGE="938642921854.dkr.ecr.us-east-1.amazonaws.com/cloudgeeks-app"
BUCKET="s3://cloudgeeks-terraform"
GIT_REPO="git@github.com:quickbooks2018/argo-cd.git"

aws s3 cp $BUCKET/TAG .
TAG=$(cat TAG)


mkdir -p /root/.ssh
aws s3 cp $BUCKET/id_rsa .
mv id_rsa /root/.ssh/id_rsa
chmod 0400 /root/.ssh/id_rsa
whoami
ls
pwd
ls /root/.ssh
cat /root/.ssh/id_rsa echo "Cloning my Kubernetes Application k8 Manifests Repo"
ssh-keygen -F github.com || ssh-keyscan github.com > ~/.ssh/known_hosts
git clone $GIT_REPO
ls argo-cd

cat << EOF > argo-cd/dev/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cloudgeeks-app
  labels:
    app: cloudgeeks-app
    tier: frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cloudgeeks-app
  template:
    metadata:
      labels:
        app: cloudgeeks-app
        tier: frontend
    spec:
      containers:
        - name: cloudgeeks-app
          image: $IMAGE:$TAG
          ports:
            - containerPort: 80
EOF

cd argo-cd
git config --global user.name "Muhammad Asim"
git config --global user.email "info@cloudgeeks.ca"
git add dev/deployment.yaml
git commit -m "TAG Updated"
git push origin master
# End