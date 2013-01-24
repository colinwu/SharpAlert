require 'bundler/capistrano'
set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :user, 'sharpmon'
set :use_sudo, false
set :keep_releases, 6

set :applicationdir, "/var/www/SharpAlert"
set :application, "SharpApp"
set :repository,  "https://github.com/colinwu/SharpAlert.git"
set :git_enable_submodules, 1
set :branch, 'master'
set :git_shallow_clone, 1
set :scm_verbose, true

role :web, "seclcsglab.sharpamericas.com"                          # Your HTTP server, Apache/etc
role :app, "seclcsglab.sharpamericas.com"                          # This may be the same as your `Web` server
role :db,  "seclcsglab.sharpamericas.com", :primary => true # This is where Rails migrations will run
# role :db,  "your slave db-server here"

# deply config
set :deploy_to, applicationdir
set :deploy_via, :remote_cache

# additional settings
default_run_options[:pty] = true
# set :use_sudo false

# Passenger
after "deploy", "deploy:bundle_gems"
after "deploy:bundles_gems", "deploy:restart"

namespace :deploy do
  task :bundle_gems do
    run "cd #{deploy_to}/current && bundle install vendor/gems"
    run "cd #{deploy_to}/current && bundle exec rake assets:precompile"
  end
  task :start do ; end
  task :stop do ; end
  task :restart, :rolse => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
