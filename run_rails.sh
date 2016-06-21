#!/bin/bash
source /usr/local/rvm/environments/ruby-2.2.4@SharpAlert

cd /home/wucolin/apps/SharpAlert/current
env RAILS_ENV=production ~/bin/rails r $1 $2 $3 $4 $5
