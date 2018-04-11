#!/bin/bash
source /usr/local/rvm/environments/ruby-2.4.1@SharpAlert
source /home/wucolin/.profile
cd /home/wucolin/apps/SharpAlert/current
env RAILS_ENV=production /usr/local/rvm/gems/ruby-2.4.1@sharpAlert/bin/rails r $1 $2 $3 $4 $5
