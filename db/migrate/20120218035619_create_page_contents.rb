class CreatePageContents < ActiveRecord::Migration
  def self.up
    create_table :page_contents do |t|
      t.integer :page_id
      t.text :content_text

      t.timestamps
    end
  end

  def self.down
    drop_table :page_contents
  end
end
