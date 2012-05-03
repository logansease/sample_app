require 'spec_helper'

describe "LayoutLinks" do
 
 
 describe "test links" do
   it "should have a home page at '/' " do
     get '/'
     response.should have_selector('title', :content => "Home")
   end                            
   
   it "should have a sign up page at /signup" do
      get "/signup"
      response.should have_selector('title', :content => 'Sign up')
   end    
   
   it "should have a sign in page at /signin" do
      get "/signin"
      response.should have_selector('title', :content => 'Sign in')
   end
   
   it "should have correct links int he layout" do
     visit root_path
     response.should have_selector('title', :content => "Home")
     click_link "About"
     response.should have_selector('title', :content=> "About")        
     click_link "Contact"
     response.should have_selector('title', :content=> "Contact")  
     click_link "Home"
     response.should have_selector('title', :content=> "Home")
     click_link "Sign up now!"
     response.should have_selector('title', :content=> "Sign up")    
     response.should have_selector('a[href="/"]>img')
   end
 end  
 
 describe "when not signed in" do
    it "should have a sign in link" do
       visit root_path
       response.should have_selector("a", :href => signin_path, 
                                          :content => "Sign in")
    end
 end   
 
 describe "when signed in" do
    
   #note the sign in mtd in spec helper is not available to int tests
   before(:each) do
       @user = Factory(:user)
       visit signin_path
       fill_in :email, :with => @user.email
       fill_in :password, :with => @user.password
       click_button
   end             
   
   it "should hav a sign out link" do
      visit root_path
      response.should have_selector("a", :href => signout_path, 
                                         :content => "Sign out")
   end
   
   it "should have a profile link" do
       visit root_path
       response.should have_selector("a", :href => user_path(@user), 
                                          :content => "Profile")
    end    
    
    it "should have a settings link" do
        visit root_path
        response.should have_selector("a", :href => edit_user_path(@user), 
                                           :content => "Settings")
     end    
     
     it "should have a users link" do
         visit root_path
         response.should have_selector("a", :href => users_path, 
                                            :content => "Users")
      end
   
 end

end
