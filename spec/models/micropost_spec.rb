# == Schema Information
#
# Table name: microposts
#
#  id         :integer         not null, primary key
#  content    :string(255)
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'
   
describe Micropost do 
 
  before(:each) do         
     @user = Factory(:user)
     @attr = {:content => "foobar"}   
  end                                             
  
  it "should create a new instance with valid attribs" do
     @user.microposts.create!(@attr)
  end     
  
  describe "the user associations" do   
    
    before(:each) do               
       @micropost = @user.microposts.create(@attr)
    end
    
     it "should havea  user attrib" do
        @micropost.should respond_to(:user)
     end
     
     it "should have correct assc user" do
         @micropost.user_id.should == @user.id
         @micropost.user.should == @user
     end
  end
         
  describe "validations" do
     it "should have a user id" do
         Micropost.new(@attr).should_not be_valid
     end                                         
     
     it "should require non blank content" do
        @user.microposts.build(:content => "").should_not be_valid
     end                                                          
     
     it "should reject long content" do
        a = "a" * 51
        @user.microposts.build(:content => "a" * 141).should_not be_valid
     end
  end   
  
  describe "from users followed by" do
     
     before (:each) do
        @other_user = Factory(:user, :email => Factory.next(:email))
        @third_user = Factory(:user, :email => Factory.next(:email))
        
        @user_post = @user.microposts.create!(:content => "foo") 
        @other_post = @other_user.microposts.create!(:content => "far") 
        @third_post = @third_user.microposts.create!(:content => "baz")  
        
        @user.follow!(@other_user)
        
     end
     
     it "should have a from users followed by mtd" do
        Micropost.should respond_to(:from_users_followed_by)
     end 
     
     it "should include the followed users posts" do
        Micropost.from_users_followed_by(@user).
            should include(@other_post)
     end
     
     it "should include the users own posts" do
         Micropost.from_users_followed_by(@user).
           should include(@user_post)
     end
     
     it "should not include unfollowed users micro posts" do
        Micropost.from_users_followed_by(@user).
           should_not include(@third_post)
     end
  end
  
end


