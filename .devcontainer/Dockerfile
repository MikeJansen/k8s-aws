# syntax=docker/dockerfile:1

FROM alpine:3.17

ENV GLIBC_VERSION=2.35-r0

## Basic
RUN <<EOF
apk add --no-cache \
    git \
    github-cli \
    build-base \
    terraform \
    curl \
    python3 \
    python3-dev \
    py3-pip \
    openssl \
    openssh \
    ansible

pip3 install --no-cache-dir --upgrade pip
pip3 install --no-cache-dir ansible-lint
EOF

## kubectl
RUN <<EOF
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum -c
install kubectl -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl*
kubectl version --client --output=yaml
EOF

## AWS CLI v2
RUN <<EOF
curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub
curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk
curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk
curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-i18n-${GLIBC_VERSION}.apk
apk add --force-overwrite --no-cache \
    glibc-${GLIBC_VERSION}.apk \
    glibc-bin-${GLIBC_VERSION}.apk \
    glibc-i18n-${GLIBC_VERSION}.apk
/usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8
ln -sf /usr/glibc-compat/lib/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2
curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
unzip -qq awscliv2.zip
aws/install
rm -rf \
    awscliv2.zip \
    aws \
    /usr/local/aws-cli/v2/current/dist/aws_completer \
    /usr/local/aws-cli/v2/current/dist/awscli/data/ac.index \
    /usr/local/aws-cli/v2/current/dist/awscli/examples \
    glibc-*.apk
find /usr/local/aws-cli/v2/current/dist/awscli/botocore/data -name examples-1.json -delete 
EOF

## Cleanup
RUN <<EOF
apk --no-cache del \
    binutils
rm -rf /var/cache/apk/*
EOF

ENTRYPOINT [ "/bin/ash" ]
