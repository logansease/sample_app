class FbConnectionsController < ApplicationController
  before_filter :authenticate

  def create
    remove_user_fb_connections
    create_user_fb_connections
    redirect_back_or(edit_user_path)
  end

  def destroy
     remove_user_fb_connections
    redirect_back_or(edit_user_path)
  end
end
