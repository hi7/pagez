# pagez
Draw a simple cursor on framebuffer display (in zig programming language)

* Install on Alpine Linux

Logged in as root:
`localhost:~$ apk add git`
`localhost:~$ adduser <user>`
`localhost:~$ adduser <user> input`
`localhost:~$ adduser <user> video`
`localhost:~$ chgrp input /dev/input/mouse0`

Login as >>user<<:
`localhost:~$ cd`
`localhost:~$ mkdir -p src/zig`
`localhost:~$ cd src/zig`
`localhost:~$ git config --global user.name "Your Name"` (optional)
`localhost:~$ git config --global user.email "your@email.ad"` (optional)
`localhost:~$ git clone https://github.com/hi7/pagez.git`
`localhost:~$ cd pagez`
`localhost:~$ sh/install.sh -os linux -cpu <CPUTYPE>` (CPUTYPE: armv7a, aarch64, x86_64)
`localhost:~$ touch ~/.profile`
`localhost:~$ vi ~/.profile` press enter than i followed by
	`PATH="$HOME/bin:$PATH"` (press ESC than zz)
`localhost:~$ source ~/.profile`
`localhost:~$ zig version`
0.8.1
`localhost:~$ zig build run`
