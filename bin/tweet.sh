#! /bin/bash
cd $HOME/daigoroubot2/bin
/usr/bin/ruby2.3.3 tweet.rb $* 1>> ../logs/tweet.log 2>> ../logs/tweet.log
