# syntax=docker/dockerfile:1

FROM ubuntu:latest

ENV DEBIAN_FRONTEND noninteractive

## Basic
RUN <<EOF

apt update
apt upgrade -y

apt install -y \
    git \
    gh \
    gnupg \
    wget \
    software-properties-common \
    curl \
    python3-dev \
    python3-pip \
    python3-venv \
    openssh-client \
    ansible \
    shellcheck \
    unzip

wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    tee /etc/apt/sources.list.d/hashicorp.list
apt update
apt install -y \
    terraform

pip install --upgrade pip
pip install  \
    ansible-lint \
    boto3 \
    cfn-lint \
    pydot
EOF

## kubectl
RUN <<EOF
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum -c
install kubectl -o root -g root -m 0755 kubectl /usr/local/bin
rm kubectl*
kubectl version --client --output=yaml
EOF

# ansible
RUN <<EOF
ansible-galaxy collection install \
    amazon.aws \
    community.general \
    community.crypto \
    community.aws
EOF

# AWS CLI
RUN <<EOF

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm awscliv2.zip
rm -rd aws
EOF

ENTRYPOINT [ "/bin/bash" ]
