require 'spec_helper'

describe SessionsController do
            
  #needed any time you have the have_selector tag
  render_views

  describe "GET 'new'" do
    it "should be successful" do
      get :new
      response.should be_success
    end  
    
    it "should have the right title" do
      get :new
      response.should have_selector('title', :content => "Sign in")
    end
  end   
  
  describe "post create" do
     describe "failure" do
          
        before(:each) do
           @attr = {:email => "", :password => ""}
        end
        
       it "should re-render submission page" do
           post :create, :session => @attr   
           response.should render_template('new')
       end        
       
       it "should have an error message" do
           post :create, :session => @attr
           flash.now[:error].should =~ /invalid/i
       end      
       
       it "should have the right title" do
         post :create, :session => @attr
         response.should have_selector('title', :content => "Sign in")
       end
       
     end
     
     describe "success" do
       before(:each) do    
         @user = Factory(:user)
         @attr = {:email => @user.email, :password => @user.password}
       end
       
       it "should sign the user in" do
          post :create, :session => @attr    
          controller.current_user.should == @user
          controller.should be_signed_in #note be_signed_in means signed_in? will be called 
       end  
       
       it "should redirect to user show page" do
          post :create, :session => @attr
          response.should redirect_to(user_path(@user))
       end
       
     end
  end 
  
  describe "delete session" do
     
     it "should sign the user out" do
          test_sign_in(Factory(:user)) #def in spec_helper
          delete :destroy
          controller.should_not be_signed_in
          response.should redirect_to(root_path)
     end

    it "should clear the fb session variable" do
          test_sign_in(Factory(:user)) #def in spec_helper
          session[:fb_session_token] = "12312"
          delete :destroy
          session[:fb_session_token].should be_nil
    end
  end
  
  describe "post to fb_log_in" do
    
    before(:each) do
      @user = Factory(:user)  
      request.cookies['fbsr_179989805389930'] = 'yCsSoeF9po3K-TJ6xvLnApzFOXxYYQ7-lKa_Al2IMKc.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImNvZGUiOiJBUUEyN25pMmF4VFdrcXowMWtmZXMzTVg1TDFadkJaQnlfR0xiREhIeTZuS2I2OUZNXzRiTmF5UTdOOUU0dmVEY3hCeUlOZDVlVXF1M3k2OFV0elp5YnBqR2l2S2dhRno2aERFakE3c0tkZFRfenFZdVRQVWlyZlJjSERrTXlaZWhwSDFxek9oNFhFa3Z0aDFwRVF6OUZsdEFQaUZkVzRlVm5NVXpkT0ZpMXBwVkEiLCJpc3N1ZWRfYXQiOjEzMjQ4NTI4NjgsInVzZXJfaWQiOiI2MjA2MTk3In0'    
    end
    
    describe "linking" do
      before(:each) do
        test_sign_in(@user)
        @fb_user_id = @user.fb_user_id
        @user.update_attribute(:fb_user_id, nil)
        @user.reload
        @token = "4123"
      end
      
      it "should link the current user with the fb user" do
        post :fb_signin
        controller.should be_signed_in
        controller.current_user.fb_user_id.should == @fb_user_id
      end
      
     it "should redirect to the edit user path" do
        post :fb_signin
        response.should redirect_to @user
      end
    end
    
    describe "success" do
      it "should log the user in when user with fb_id found with a valid cookie" do
        post :fb_signin
        controller.should be_signed_in
        controller.current_user.should == @user
      end
      
      it "should redirect to user show page" do
        post :fb_signin
         response.should redirect_to(user_path(@user))
      end
      
      it "should redirect to the specified redirect page" do
        post :fb_signin, :redirect_to => "/users"
        response.should redirect_to(users_path)
      end

      it "should set the access token" do
        post :fb_signin, :access_token => @token
        controller.fb_access_token.should == @token
      end
      
    end
    
    describe "failure" do
      
      it "should not log a user in with an invalid cookie" do
        request.cookies['fbsr_179989805389930'] = ""
        post :fb_signin, :fb_id => 0
        controller.should_not be_signed_in
      end
        
      it "should redirect to the root path" do
        request.cookies['fbsr_179989805389930'] = ""
        post :fb_signin, :fb_id => @user.fb_user_id
        response.should redirect_to root_path
      end
    end
    
    describe "no user found" do
      it "should not log a user in a user with a valid cookie, but with no fb_id user " do
        fb_id = @user.fb_user_id
        @user.fb_user_id = nil
        @user.save!
        post :fb_signin, :fb_id => fb_id
        controller.should_not be_signed_in        
      end
      
      it "should redirect to the fb registration page" do
        fb_id = @user.fb_user_id
        @user.fb_user_id = nil
        @user.save!
        post :fb_signin, :fb_id => fb_id  
        response.should render_template "users/new_fb"      
      end
    end
  end

end
