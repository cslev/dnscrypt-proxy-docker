FROM debian:bookworm
LABEL maintainer="cslev <cslev@gmx.com>"

# ARG DNSCRYPT_PROXY_VERSION=2.1.4

#packages needed for compilation
ENV DEPS tshark \
         tcpdump \
         nano \
         tar \
         bzip2 \
         wget \
         procps \
         jq \
         ethtool \
         ca-certificates \
         git \
         golang

ENV PYTHON_DEPS python3 \
                python3-six \
                python3-pandas \
                python3-simplejson \
                libpython3-dev \
                python3-urllib3 \
                python3-selenium

#DEBIAN_FRONTEND=noninteractive helps to avoid dpkg-configuration question, such as Wireshark and enable it for non-root users
COPY source /dnscrypt-proxy-source
WORKDIR /dnscrypt-proxy
SHELL ["/bin/bash", "-c"]
RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $DEPS && \
  #DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $PYTHON_DEPS && \
    # dpkg -i selenium/python3-urllib3_1.24.1.deb && \
    # dpkg -i selenium/python3-selenium_3.14.1.deb && \
    apt-get autoremove --purge -y && \
    # tar -xzf dnscrypt-proxy-linux_x86_64-2.1.4.tar.gz -C /tmp/ && \
    # mv /tmp/linux-x86_64/* ./ && \
    git clone https://github.com/dnscrypt/dnscrypt-proxy src && \
    export GOOS=linux && \
    export GOARCH=amd64 && \
    cd src/dnscrypt-proxy && \
    go build -ldflags="-s -w" -mod vendor && \
    mkdir config/ && \
    cp /dnscrypt-proxy-source/dnscrypt-proxy.toml config/dnscrypt-proxy.toml

ENTRYPOINT ["/dnscrypt-proxy/src/dnscrypt-proxy/dnscrypt-proxy"]
CMD ["-config", "/dnscrypt-proxy/config/dnscrypt-proxy.toml"]