class FbConnection < ActiveRecord::Base

  attr_accessible :fbc_fb_id, :fbc_user_id

  belongs_to :fb_friends, :foreign_key => "fbc_fb_id", :primary_key => :fb_user_id, :class_name => "User" #must specify the type

  validates :fbc_user_id, :presence => true
  validates :fbc_fb_id, :presence => true

end

# == Schema Information
#
# Table name: fb_connections
#
#  id          :integer         not null, primary key
#  fbc_user_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#  fbc_fb_id   :integer
#

