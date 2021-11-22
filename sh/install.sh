#!/bin/sh
V="-v"
if [[ "$1" == $V ]]; then echo "install pagez (verbose mode)"; fi
if [[ "$1" == "-os" ]]; then OSTYPE="$2"; fi
if [[ "$2" == "-os" ]]; then OSTYPE="$3"; fi
if [[ "$1" == "-cpu" ]]; then CPUTYPE="$2"; fi
if [[ "$2" == "-cpu" ]]; then CPUTYPE="$3"; fi
if [[ "$3" == "-cpu" ]]; then CPUTYPE="$4"; fi
if [[ "$4" == "-cpu" ]]; then CPUTYPE="$5"; fi
if [[ ! "$CPUTYPE" ]]; then CPUTYPE=$(lscpu | grep Arch | cut -d : -f 2 | xargs); fi

INSTDIR="$HOME/tools"
if [ ! -d $INSTDIR ]; then
	if [[ $1 == $V ]]; then echo "mkdir $INSTDIR"; fi
	mkdir $INSTDIR;
fi

ZIGVERSION="0.8.1"
ZIGDLPATH="https://ziglang.org/download/$ZIGVERSION/"
ZIGEXT=".tar.xz"
ZIGBIN=zig
ZIGFILE=${ZIGBIN}-${OSTYPE%%-*}-$CPUTYPE-$ZIGVERSION

if [ ! -d $INSTDIR/$ZIGFILE ]; then
	if [ ! -f $INSTDIR/$ZIGFILE$ZIGEXT ]; then
		if [[ $1 == $V ]]; then echo wget -P $INSTDIR ${ZIGDLPATH}$ZIGFILE$ZIGEXT $INSTDIR; fi
		wget -P $INSTDIR ${ZIGDLPATH}$ZIGFILE$ZIGEXT;
	fi
	if [[ $1 == $V ]]; then echo "tar xf $INSTDIR/$ZIGFILE$ZIGEXT -C $INSTDIR"; fi
	tar xf $INSTDIR/$ZIGFILE$ZIGEXT -C $INSTDIR;
	if [[ $1 == $V ]]; then echo "rm $INSTDIR/$ZIGFILE$ZIGEXT"; fi
	rm $INSTDIR/$ZIGFILE$ZIGEXT;
fi

USERBIN=~/bin
if [ ! -d $USERBIN ]; then
	if [[ $1 == $V ]]; then echo "mkdir $USERBIN"; fi
	mkdir $USERBIN;
fi

if [ ! -L $USERBIN/$ZIGBIN ]; then
	if [[ $1 == $V ]]; then echo "ln -s $INSTDIR/$ZIGFILE/$ZIGBIN $USERBIN/$ZIGBIN"; fi
	ln -s $INSTDIR/$ZIGFILE/$ZIGBIN $USERBIN/$ZIGBIN;
fi

if [ -d "$HOME/bin" ]; then
	if [[ $1 == $V ]]; then echo "PATH=$HOME/bin:$PATH"; fi
	PATH="$HOME/bin:$PATH"
fi

INPUT_COUNT=$(groups | grep input | wc -l);
if [[ $INPUT_COUNT == 0 ]]; then
    command -v sudo || {
	echo "sudo not found! Please do as root: adduser $USER input";
	exit 1;
    }
    echo "sudo adduser $USER input";
    sudo adduser $USER input
fi
VIDEO_COUNT=$(groups | grep video | wc -l);
if [[ $VIDEO_COUNT == 0 ]]; then
    command -v sudo || {
	echo "sudo not found! Please do as root: adduser $USER video";
	exit 1;
    }
    echo "sudo adduser $USER video";
    sudo adduser $USER video
fi
