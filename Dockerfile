FROM ubuntu:20.04

ARG NGINX_VERSION=1.18.0
ARG MODSECURITY_VERSION=3.0.4
ARG OWASP_CRS_VERSION=3.3.0

# install nginx as per https://nginx.org/en/linux_packages.html#Ubuntu

# install nginx dependencies and other tools
RUN apt-get update && apt-get install -y \
        curl \
        gnupg2 \
        ca-certificates \
        lsb-release \
        logrotate \
    && rm -rf /var/lib/apt/lists/*

# add nginx mainline repo and install
RUN echo "deb http://nginx.org/packages/mainline/ubuntu `lsb_release -cs` nginx" | tee /etc/apt/sources.list.d/nginx.list \
    && curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add - \
    && apt-get update \
    && NGINX_DEB_VERSION=$(apt list -a nginx | grep "${NGINX_VERSION}-" | cut -d' ' -f2) \
    && apt-get install -y nginx=${NGINX_DEB_VERSION} \
    && rm -rf /var/lib/apt/lists/*

# install nginx modsecurity as per "MODSECURITY 3.0 & NGINX: Quick Start Guide"

# install nginx modsecurity dependencies
RUN apt-get update && apt-get install -y \
        apt-utils \
        autoconf \
        automake \
        build-essential \
        git \
        libcurl4-openssl-dev \
        libgeoip-dev \
        liblmdb-dev \
        libpcre++-dev \
        libtool \
        libxml2-dev \
        libyajl-dev \
        pkgconf \
        wget \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# clone modsecurity source and build
RUN git clone --depth 1 --branch v${MODSECURITY_VERSION} https://github.com/SpiderLabs/ModSecurity \
    && cd ModSecurity \
    && git submodule init \
    && git submodule update \
    && ./build.sh \
    && ./configure \
    && make \
    && make install \
    && cd / \
    && rm -R ModSecurity

# clone nginx connector for modsecurity and build
RUN git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git \
    && NGINX_VERSION="$(nginx -v 2>&1 | sed 's/[^0-9]*\([0-9.]\+\)[^0-9]*\+/\1/')" \
    && wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && tar zxvf nginx-${NGINX_VERSION}.tar.gz \
    && cd nginx-${NGINX_VERSION} \
    && ./configure --with-compat --add-dynamic-module=../ModSecurity-nginx \
    && make modules \
    && cp objs/ngx_http_modsecurity_module.so /etc/nginx/modules \
    && sed -i '1iload_module modules/ngx_http_modsecurity_module.so;' /etc/nginx/nginx.conf \
    && cd / \
    && rm -R ModSecurity-nginx \
    && rm -R nginx-${NGINX_VERSION} \
    && rm -R nginx-${NGINX_VERSION}.tar.gz

# copy in modsecurity recommended config and our config
# SecAuditEngine is off as per "Implementing ModSecurity in Production" section of "MODSECURITY 3.0 & NGINX: Quick Start Guide"
RUN mkdir /etc/nginx/modsec \
    && cd /etc/nginx/modsec \
    && wget https://raw.githubusercontent.com/SpiderLabs/ModSecurity/v${MODSECURITY_VERSION}/modsecurity.conf-recommended \
    && mv modsecurity.conf-recommended modsecurity.conf \
    && cp modsecurity.conf modsecurity-detectiononly.conf \
    && sed -i "s/SecAuditEngine \S*/SecAuditEngine Off/" /etc/nginx/modsec/modsecurity.conf \
    && sed -i "s/SecRuleEngine \S*/SecRuleEngine On/" /etc/nginx/modsec/modsecurity.conf \
    && sed -i "s#SecAuditLog \S*#SecAuditLog /dev/stdout#" /etc/nginx/modsec/modsecurity.conf \
    && chown root:nginx modsecurity.conf \
    && wget https://raw.githubusercontent.com/SpiderLabs/ModSecurity/v${MODSECURITY_VERSION}/unicode.mapping
COPY modsec.conf /etc/nginx/modsec/main.conf
COPY modsec-detectiononly.conf /etc/nginx/modsec/main-detectiononly.conf

# download OWASP CRS
RUN wget -O owasp-crs.tar.gz https://github.com/coreruleset/coreruleset/archive/v${OWASP_CRS_VERSION}.tar.gz \
    && tar -xzvf owasp-crs.tar.gz \
    && mv coreruleset-${OWASP_CRS_VERSION}/ /usr/local/owasp-modsecurity-crs/ \
    && cd /usr/local/owasp-modsecurity-crs \
    && cp crs-setup.conf.example crs-setup.conf \
    && cd / \
    && rm -R owasp-crs.tar.gz

# copy in our nginx conf
COPY nginx.conf /etc/nginx/nginx.conf
# copy in our entrypoint script
COPY entrypoint.sh /entrypoint.sh

EXPOSE 8080
ENTRYPOINT [ "/entrypoint.sh" ]
