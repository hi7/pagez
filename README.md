# pagez
Draw a simple cursor on framebuffer display (in zig programming language)

### Install on DietPi

Logged in as dietpi:
1. `dietpi@DietPi:~$ sudo apt install git`
2. `dietpi@DietPi:~$ cd`
3. `dietpi@DietPi:~$ mkdir -p src/zig`
4. `dietpi@DietPi:~$ cd src/zig`
5. `dietpi@DietPi:~$ git config --global user.name "Your Name"` (optional)
6. `dietpi@DietPi:~$ git config --global user.email "your@email.ad"` (optional)
7. `dietpi@DietPi:~$ git clone https://github.com/hi7/pagez.git`
8. `dietpi@DietPi:~$ cd pagez`
9. `dietpi@DietPi:~$ sudo apt install xz-utils`
10. `dietpi@DietPi:~$ sh/install.bash -os linux -cpu <CPUTYPE>` (CPUTYPE: armv7a, aarch64)
11. `dietpi@DietPi:~$ nano ~/.profile` move to the end of the file and enter 
`if [ -d ~/bin ]; then`
`  PATH="$HOME/bin:$PATH"`
`fi` (press Control & o, followed by Enter, than Control & x)
12. `dietpi@DietPi:~$ source ~/.profile`
13. `dietpi@DietPi:~$ zig version` 0.8.1
14. `dietpi@DietPi:~$ zig build run`



### Install on Alpine Linux

Logged in as root:
1. `localhost:~$ apk add git`
2. `localhost:~$ adduser <user>`
3. `localhost:~$ adduser <user> input`
4. `localhost:~$ adduser <user> video`
5. `localhost:~$ chgrp input /dev/input/mouse0`

Logged in as `<user>`:
1. `localhost:~$ cd`
2. `localhost:~$ mkdir -p src/zig`
3. `localhost:~$ cd src/zig`
4. `localhost:~$ git config --global user.name "Your Name"` (optional)
5. `localhost:~$ git config --global user.email "your@email.ad"` (optional)
6. `localhost:~$ git clone https://github.com/hi7/pagez.git`
7. `localhost:~$ cd pagez`
8. `localhost:~$ sh/install.sh -os linux -cpu <CPUTYPE>` (CPUTYPE: armv7a, aarch64, x86_64)
9. `localhost:~$ touch ~/.profile`
10. `localhost:~$ vi ~/.profile` press enter than i followed by `PATH="$HOME/bin:$PATH"` (press ESC than zz)
11. `localhost:~$ source ~/.profile`
12. `localhost:~$ zig version` 0.8.1
13. `localhost:~$ zig build run`
