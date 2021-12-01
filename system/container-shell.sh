#!/bin/sh -e

build_container () {
    base="$1"
    container_tag="$1-shell:latest"
    docker pull "$1:latest"
    docker build -t "$container_tag" -f "shell-dockerfiles/$1.Dockerfile" .
}

run_container ()
{
    base="$1"
    container_tag="$1-shell:latest"
    docker run -it --rm "$container_tag"
}

is_valid_platform_name() {
    case "$1" in
        ubuntu) return 0 ;;
        debian) return 0 ;;
        *)      echo "Unknown platform $1"
                return 1;
    esac
}

cmd_build()
{
    if `is_valid_platform_name "$1"`; then
        build_container "$1"
    else
        return 1
    fi
}

cmd_build_all()
{
    cmd_build ubuntu
    cmd_build debian
}

cmd_run()
{
    if `is_valid_platform_name "$1"`; then
        run_container "$1"
    else
        return 1
    fi
}

print_usage()
{
    echo "Usage:"
    echo "./container-shell.sh build <platform>"
    echo "./container-shell.sh run <platform>"
    return 1
}

case "$1" in
    build)          cmd_build "$2" ;;
    "build-all")    cmd_build_all ;;
    run)            cmd_run "$2" ;;
    *)              print_usage ;;
esac
