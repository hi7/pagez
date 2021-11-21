#!/bin/bash
V=-v
if [[ $1 == $V ]]; then echo "install pagez (verbose mode)"; fi

INSTDIR=~/tools
if [ ! -d $INSTDIR ]; then
	mkdir $INSTDIR;
	if [[ $1 == $V ]]; then echo "mkdir $INSTDIR"; fi
fi
ZIGVERSION=0.8.1
ZIGDLPATH="https://ziglang.org/download/$ZIGVERSION/"
ZIGEXT=".tar.xz"
ZIGBIN=zig
CPUTYPE=$(lscpu | grep Arch | cut -d : -f 2 | xargs)
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

