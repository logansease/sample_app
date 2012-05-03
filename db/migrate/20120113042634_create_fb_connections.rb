class CreateFbConnection < ActiveRecord::Migration
  def self.up
    create_table :fb_connection do |t|
      t.integer :fbc_user_id

      t.timestamps
    end
    change_column :fb_connection, :fbc_user_id, :bigint
  end

  def self.down
    drop_table :fb_connection
  end
end
