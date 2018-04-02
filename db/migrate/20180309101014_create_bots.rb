class CreateBots < ActiveRecord::Migration
  def change
    create_table :bots do |t|
      t.string :name
      t.integer :user_id
      t.string :facebook_page_id
      t.string :facebook_page_access_token
      t.string :google_access_token
      t.datetime :google_token_expires_at
      t.string :google_refresh_token
      t.string :google_spreadsheet_key
      t.string :google_spreadsheet_title
      t.boolean :published, default: true

      t.timestamps null: false
    end
  end
end
