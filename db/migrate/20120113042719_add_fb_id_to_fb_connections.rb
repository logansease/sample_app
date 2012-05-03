class AddFbIdToFbConnection < ActiveRecord::Migration
  def self.up
    add_column :fb_connection, :fbc_fb_id, :bigint
  end

  def self.down
    remove_column :fb_connection, :fbc_fb_id
  end
end
