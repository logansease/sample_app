class ApplicationController < ActionController::Base
   protect_from_forgery :except => [:fb_signin, :create_fb]
  
  #helper is only available in views, so include the helper in controller
  #by putting here, get it in all controllers
  include SessionsHelper
  
end
