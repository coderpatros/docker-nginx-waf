#!/usr/bin/env bash
sed -i "s/SecAuditEngine \S*/SecAuditEngine $SEC_AUDIT_ENGINE/" /etc/nginx/modsec/modsecurity.conf
sed -i "s/SecRuleEngine \S*/SecRuleEngine $SEC_RULE_ENGINE/" /etc/nginx/modsec/modsecurity.conf

# make directory /var/log/nginx if needed
mkdir --parents /var/log/nginx

nginx -g "daemon off;"