
# == Schema Information
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  salt               :string(255)
#  admin              :boolean         default(FALSE)
#  fb_user_id         :integer
#

class User < ActiveRecord::Base      
  attr_accessor  :password, :fb_access_token  #defines new getter and setter
  attr_accessible :name, :email, :password, :password_confirmation, :fb_user_id, :fb_access_token
  
  has_many :microposts, :dependent => :destroy  
  has_many :relationships, :dependent => :destroy,
                           :foreign_key => "follower_id" #since relationship table does not have user_id, must specify key to join to
  
  has_many :reverse_relationships, :dependent => :destroy,
                           :foreign_key => "followed_id",      
                           :class_name => "Relationship" #specify class / table since no rev rel table exists
                           
  has_many :fb_connections, :dependent =>:destroy,
            :foreign_key => "fbc_user_id"
  has_many :fb_friends, :through => :fb_connections, :source => :fb_friends

  has_many :following, :through => :relationships, :source => :followed #must specify join column since otherwise it assumes singluar of following
  has_many :followers, :through => :reverse_relationships, :source => :follower 
  
  email_reg_ex = /\A[\w+\-.]+@[a-z\d.]+\.[a-z]+\z/i
  
  validates :name, :presence => true,
                    :length => { :maximum => 50 }
  validates :email, :presence => true,  
                    :format => { :with => email_reg_ex},
                    :uniqueness => { :case_sensitive => false}
  
  validates :password, :presence => true,
                       :confirmation => true,
                       :length => { :within => 6..40 }   
                       
  before_save :encrypt_password
   
   ## or class << self
   ## def authenticate(       
  def User.authenticate(email, submitted_password)
     user = User.find_by_email(email); 
      
     (user && user.has_password?(submitted_password)) ? user : nil
       
  end                  
  
  def User.authenticate_with_salt(id, cookie_salt)
     user = find_by_id(id)
     (user && user.salt == cookie_salt) ? user : nil
  end
           
  def has_password?(submitted_password)
     encrypted_password == encrypt(submitted_password)
  end    
  
  def feed
     Micropost.from_users_followed_by(self)
  end   
  
  def following?(followed)
     self.relationships.find_by_followed_id(followed.id)
  end           
  
  def follow!(followed)
     relationships.create!(:followed_id => followed.id)
  end        
  
  def unfollow!(followed)
     relationships.find_by_followed_id(followed.id).destroy    
  end
  
  private 
  
    def encrypt_password      
       self.salt = make_salt if new_record?
       if(self.password && !password.blank?)
        self.encrypted_password = encrypt(self.password)
       end
    end        
    
    def encrypt(string)
       secure_hash("#{salt}--#{string}")
    end  
                
    def make_salt
       secure_hash("#{Time.now.utc}--#{password}")
    end
    
    def secure_hash(string)
       Digest::SHA2.hexdigest(string)
    end         
  
end








