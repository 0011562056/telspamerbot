telegram-bot
============

A telegram bot using https://github.com/vysheng/tg.

Installation
------------
```bash
$ wget http://luarocks.org/releases/luarocks-2.2.0.tar.gz
$ tar -xzvf luarocks-2.2.0.tar.gz 
$ cd luarocks-2.2.0/
$ ./configure 
$ make && sudo make install
$ sudo luarocks install oauth # You need unzip
```

```bash
# Tested on Ubuntu 14.04, for other OSs check out https://github.com/vysheng/tg#installation
$ sudo apt-get install lua-socket libreadline-dev libconfig-dev libssl-dev lua5.2 liblua5.2-dev libevent-dev
$ git clone git@github.com:yagop/telegram-bot.git --recursive
$ cd telegram-bot/tg
$ ./configure && make
$ cd .. && ./launch.sh # Will ask you for a phone number & confirmation code.
```

Multimedia
----------
- When user sends image (png, jpg, jpeg) URL download and send it to origin.
- When user sends media (gif, mp4, pdf, etc.) URL download and send it to origin.
- When user sends twitter URL, send text and images to origin. Requieres OAuth Key.
- When user sends youtube URL, send to origin video image.

![http://i.imgur.com/RQYGUuH.png](http://i.imgur.com/RQYGUuHm.png) ![http://i.imgur.com/zqojNhh.png](http://i.imgur.com/zqojNhhm.png)

Command list
------------
```
!9gag -> send random image from 9gag
!echo [whatever] -> echoes the msg
!eur [USD] -> EURUSD market value
!uc3m -> Fortunes from Universidad Carlos III
!get (value_name) -> retrieves variables saved with !set
say hello to [name] -> Says hello to someone
!help -> Lists all available commands
!img [topic] -> search image with Google API and sends it
!ping -> bot sends pong
!rae [word] -> Spanish dictionary
!set [value_name] [data] -> Set value
!time [area] -> Displays the local time in an area
!tw [text] -> Sends a tweet
!version -> Shows bot version
!weather (city) -> weather in that city (Madrid is default)
```

