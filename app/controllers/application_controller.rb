class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :all
  
  $remote_host = '172.29.109.114'
  
end
