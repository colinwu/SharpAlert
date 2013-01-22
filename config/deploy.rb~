require 'bundler/capistrano'
set :user, 'sharpmon'
set :application, "SharpApp"

set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :applicationdir, "/home/sharpmon/src/SharpAlert"
set :repository,  "/var/www/SharpAlert.git"
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
set :deploy_via, :export

# additional settings
default_run_options[:pty] = true
# set :use_sudo false

# Passenger
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :rolse => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
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