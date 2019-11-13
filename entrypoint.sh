#!/usr/bin/env bash

# make directory /var/log/nginx if needed
mkdir --parents /var/log/nginx

service cron start

# Launch NGINX
echo "starting nginx ..."
nginx -g "daemon off;" &

nginx_pid=$!

# Amplify agent variables
agent_conf_file="/etc/amplify-agent/agent.conf"
agent_log_file="/var/log/amplify-agent/agent.log"
nginx_status_conf="/etc/nginx/conf.d/stub_status.conf"

if [ -n "${AMPLIFY_API_KEY}" ]; then
    echo "updating ${agent_conf_file} ..."

    if [ ! -f "${agent_conf_file}" ]; then
        test -f "${agent_conf_file}.default" && \
        cp -p "${agent_conf_file}.default" "${agent_conf_file}" || \
        { echo "no ${agent_conf_file}.default found! exiting."; exit 1; }
    fi

    test -n "${AMPLIFY_API_KEY}" && \
    echo " ---> using api_key = ${AMPLIFY_API_KEY}" && \
    sh -c "sed -i.old -e 's/api_key.*$/api_key = ${AMPLIFY_API_KEY}/' \
    ${agent_conf_file}"

    test -n "${AMPLIFY_IMAGENAME}" && \
    echo " ---> using imagename = ${AMPLIFY_IMAGENAME}" && \
    sh -c "sed -i.old -e 's/imagename.*$/imagename = ${AMPLIFY_IMAGENAME}/' \
	${agent_conf_file}"

    test -f "${agent_conf_file}" && \
    chmod 644 ${agent_conf_file} && \
    chown nginx ${agent_conf_file} > /dev/null 2>&1

    test -f "${nginx_status_conf}" && \
    chmod 644 ${nginx_status_conf} && \
    chown nginx ${nginx_status_conf} > /dev/null 2>&1

    if ! grep '^api_key.*=[ ]*[[:alnum:]].*' ${agent_conf_file} > /dev/null 2>&1; then
        echo "no api_key found in ${agent_conf_file}! exiting."
    fi

    echo "starting amplify-agent ..."
    service amplify-agent start > /dev/null 2>&1 < /dev/null

    if [ $? != 0 ]; then
        echo "couldn't start the agent, please check ${agent_log_file}"
        exit 1
    fi
fi

wait ${nginx_pid}

echo "nginx master process has stopped, exiting."