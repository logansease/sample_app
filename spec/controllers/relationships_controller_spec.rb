require 'spec_helper'

describe RelationshipsController do
   describe "access controll" do
      it "should require signin for create" do
         post :create
         response.should redirect_to(signin_path)
      end  
      
      it "should require signin for destroy" do
         post :destroy, :id => 1
         response.should redirect_to(signin_path)
      end    
   end    
   
   describe "post create" do
      before (:each) do
         @user = test_sign_in(Factory(:user))  
         @followed_user = Factory(:user, :email => Factory.next(:email))
      end    
      
      it "should craate relationship" do
         lambda do
           post :create, :relationship => {:followed_id => @followed_user}  
           response.should redirect_to(user_path(@followed_user))
         end.should change(Relationship, :count).by(1)
      end
      
      it "should create relationship with ajx" do
         lambda do
           xhr :post, :create, :relationship => {:followed_id => @followed_user}
           response.should be_success
         end.should change(Relationship, :count).by(1)
      end
            
   end  
   
   describe "delete destroy" do
      before (:each) do
        @user = test_sign_in(Factory(:user))  
        @followed_user = Factory(:user, :email => Factory.next(:email))  
        @user.follow!(@followed_user)
        @relationship = @user.relationships.find_by_followed_id(@followed_user)
     end   
     
     it "should destroy relationship" do
        lambda do
          delete :destroy, :id => @relationship
          response.should redirect_to(user_path(@followed_user))
        end.should change(Relationship,:count).by(-1)
     end
     
   end
   
end