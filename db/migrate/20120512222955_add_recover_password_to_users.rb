class AddRecoverPasswordToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :recover_password, :boolean, :default => false
  end

  def self.down
    remove_column :users, :recover_password
  end
end
