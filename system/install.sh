#!/bin/sh -e

if [ -t 1 ]; then
    # interactive
    apt_get_parameters=""
else
    # not interactive
    apt_get_parameters="-y"
fi

apt_packages=`sed '/^#/d' apt | xargs`
debian_specific_packages=`sed '/^#/d' debian-specific | xargs`
ubuntu_specific_packages=`sed '/^#/d' ubuntu-specific | xargs`
brew_packages=`sed '/^#/d' brew | xargs`

if [ `whoami` = 'root' ]; then
    echo is root
    sudo_cmd=''
else
    echo is not root
    sudo_cmd='sudo'
fi

install_apt_packages()
{
    distribution_name=`egrep '^NAME=' /etc/os-release | cut -f 2 -d '"'`
    echo "Distribution name: ${distribution_name}"

    echo "Adding packages for Debian based systems:\n${apt_packages}"
    apt_packages_to_install="${apt_packages}"

    case "${distribution_name}" in
        Ubuntu)             apt_packages_to_install="${apt_packages_to_install} ${ubuntu_specific_packages}"
                            echo "Adding Ubuntu specific packages:\n${ubuntu_specific_packages}" ;;
        "Debian GNU/Linux") apt_packages_to_install="${apt_packages_to_install} ${debian_specific_packages}"
                            echo "Adding Debian specific packages\n${debian_specific_packages}" ;;
    esac

    echo "Installing the following packages:"
    echo "${apt_packages_to_install}"

    $sudo_cmd apt-get update
    $sudo_cmd apt-get install $apt_get_parameters ${apt_packages_to_install}
}

install_linux_packages()
{
    install_apt_packages
}

install_darwin_packages()
{
    echo "macOS is not implemented..."
    exit 1
}

case `uname` in
    Linux)  install_linux_packages ;;
    Darwin) install_darwin_packages ;;
    *)      echo "`uname` is not a supported platform"
            exit 1 ;;
esac
