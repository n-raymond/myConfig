#!/bin/bash

set -e

ext=".backup"

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

USER=$(cat ~/.proxy_credentials.json | jq -r '.user')
PASSWORD=$(cat ~/.proxy_credentials.json | jq -r '.password')
URL_ESCAPED_PASSWORD=$(python -c "import urllib.parse; print(urllib.parse.quote('''$PASSWORD'''))")
HOST="10.49.64.5"
PORT="8080"

set_proxy_variables() {

    # Most applications use lowercase variables
    export http_proxy="http://${USER}:${URL_ESCAPED_PASSWORD}@${HOST}:${PORT}"
    export https_proxy="http://${USER}:${URL_ESCAPED_PASSWORD}@${HOST}:${PORT}"
    export ftp_proxy="https://${USER}:${URL_ESCAPED_PASSWORD}@${HOST}:${PORT}"
    export no_proxy="192.168.1.1,localhost,127.0.0.0,127.0.0.1,127.0.1.1,local.home,schema-registry,192.168.99.0/24,10.96.0.0/12"

    # But some applications use uppercase variables so let's define them too
    export HTTP_PROXY=$http_proxy
    export HTTPS_PROXY=$https_proxy
    export FTP_PROXY=$ftp_proxy
    export NO_PROXY=$no_proxy

    # Export various configurations
    export GIT_SSH_COMMAND="ssh -o ProxyCommand=\"socat - PROXY:${HOST}:%h:%p,proxyport=${PORT},proxyauth=${USER}:${PASSWORD}\""
    export DOCKER_RUN_PROXY="-e https_proxy=$https_proxy -e http_proxy=$http_proxy -e no_proxy=$no_proxy"
    export SBT_OPTS="-Dhttp.proxyHost=${HOST} -Dhttp.proxyPort=${PORT} -Dhttp.proxyUser=${USER} -Dhttp.proxyPassword=${PASSWORD} -Dhttp.nonProxyHosts=${no_proxy//,/|}"
    export SBT_CREDENTIALS="${HOME}/.sbt/.credentials"
    export JAVA_OPTS="-Dhttp.proxyHost=${HOST} -Dhttp.proxyPort=${PORT} -Dhttp.proxyUser=${USER} -Dhttp.proxyPassword=${PASSWORD} -Dhttp.nonProxyHosts=${no_proxy//,/|}"
    export _JAVA_OPTIONS="-Dhttp.proxyHost=${HOST} -Dhttp.proxyPort=${PORT} -Dhttp.proxyUser=${USER} -Dhttp.proxyPassword=${PASSWORD} -Dhttp.nonProxyHosts=${no_proxy//,/|}"

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
main_credential_file="$HOME/.sbt/credentials"
sbt_0_13_folder="$HOME/.sbt/0.13"
sbt_0_13_credentials_file="${sbt_0_13_folder}/plugins/credentials.sbt"
sbt_1_0_folder="$HOME/.sbt/1.0"
sbt_1_0_credentials_file="${sbt_1_0_folder}/plugins/credentials.sbt"

set_sbt_proxy() {
    cat > $sbt_repository_file << EOF
[repositories]
  local
  local-preloaded-ivy: file:///\${sbt.preloaded-\${sbt.global.base-\${user.home}/.sbt}/preloaded/}, [organization]/[module]/[revision]/[type]s/[artifact](-[classifier]).[ext]
  local-preloaded: file:///\${sbt.preloaded-\${sbt.global.base-\${user.home}/.sbt}/preloaded/}
  gcp-udd-ivy-proxy-releases: https://nexus.phenix.carrefour.com/content/groups/ivy-releases/, [organization]/[module]/(scala_[scalaVersion]/)(sbt_[sbtVersion]/)[revision]/[type]s/[artifact](-[classifier]).[ext]
  gcp-udd-maven-proxy-releases: https://nexus.phenix.carrefour.com/content/groups/public/
  maven-central
  typesafe-ivy-releases: https://repo.typesafe.com/typesafe/ivy-releases/, [organization]/[module]/[revision]/[type]s/[artifact](-[classifier]).[ext], bootOnly
  sbt-ivy-snapshots: https://repo.scala-sbt.org/scalasbt/ivy-snapshots/, [organization]/[module]/[revision]/[type]s/[artifact](-[classifier]).[ext], bootOnly
EOF

    cat > $main_credential_file << EOF
realm=Sonatype Nexus Repository Manager
host=nexus.phenix.carrefour.com
user=$USER
password=$PASSWORD
EOF

    if [[ -d $sbt_0_13_folder ]]; then
        mkdir -p ${sbt_0_13_folder}/plugins
        cat > $sbt_0_13_credentials_file << EOF
credentials += Credentials(Path.userHome / ".sbt" / "credentials")
EOF
    fi

    if [[ -d $sbt_1_0_folder ]]; then
        mkdir -p ${sbt_1_0_folder}/plugins
        cat > $sbt_1_0_credentials_file << EOF
credentials += Credentials(Path.userHome / ".sbt" / "credentials")
EOF
    fi
}

unset_sbt_proxy() {
    unset_file $sbt_repository_file
    unset_file $sbt_0_13_credentials_file
    unset_file $sbt_1_0_credentials_file
    unset_file $main_credential_file
}


# Docker configuration

docker_service_folder="/etc/systemd/system/docker.service.d/"
docker_service_conf="${docker_service_folder}http-proxy.conf"
docker_service_env="${docker_service_folder}http-proxy.env"

set_docker_proxy() {
    sudo bash << SUDO_EOF
cat > $docker_service_conf << EOF
[Service]
EnvironmentFile=${docker_service_env}
EOF
SUDO_EOF

    sudo bash << SUDO_EOF
cat > $docker_service_env << EOF
HTTP_PROXY="http://${USER}:${URL_ESCAPED_PASSWORD}@${HOST}:${PORT}"
HTTPS_PROXY="http://${USER}:${URL_ESCAPED_PASSWORD}@${HOST}:${PORT}"
NO_PROXY="localhost,127.0.0.1"
EOF
SUDO_EOF

    sudo systemctl daemon-reload
}

unset_docker_proxy() {
    unset_file $docker_service_conf
    unset_file $docker_service_env
    sudo systemctl daemon-reload
}

# Main functions

proxy_on() {
    echo "[PROXY ON]"
    set_proxy_variables
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
wifi_id=$(ip addr show | awk '/inet.*brd/{print $NF; exit}')

addr=$(ifconfig $wifi_id 2>/dev/null | sed -En 's/.*inet (addr:)?(([0-9]*\.){1}[0-9]*).*/\2/p')
ppp=$(ifconfig ppp0 | sed -En 's/.*inet (addr:)?(([0-9]*\.){1}[0-9]*).*/\2/p')

[[ $addr == *10.176* || ${addr} == *10.18* || ${ppp} == *10.* ]] && proxy_on || proxy_off

