# pagez
Draw a simple cursor on framebuffer display (in zig programming language)

### Install on Alpine Linux

*Logged in as root:*
1. `localhost:~$ apk add git`
2. `localhost:~$ adduser <user>`
3. `localhost:~$ adduser <user> input`
4. `localhost:~$ adduser <user> video`
5. `localhost:~$ chgrp input /dev/input/mouse0`

*Logged in as >>user<<:*
6. `localhost:~$ cd`
7. `localhost:~$ mkdir -p src/zig`
8. `localhost:~$ cd src/zig`
9. `localhost:~$ git config --global user.name "Your Name"` (optional)
10. `localhost:~$ git config --global user.email "your@email.ad"` (optional)
11. `localhost:~$ git clone https://github.com/hi7/pagez.git`
12. `localhost:~$ cd pagez`
13. `localhost:~$ sh/install.sh -os linux -cpu <CPUTYPE>` (CPUTYPE: armv7a, aarch64, x86_64)
14. `localhost:~$ touch ~/.profile`
15. `localhost:~$ vi ~/.profile` press enter than i followed by `PATH="$HOME/bin:$PATH"` (press ESC than zz)
16. `localhost:~$ source ~/.profile`
17. `localhost:~$ zig version` 0.8.1
18. `localhost:~$ zig build run`
