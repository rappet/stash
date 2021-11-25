#!/bin/sh -e

load_env_file () {
    echo -n "Load $1..."
    export `cat $1 | sed 's/#.*$//;/^$/d' | xargs`
    echo "OK"
}

load_env () {
    env_file="$1"
    secrets_file="$2"

    # load env file
    load_env_file global.env

    # load instance env file
    load_env_file "$env_file"

    # load secrets
    load_env_file "$secrets_file"
}

run_local () {
    echo 'starting local...'
    load_env local.env secrets.local.env
    docker-compose up -d
}

run_prod () {
    decrypt_prod
    echo 'starting prod...'
    load_env prod.env secrets.prod.env
    docker-compose up -d
}

stop_local () {
    echo 'stopping local...'
    load_env local.env secrets.local.env
    docker-compose down
}

stop_prod () {
    echo 'stopping prod...'
    load_env prod.env secrets.prod.env
    docker-compose down -d
}

decrypt_prod () {
    gpg --batch --yes --passphrase-file secrets.key --output secrets.prod.env --decrypt secrets.prod.env.gpg
}

encrypt_prod () {
    gpg --batch --yes --passphrase-file secrets.key --output secrets.prod.env.gpg --symmetric --cipher-algo AES256 secrets.prod.env
}

help () {
    echo "Usage: $0 (local|prod|stop-local|stop-prod|decrypt-secrets|encrypt-secrets)"
}

case "$1" in
    local)              run_local ;;
    prod)               run_prod ;;
    stop-local)         stop_local ;;
    stop-prod)          stop_prod ;;
    decrypt-secrets)    decrypt_prod ;;
    encrypt-secrets)    encrypt_prod ;;
    *)                  help ;;
esac