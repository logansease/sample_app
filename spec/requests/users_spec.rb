require 'spec_helper'

describe "Users" do
  
  describe "sign up" do
    
    describe "failure" do
        it "should not make a new user" do
          lambda do
            visit signup_path
            fill_in "Name",             :with => ""
            fill_in "Email",            :with => ""
            fill_in "Password",         :with => ""
            fill_in "Confirmation",     :with => ""
            click_button
            response.should render_template('users/new')
            response.should have_selector('div#error_explanation')
          end.should_not change(User, :count)
       end
    end
    
    describe "success" do   
      it "should make a new user" do
       lambda do
           visit signup_path
           fill_in "Name",             :with => "New User"
           fill_in "Email",            :with => "email@mail.com"
           fill_in "Password",         :with => "foobar"
           fill_in "Confirmation",     :with => "foobar"
           click_button
           response.should render_template('users/show')
           #not should redirect
           response.should have_selector('div.flash.success', :content => "Welcome")
       end.should change(User, :count).by(1)  
      end
    end
  end
      
  describe "sign in" do
     describe "failure" do   
       it "should not sign the user in" do
          visit signin_path
          fill_in "Email", :with => ""
          fill_in "Password", :with => ""
          click_button
          
          response.should have_selector('div.flash.error', :content => "Invalid")    
          response.should render_template('sessions/new')
       end  
     end 
   
     describe "success" do
      it "should sign a user in and out" do
        user = Factory(:user)
        visit signin_path
        fill_in "Email", :with => user.email
        fill_in "Password", :with => user.password
        click_button
        controller.should be_signed_in
        click_link "Sign out"
        controller.should_not be_signed_in    
        controller.current_user.should be_equal(@user)
      end  
     end
    
  end
  
  describe "facebook functionality" do
  
    before(:each) do
      #write cookie
    end
  
    describe "facebook sign in" do
      describe "success" do
        it "should sign the user in through the fb connect button and allow sign out" 
          
      end
      
      describe "failure" do
        it "should not sign the user in"
      end
    end
    
    describe "facebook register" do
      describe "success" do
        it "should make a new user"
      end
      describe "failure " do
        it "should not make a new user"
      end
    end
  end
  
end
