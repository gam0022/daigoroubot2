#! /bin/bash
cd $HOME/daigoroubot2
MECAB_PATH=/usr/lib/libmecab.so.2 /usr/bin/ruby bin/tweet.rb $* 1>> logs/tweet.log 2>> logs/tweet.log
