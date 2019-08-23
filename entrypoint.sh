#!/usr/bin/env bash
sed -i "s/SecRuleEngine DetectionOnly/SecRuleEngine $SEC_RULE_ENGINE/" /etc/nginx/modsec/modsecurity.conf
nginx -g "daemon off;"