#! /bin/bash
cd $HOME/daigoroubot2
/usr/bin/ruby bin/follow.rb $* 1>> logs/follow.log 2>> logs/follow.log
