class AddFbIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :fb_user_id, :bigint
  end

  def self.down
    remove_column :users, :fb_user_id
  end
end
