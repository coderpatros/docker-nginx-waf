FROM ubuntu:18.04

# install nginx as per https://nginx.org/en/linux_packages.html#Ubuntu

# install nginx dependencies
RUN apt-get update \
    && apt-get install -y \
        curl \
        gnupg2 \
        ca-certificates \
        lsb-release

# add nginx mainline repo and install
RUN echo "deb http://nginx.org/packages/mainline/ubuntu `lsb_release -cs` nginx" | tee /etc/apt/sources.list.d/nginx.list \
    && curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add - \
    && apt-get update \
    && apt-get install -y nginx

# install nginx modsecurity as per "MODSECURITY 3.0 & NGINX: Quick Start Guide"

# install nginx modsecurity dependencies
RUN apt-get install -y \
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
        zlib1g-dev

# clone modsecurity source and build
RUN git clone --depth 1 -b v3/master --single-branch https://github.com/SpiderLabs/ModSecurity \
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
    && wget https://raw.githubusercontent.com/SpiderLabs/ModSecurity/v3/master/modsecurity.conf-recommended \
    && mv modsecurity.conf-recommended modsecurity.conf \
    && sed -i "s/SecRuleEngine DetectionOnly/SecRuleEngine On/" modsecurity.conf \
    && sed -i "s/SecAuditEngine RelevantOnly/SecAuditEngine off/" modsecurity.conf \
    && wget https://raw.githubusercontent.com/SpiderLabs/ModSecurity/v3/master/unicode.mapping
COPY modsec.conf /etc/nginx/modsec/main.conf

# download OWASP CRS
RUN wget https://github.com/SpiderLabs/owasp-modsecurity-crs/archive/v3.0.0.tar.gz \
    && tar -xzvf v3.0.0.tar.gz \
    && mv owasp-modsecurity-crs-3.0.0 /usr/local \
    && cd /usr/local/owasp-modsecurity-crs-3.0.0 \
    && cp crs-setup.conf.example crs-setup.conf \
    && cd / \
    && rm -R v3.0.0.tar.gz

EXPOSE 8080
ENTRYPOINT [ "nginx", "-g", "daemon off;" ]