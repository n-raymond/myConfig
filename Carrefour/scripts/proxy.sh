#!/bin/bash

ext=".unset"

warn() {
    >&2 echo "Warning: $1"
}

set_file() {
    if [[ ! -f $1 ]]; then
        [[ -f $1$ext ]] && sudo mv $1$ext $1 || warn "$1$ext not found: could not set $1..."
    fi
}

unset_file() {
    [[ -f $1 ]] && sudo mv $1 $1$ext
}


# Proxy Configuration

proxy_user="nicolas_raymond_1"
proxy_password="2469.Noo"
#proxy_host="10.176.205.3"
proxy_host="10.49.64.5"
proxy_port="8080"
proxy_host_gke="gke-proxy.phenix-rec.carrefour.com"
proxy_port_gke="4239"
proxy_host_registry="10.176.205.3"
proxy_port_registry="8080"

set_proxy_variables() {

    addr=$proxy_host
    port=$proxy_port
    if [[ $1 == 2 ]]; then
        addr=$proxy_host_gke
        port=$proxy_port_gke
    elif [[ $1 == 3 ]]; then
        addr=$proxy_host_registry
        port=$proxy_port_registry
    fi

    # Most applications use lowercase variables
    export http_proxy="http://${proxy_user}:${proxy_password}@${addr}:${port}"
    export https_proxy="http://${proxy_user}:${proxy_password}@${addr}:${port}"
    export ftp_proxy="https://${proxy_user}:${proxy_password}@${addr}:${port}"
    export no_proxy="192.168.1.1,localhost,127.0.0.0,127.0.0.1,127.0.1.1,local.home,schema-registry,192.168.99.0/24,10.96.0.0/12"

    # But some applications use uppercase variables so let's define them too
    export HTTP_PROXY=$http_proxy
    export HTTPS_PROXY=$https_proxy
    export FTP_PROXY=$ftp_proxy
    export NO_PROXY=$no_proxy

    # Export various configurations
    export GIT_SSH_COMMAND="ssh -o ProxyCommand=\"socat - PROXY:${addr}:%h:%p,proxyport=${port},proxyauth=${proxy_user}:${proxy_password}\""
    export DOCKER_RUN_PROXY="-e https_proxy=$https_proxy -e http_proxy=$http_proxy -e no_proxy=$no_proxy"
    export SBT_OPTS="-Dhttp.proxyHost=${addr} -Dhttp.proxyPort=${port} -Dhttp.proxyUser=${proxy_user} -Dhttp.proxyPassword=${proxy_password} -Dhttp.nonProxyHosts=${no_proxy//,/|}"
    export SBT_CREDENTIALS="${HOME}/.sbt/.credentials"
    export JAVA_OPTS="-Dhttp.proxyHost=${addr} -Dhttp.proxyPort=${port} -Dhttp.proxyUser=${proxy_user} -Dhttp.proxyPassword=${proxy_password} -Dhttp.nonProxyHosts=${no_proxy//,/|}"
    export _JAVA_OPTIONS="-Dhttp.proxyHost=${addr} -Dhttp.proxyPort=${port} -Dhttp.proxyUser=${proxy_user} -Dhttp.proxyPassword=${proxy_password} -Dhttp.nonProxyHosts=${no_proxy//,/|}"

}

unset_proxy_variables() {
    unset http_proxy
    unset https_proxy
    unset ftp_proxy
    unset no_proxy

    unset HTTP_PROXY
    unset HTTPS_PROXY
    unset FTP_PROXY
    unset NO_PROXY

    unset GIT_SSH_COMMAND
    unset DOCKER_RUN_PROXY
    unset SBT_OPTS
    unset SBT_CREDENTIALS
    unset JAVA_OPTS
    unset _JAVA_OPTIONS
}



# Sbt configuration

sbt_repository_file="$HOME/.sbt/repositories"
sbt_0_13_credentials_file="$HOME/.sbt/0.13/plugins/credentials.sbt"
sbt_1_0_credentials_file="$HOME/.sbt/1.0/plugins/credentials.sbt"

set_sbt_proxy() {
    set_file $sbt_repository_file
    set_file $sbt_0_13_credentials_file
    set_file $sbt_1_0_credentials_file
}

unset_sbt_proxy() {
    unset_file $sbt_repository_file
    unset_file $sbt_0_13_credentials_file
    unset_file $sbt_1_0_credentials_file
}


# Docker configuration

docker_service_file="/etc/systemd/system/docker.service.d/http-proxy.conf"

set_docker_proxy() {
    if [[ ! -f $docker_service_file ]]; then
        set_file $docker_service_file
        sudo systemctl daemon-reload
    fi
}

unset_docker_proxy() {
    if [[ -f $docker_service_file ]]; then
        unset_file $docker_service_file
        sudo systemctl daemon-reload
    fi
}



# Main functions

proxy_on() {
    echo "[PROXY ON]"
    set_proxy_variables 1
    set_sbt_proxy
    set_docker_proxy
}

proxy_on_gke() {
    echo "[PROXY ON GKE]"
    set_proxy_variables 2
    set_sbt_proxy
    set_docker_proxy
}

proxy_on_registry() {
    echo "[PROXY ON REGISTRY]"
    set_proxy_variables 2
    set_sbt_proxy
    set_docker_proxy
}

proxy_off() {
    echo "[PROXY OFF]"
    unset_proxy_variables
    unset_sbt_proxy
    unset_docker_proxy
}


# be sure that we are in the carrefour DNS : addr IP begin 10.176.*
addr1=$(ifconfig wlp60s0 2>/dev/null    | sed -En 's/.*inet (addr:)?(([0-9]*\.){1}[0-9]*).*/\2/p')
addr2=$(ifconfig eno1 2>/dev/null | sed -En 's/.*inet (addr:)?(([0-9]*\.){1}[0-9]*).*/\2/p')

[[ $addr1 == *10.176* || $addr2 == *10.176* ]] && proxy_on || proxy_off
