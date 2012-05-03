require 'spec_helper'

describe UsersController do
              
  render_views   
  
  describe "get index" do
     
    describe "for non signed in users" do
      it "should deny access" do
          get :index
          response.should redirect_to(signin_path)
      end  
    end             
    
    
    describe "for signed in" do
       
      before(:each) do
       @user = test_sign_in(Factory(:user)) 
       Factory(:user,  :email => "test2.email@ex.com")       
       Factory(:user,  :email => "test3.email@ex.com")  
       
       30.times do 
          Factory(:user, :email => Factory.next(:email))
       end
       
      end
      
      it "should be successful" do
         get :index
         response.should be_success
      end    
      
      it "should have the right title" do
         get :index
         response.should have_selector('title', :content => "All users")
       end
      
      it "should have an element for each user" do
         get :index
         User.paginate(:page => 1).each do |user|
            response.should have_selector('li', :content => user.name)
         end
      end 
      
      it "should paginate users" do
         get :index
         response.should have_selector('div.pagination')   
         response.should have_selector('span.disabled', :content => "Previous") 
         response.should have_selector('a', :href => "/users?page=2",
                                            :content => "2")
          response.should have_selector('a', :href => "/users?page=2",
                                            :content => "Next")                                  
      end  
      
      it "should have delete links for admins" do  
               
        @user.password = "foobar"
        @user.password_confirmation = "foobar"
         @user.toggle!(:admin)   
         @user.should be_admin   
          get :index  
         other_user = User.all.second
         response.should have_selector("a", :href => user_path(other_user),
                                             :content => "delete")
        
      end    
      
      it "should not have delt links for admins" do 
        get :index 
          other_user = User.all.second
        response.should_not have_selector("a", :href => user_path(other_user),
                                            :content => "delete")
        
      end
      
    end
  end
  
  describe "get fb_new" do
    it "should be successful" do
      get :new_fb
      response.should be_successful
    end
      
    it "should have the right title" do
      get :new_fb
      response.should have_selector('title', :content => "Sign up")
    end
      
    it "should have a facebook registration form" do
      get :new_fb
      response.should have_selector("div.fb-registration")
    end
  end
  
    
  describe "post fb_create" do
    
     describe "failure" do
       
       before(:each) do
          @user = Factory(:user, :fb_user_id => nil)  
          @signed_request = 'zabadreq'
      end
                                                                                                            
       it "should redirect to the root path" do
         post :create_fb, :signed_request => @signed_request
         response.should redirect_to root_path
         
       end  

       it "should not create a user" do
         lambda do
          post :create_fb, :signed_request => @signed_request
         end.should_not change(User, :count)
       end
       
       it "should not sign the user in" do
          post :create_fb, :signed_request => @signed_request
          controller.should_not be_signed_in
       end   
     end  
     
     describe "success" do
       before(:each) do
          @user = Factory(:user)  
          @fb_id = @user.fb_user_id
          @user.fb_user_id = nil
          @user.save!
          #@params = { "registration" => { "name" => @user.name, "email" => @user.email }, "user_id" => @fb_id  }
          @signed_request = '5L_A1ZVopgS9j18eu2r0Q-95IWmjnpDZ7yQMfRYCbIU.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjAsImlzc3VlZF9hdCI6MTMyNDg2NjEzMywib2F1dGhfdG9rZW4iOiJBQUFDanN5UnAyR29CQUlaQ05qRmFxeTZkY1pDWkNaQWtNajFnRWZqSlE4eVU4UmRjMmR1WkN6ZE5URFh6MlpBQjJMNnllNmdENGxSbW1qY3paQ2FOTVAxYkc4ZjBUZlNSYnNaRCIsInJlZ2lzdHJhdGlvbiI6eyJuYW1lIjoiTG9nYW4gU2Vhc2UiLCJlbWFpbCI6ImxvZ2Fuc2Vhc2VcdTAwNDB5YWhvby5jb20ifSwicmVnaXN0cmF0aW9uX21ldGFkYXRhIjp7ImZpZWxkcyI6Ilt7J25hbWUnOiduYW1lJ30sIHsnbmFtZSc6J2VtYWlsJ31dIn0sInVzZXIiOnsiY291bnRyeSI6InVzIiwibG9jYWxlIjoiZW5fVVMifSwidXNlcl9pZCI6IjYyMDYxOTcifQ'      
          @token = 'AAACjsyRp2GoBAIZCNjFaqy6dcZCZCZAkMj1gEfjJQ8yU8Rdc2duZCzdNTDXz2ZAB2L6ye6gD4lRmmjczZCaNMP1bG8f0TfSRbsZD'
       end
              
                
       it "should create a user linked to a fb account" do
          lambda do
            post :create_fb, :signed_request => @signed_request#, :data => @params}
         end.should change(User, :count).by(1)
       end  
       
       it "should have a welcome message" 

       it "should sign the user in" do
         post :create_fb, :signed_request => @signed_request
         controller.should be_signed_in
       end

       it "should store the access token to the controller" do
          post :create_fb, :signed_request => @signed_request
         controller.fb_access_token.should == @token
       end

       it "should load the users facebook friends"  do
         post :create_fb, :signed_request => @signed_request
         controller.current_user.fb_connections.should_not be_empty
       end

    end
    
    describe "success when email is taken" do
      
       before(:each) do
          @user = Factory(:user, :email => "logansease@yahoo.com", :fb_user_id => nil)  
          @fb_id = 6206197
          @signed_request = '5L_A1ZVopgS9j18eu2r0Q-95IWmjnpDZ7yQMfRYCbIU.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjAsImlzc3VlZF9hdCI6MTMyNDg2NjEzMywib2F1dGhfdG9rZW4iOiJBQUFDanN5UnAyR29CQUlaQ05qRmFxeTZkY1pDWkNaQWtNajFnRWZqSlE4eVU4UmRjMmR1WkN6ZE5URFh6MlpBQjJMNnllNmdENGxSbW1qY3paQ2FOTVAxYkc4ZjBUZlNSYnNaRCIsInJlZ2lzdHJhdGlvbiI6eyJuYW1lIjoiTG9nYW4gU2Vhc2UiLCJlbWFpbCI6ImxvZ2Fuc2Vhc2VcdTAwNDB5YWhvby5jb20ifSwicmVnaXN0cmF0aW9uX21ldGFkYXRhIjp7ImZpZWxkcyI6Ilt7J25hbWUnOiduYW1lJ30sIHsnbmFtZSc6J2VtYWlsJ31dIn0sInVzZXIiOnsiY291bnRyeSI6InVzIiwibG9jYWxlIjoiZW5fVVMifSwidXNlcl9pZCI6IjYyMDYxOTcifQ'      
          @token =  "AAACjsyRp2GoBAIZCNjFaqy6dcZCZCZAkMj1gEfjJQ8yU8Rdc2duZCzdNTDXz2ZAB2L6ye6gD4lRmmjczZCaNMP1bG8f0TfSRbsZD"
      end
      
      it "should link to the user with the email specified" do
        post :create_fb, :signed_request => @signed_request
        @user.reload
        @user.fb_user_id.should == @fb_id
      end
      
      it "should sign the user in" do
         post :create_fb, :signed_request => @signed_request
         controller.should be_signed_in
         controller.current_user.should == @user
      end

      it "should load the users facebook friends" do
         post :create_fb, :signed_request => @signed_request
        controller.current_user.fb_connections.should_not be_empty
      end

      it "should set the access token" do
         post :create_fb, :signed_request => @signed_request
        controller.fb_access_token.should == @token

      end
      
      it "should not create a new user" do
        lambda do 
          post :create_fb, :signed_request => @signed_request        
        end.should_not change(User, :count)
      end
      it "should not change the users password" do
        password = @user.encrypted_password
        post :create_fb, :signed_request => @signed_request 
        @user.reload
        password.should == @user.encrypted_password
      end
      
    end
    
  end
  

  describe "GET 'new'" do
    it "should be successful" do
      get :new
      response.should be_success
    end       
    
    it "should have the right title" do
      get :new
      response.should have_selector('title', :content => "Sign up")
    end   
  end     
  
 
  describe "get show" do     
    
    before(:each) do
       @user=Factory(:user)
    end
    
     it "should be successful do" do
       get :show, :id => @user.id
       response.should be_success
     end          
     
     it "should find the right user" do
        get :show, :id => @user
        assigns(:user).should == @user
     end       
     
     it "should have the users name" do
        get :show, :id => @user
        response.should have_selector('h1', :content => @user.name)
     end   
     
     it "should have a profile image" do
        get :show, :id => @user
        response.should have_selector('h1>img', :class => "gravatar")
     end   
     
     it "should have a correct url" do
         get :show, :id => @user
         response.should have_selector('td>a', :content => user_path(@user), 
                                                :href => user_path(@user))
     end
            
     it "should show the users microposts" do
        mp1 = Factory(:micropost, :user => @user, :content => "new content")
        mp2 = Factory(:micropost, :user => @user, :content => "foo zzz") 
        
        get :show, :id => @user
        response.should have_selector('span.content', :content => mp1.content)
        response.should have_selector('span.content', :content => mp2.content) 
     end    
     
     it "should paginate microposts" do         
       50.times { Factory(:micropost, :user => @user)}     
        get :show, :id => @user
        response.should have_selector('div.pagination')                                   
     end      
     
     it "should display the micropost count" do
        10.times { Factory(:micropost, :user => @user)}     
        get :show, :id => @user
        response.should have_selector('td.sidebar',
                                      :content => @user.microposts.count.to_s)
     
     end  
     
     describe "when signed in as another user" do
        it "should be successful" do
           test_sign_in(Factory(:user, :email => Factory.next(:email) )) 
           get :show, :id => @user
           response.should be_successful
        end
     end
     
  end 
  
  describe "post create" do
     describe "failure" do
       
       before(:each) do
          @attr = { :name => "", :email => "", :password => "", :password_confirmation => ""}
       end          
                                                                                            
       it "should have the right title" do
          post :create, :user => @attr
          response.should have_selector('title', :content => "Sign up")
       end
       
       it "should render the new page"  do
          post :create, :user => @attr
          response.should render_template('new')
       end
       
       it "should not create a user" do
          lambda do
              post :create, :user => @attr  
          end.should_not change(User, :count)
                    
       end     
       
     end  
     
     describe "success" do
        
       before(:each) do
          @attr = {:name => "New User", :email => "email@l.com", 
                    :password => "foobar", :password_confirmation => "foobar"}  
                  
       end        
       
       it "should create a user" do
          lambda do
             post :create, :user => @attr
          end.should change(User, :count).by(1)
         
       end
            
       it "should redirect to user show page" do
          post :create, :user => @attr         
          user_saved = assigns(:user)
          response.should redirect_to(user_path(user_saved))
       end   
       
       it "should have a welcome message" do
          post :create, :user => @attr
          flash[:success].should =~ /welcome to the sample app/i
       end          
       
       it "should sign the user in" do
           post :create, :user => @attr 
           controller.should be_signed_in
       end
      
     end
     
  end   
  
  describe "get edit" do
     
     before(:each) do
        @user = Factory(:user)
        test_sign_in(@user)
     end
                          
     it "should be successful" do
        get :edit, :id => @user
        response.should be_success
     end
     
     it "should have correct title" do
        get :edit, :id => @user
        response.should have_selector('title', :content => "Edit user")
     end                              
        
     it "should have a link to gravitar" do
        get :edit, :id => @user
        response.should have_selector('a', :href => "http://gravatar.com/emails",
                                            :content => "change")
     end
    
  end      
  
  describe "put update" do   
    
     before(:each) do
           @user = Factory(:user)
           test_sign_in(@user)
     end     
     
     describe "failure" do   
       
       before(:each) do
             @attr = {:name => "", :email => "", 
                   :password => "", :password_confirmation => ""}
       end
            
         it "should render the edit page" do
            put :update, :id => @user, :user => @attr
            response.should render_template('edit')
         end   
         
         it "should have the right title" do
            put :update, :id => @user, :user => @attr
             response.should have_selector('title', :content => "Edit user")  
         end
     end  
     
     describe "success" do  
       
        before(:each) do
             @attr = {:name => "new name2", :email => "newemail@a.com", 
                   :password => "foobar2", :password_confirmation => "foobar2"}
       end      
       
       it "should change user attributes" do
          put :update, :id => @user, :user => @attr
          user2 = assigns(:user) #get the user from the controller
          @user.reload
          @user.name.should == user2.name
          @user.email.should == user2.email
          @user.encrypted_password.should == user2.encrypted_password
       end    
       
       it "should have a flash message" do
          put :update, :id => @user, :user => @attr
          flash[:success].should =~ /updated/i
       end
       

     end
  end     
  
  describe "authentication of edit/update actions" do   
    
    before(:each) do
          @user = Factory(:user)
    end
     
    describe "for non signed in users" do
      it "should deny access to 'edit'" do
         get :edit, :id => @user          
         response.should redirect_to signin_path 
         flash[:notice].should =~ /sign in/i #=~ is reg exp matcher   
      end    

      it "should deny access to 'update'" do
         put :update, :id => @user, :user => {}          
         response.should redirect_to signin_path
      end     
    end
           
    describe "for signed in users" do
     
       before(:each) do
          wrong_user = Factory(:user, :email => "wrong@email.com") 
          test_sign_in(wrong_user)
       end                        
       
       it "should require matching users for edit" do
          get :edit, :id => @user
          response.should redirect_to(root_path)
       end  
       
       it "should require matching users for update" do
          put :update, :id => @user
          response.should redirect_to(root_path)
       end
      
      
    end
    
  end
     
  describe "delete destroy" do 
    before(:each) do
      @user = Factory(:user)
    end
    
    describe "as a non signed in user" do
       it "should deny access" do
          delete :destroy, :id => @user
          response.should redirect_to(signin_path)
       end
         
    end    
    
    describe "as a non-admin user" do
       it "should protect the action" do
          test_sign_in(@user)
          delete :destroy, :id => @user
          response.should redirect_to(root_path)
       end
    end
    
    describe "as a signed in user" do    
      
      before(:each) do
         @admin = Factory(:user, :email => "newemail@gmail.com",
                                :admin => true)
         test_sign_in(@admin)
      end
      
       it "should destroy the user" do
           lambda do
             delete :destroy, :id => @user
           end.should change(User, :count).by(-1)
       end
       
       it "should redirect to the users page" do
          delete :destroy, :id => @user        
          flash[:success] =~ /deleted/i
          response.should redirect_to(users_path)
       end   
       
       it "should not be able to destroy itself" do
          
          lambda do
               delete :destroy, :id => @admin 
          end.should_not change(User, :count)  
       end
    end
    
  end  
  
  describe "follow pages" do
     describe "when not signed in" do
        it " should protect follwing" do
          get :following, :id => 1
          response.should redirect_to(signin_path)
        end     
        it " should protect followers" do
          get :followers, :id => 1
          response.should redirect_to(signin_path)
        end     
     end 
     describe "when signed in" do
        before (:each) do
           @user = test_sign_in(Factory(:user))
           @other_user = Factory(:user, :email => Factory.next(:email)) 
           @user.follow!(@other_user)
        end  
        
        it "should show the user following" do
           get :following, :id => @user
           response.should have_selector('a', :href => user_path(@other_user),
                                          :content => @other_user.name)
        end   
        
        it "should show the user followers" do
           get :followers, :id => @other_user
           response.should have_selector('a', :href => user_path(@user),
                                          :content => @user.name)
        end
     end
    
  end
  
  describe "post fb_unlink action" do
    describe "unlinking" do
      before (:each) do
        @user = test_sign_in(Factory(:user, :fb_user_id =>1))
        @user2 = Factory(:user, :email => Factory.next(:email), :fb_user_id =>21)
        @fb_connection = FbConnection.create(:fbc_user_id =>@user.id, :fbc_fb_id => 21)
      end
      
      it "should unlink the fb user" do
        post :fb_unlink, {  :id => @user, :fb_user_id => ""}
        @user.reload
        @user.fb_user_id.should be_nil
      end
      
      it "should redirect to the edit page" do
        post :fb_unlink, {  :id => @user, :fb_user_id => ""}
        response.should redirect_to(edit_user_path)
      end

      it "should clear the fb access token" do
        session[:fb_access_token] = "12312"
        post :fb_unlink, {  :id => @user, :fb_user_id => ""}
        session[:fb_access_token].should be_nil
      end

      it "should remove the users facebook friends" do
        controller.current_user.fb_friends.should_not be_empty
        post :fb_unlink, {  :id => @user, :fb_user_id => ""}
        controller.current_user.fb_friends.should be_empty
      end

    end
    
    describe "linking" do
      before (:each) do
        @user = test_sign_in(Factory(:user, :fb_user_id => nil))
      end
      
   #   it "should link the fb user" do
   #     post :fb_unlink, {  :id => @user, :fb_user_id => "1"}
   #     @user.reload
   #     @user.fb_user_id.should == 1
   #  end
      
   #   it "should redirect to the edit page" do
   #     post :fb_unlink, {  :id => @user, :fb_user_id => "1"}
   #     response.should redirect_to(edit_user_path)
   #   end
    end
    
    
    
  end
  

end
