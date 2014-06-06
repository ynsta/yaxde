#!/bin/bash

# This script install dependencies required to build the different tools

if [ $UID -ne 0 ]; then
    echo "Please run as root"

    echo "on ubuntu you can use 'sudo $0'"
    exit 1
fi

install=$(which apt-get 2>/dev/null || which yum 2>/dev/null)

case $install in
    */apt-get)
	apt-get -y install nsis
	apt-get -y install checkinstall
	apt-get -y install build-essential git-all
	apt-get -y install autoconf automake autopoint gawk m4 sed cmake
	apt-get -y install wget tar gzip bzip2 lzop
	apt-get -y install python python-dev
	apt-get -y install libusb-1.0
	apt-get -y install libusb-dev
	apt-get -y install libusb-1.0-0-dev
	apt-get -y install libudev-dev
	apt-get -y isntall libgtk-3-dev
	apt-get -y install libtool
	apt-get -y install gnat
	apt-get -y install libisl-dev
	gnatv=$(gnat | grep '^GNAT 4.' | awk '{ print $2 }' | awk -F. '{print $1"."$2}')
	apt-get -y install -y gcc-${gnatv}-multilib
	apt-get -y install -y g++-${gnatv}-multilib
	apt-get -y build-dep gnat gcc gdb newlib
	apt-get -y install yasm
	apt-get -y install xz-utils
	apt-get -y install libglib2.0-dev
	apt-get -y install libpixman-1-dev
	apt-get -y install texinfo
	apt-get -y build-dep qemu-system-arm


	# Disable dash for /bin/sh (use bash)
	apt-get -y install debconf-utils
	echo "dash dash/sh boolean false" | debconf-set-selections -
	dpkg-reconfigure -u dash
	;;
    */yum)
	yum install -y nsis yasm git-all yum-utils checkinstall \
	    libusb1-devel gcc gcc-gnat python-devel xz \
	    autoconf automake autopoint gawk m4 sed tar bunzip gtk3-devel
	yum-builddep -y gcc gcc-gnat gdb binutils qemu
	;;
esac

mkdir -p /opt/x-tools
mkdir -p /c/x-tools
chmod 1777 /opt/x-tools
chmod 1777 /c/x-tools
