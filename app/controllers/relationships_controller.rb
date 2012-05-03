class RelationshipsController < ApplicationController
     
  before_filter :authenticate
  
  def create
    @user = User.find(params[:relationship][:followed_id])
    current_user.follow!(@user) 
    
    #handle html / ajax
    respond_to do |format|
       format.html {redirect_to @user}
       format.js # if no block, it will execute action_name.js.erb
    end

  end
  
  def destroy
     #relationship = Relationship.find(params[:id]).destroy 
     #redirect_to relationship.followed
     
     @user = Relationship.find(params[:id]).followed
     current_user.unfollow!(@user)
     respond_to do |format|
        format.html {redirect_to @user}
        format.js # if no block, it will execute action_name.js.erb
     end
  end 
              

  
end