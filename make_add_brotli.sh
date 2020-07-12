#!/bin/bash

# https://www.majlovesreg.one/tag/code/
# https://www.majlovesreg.one/adding-brotli-to-a-built-nginx-instance
# https://github.com/majal/maj-server/tree/master/nginx-modules-brotli

# Install needed development packages if not yet installed in the system
#  apt -y install git libpcre3 libpcre3-dev zlib1g zlib1g-dev openssl libssl-dev

# For predefined NGINX version, use:
# ngver=1.17.1

# For passing the version via the command line (i.e.: user@server:~$ ./mkbrotli 1.17.1), use:
ngver=$1

# For automated detection of currently installed NGINX version (not to be used for auto-updating, see hooks in post), use:
# ngver=$(nginx -v 2>&1 | grep -o '[0-9\.]*')

# Get configure parameters of installed NGINX. Not needed if NGINX was configured '--with-compat'.
# Uncomment one of the lines below if the script sucessfully builds modules but NGINX throws a "not binary compatible" error.
# confparams=$(nginx -V 2>&1 | grep -o -- '--prefix='.*)
# confparams=$(nginx -V 2>&1 | grep -o -- '--[^with]'.*)
# confparams=$(nginx -V 2>&1 | grep -- '--' | sed "s/.*' //")
# confparams=$(nginx -V 2>&1 | grep -o -- "--prefix='.*'$")

# To manually set NGINX modules directory:
moddir=/usr/lib/nginx/modules

[ -d $(nginx -V 2>&1 | grep -o 'prefix=[^ ]*' | sed 's/prefix=//')/modules ] && moddir="$(nginx -V 2>&1 | grep -o 'prefix=[^ ]*' | sed 's/prefix=//')/modules"
[ -d $(nginx -V 2>&1 | grep -o 'modules-path=[^ ]*' | sed 's/modules-path=//') ] && moddir="$(nginx -V 2>&1 | grep -o 'modules-path=[^ ]*' | sed 's/modules-path=//')"
[ "${moddir}" ] || { echo '!! missing modules directory, exiting...'; exit 1; }

# Set temporary directory and build on it
builddir="$(mktemp -d)"
cd "${builddir}"

echo
echo '################################################################################'
echo
echo "Building Brotli for NGINX ${ngver}"
echo "Temporary build directory: ${builddir}"
echo "Modules directory: ${moddir}"
echo

# Download and unpack NGINX
wget https://nginx.org/download/nginx-${ngver}.tar.gz && { tar zxf nginx-${ngver}.tar.gz && rm nginx-${ngver}.tar.gz; } || { echo '!! download failed, exiting...'; exit 2; }

# Download, initialize, and make Brotli dynamic modules
git clone https://github.com/google/ngx_brotli.git
cd ngx_brotli && git submodule update --init && cd ../nginx-${ngver}
[ "${confparams}" ] && nice -n 19 ionice -c 3 "./configure --add-dynamic-module=../ngx_brotli ${confparams}" || nice -n 19 ionice -c 3 ./configure --with-compat --add-dynamic-module=../ngx_brotli
nice -n 19 ionice -c 3 make modules || { echo '!! configure or make failed, exiting...'; exit 4; }

# Replace Brotli in modules directory
[ -f "${moddir}/ngx_http_brotli_filter_module.so" ] &&  mv "${moddir}/ngx_http_brotli_filter_module.so" "${moddir}/ngx_http_brotli_filter_module.so.old"
[ -f "${moddir}/ngx_http_brotli_static_module.so" ] &&  mv "${moddir}/ngx_http_brotli_static_module.so" "${moddir}/ngx_http_brotli_static_module.so.old"
 cp objs/*.so "${moddir}/"
 chmod 644 "${moddir}/ngx_http_brotli_filter_module.so" || { echo '!! module permissions failed, exiting...'; exit 5; }
 chmod 644 "${moddir}/ngx_http_brotli_static_module.so" || { echo '!! module permissions failed, exiting...'; exit 6; }

# Clean up build files
cd "${builddir}/.."
 rm -r "${builddir}/ngx_brotli"
rm -r "${builddir}"

echo
echo "Sucessfully built and installed latest Brotli for NGINX ${ngver}"
echo "Modules can be found in ${moddir}"
echo "Next step: Configure dynamic modules and reload/restart NGINX."
echo
echo '################################################################################'
echo

# Start/restart NGINX.
# Not recommended if script is hooked since NGINX is automatically restarted by the package manager (e.g. apt) after an upgrade.
# Restarting NGINX before the upgrade could cause a module version mismatch.
#  nginx -t && { systemctl is-active nginx &&  systemctl restart nginx ||  systemctl start nginx; } || true
# echo
# systemctl --no-pager status nginx
# echo
