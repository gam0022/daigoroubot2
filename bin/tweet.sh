#! /bin/bash
cd $HOME/daigoroubot2
/usr/bin/ruby bin/tweet.rb $* 1>> logs/tweet.log 2>> logs/tweet.log
