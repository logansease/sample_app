require 'spec_helper'
 
#TODO better naming convention for int tests*/
describe "Microposts" do
  before(:each) do
     user = Factory(:user)
     visit signin_path
     fill_in :email, :with => user.email
     fill_in :password, :with => user.password
     click_button
  end            
  
  describe "creation" do
     describe "failure" do
        it "should not make a new post" do
        
        lambda do
          visit root_path
          fill_in :micropost_content, :with => ""
          click_button
          response.should render_template('pages/home')
          response.should have_selector('div#error_explanation')
        end.should_not change(Micropost, :count)
        end
     end        
     
     describe "success" do
        it "should make a new post" do
        
        lambda do
          visit root_path
          fill_in :micropost_content, :with => "asdfa"
          click_button
          response.should render_template('pages/home')
          response.should have_selector('span.content')
        end.should change(Micropost, :count).by(1)
        end
     end
  end
end
