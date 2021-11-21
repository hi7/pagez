#!/bin/zsh
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
ZIGFILE=${ZIGBIN}-${OSTYPE%%-*}-$CPUTYPE-$ZIGVERSION
if [ ! -d $INSTDIR/$ZIGFILE ]; then
	if [ ! -f $INSTDIR/$ZIGFILE$ZIGEXT ]; then
		wget -P $INSTDIR ${ZIGDLPATH}$ZIGFILE$ZIGEXT;
		if [[ $1 == $V ]]; then echo wget -P $INSTDIR ${ZIGDLPATH}$ZIGFILE$ZIGEXT $INSTDIR; fi
	fi
	if [[ $1 == $V ]]; then echo "tar xf $INSTDIR/$ZIGFILE$ZIGEXT -C $INSTDIR"; fi
	tar xf $INSTDIR/$ZIGFILE$ZIGEXT -C $INSTDIR;
fi

USERBIN=~/bin
if [ ! -d $USERBIN ]; then
	mkdir $USERBIN;
	if [[ $1 == $V ]]; then echo "mkdir $USERBIN"; fi
fi

if [ ! -L $USERBIN/$ZIGBIN ]; then
	ln -s $INSTDIR/$ZIGFILE/$ZIGBIN $USERBIN/$ZIGBIN;
	if [[ $1 == $V ]]; then echo "ln -s $INSTDIR/$ZIGFILE/$ZIGBIN $USERBIN/$ZIGBIN"; fi
fi

if [ -d "$HOME/bin" ]; then
	PATH="$HOME/bin:$PATH";
	if [[ $1 == $V ]]; then echo "PATH=$HOME/bin:$PATH"; fi
fi

