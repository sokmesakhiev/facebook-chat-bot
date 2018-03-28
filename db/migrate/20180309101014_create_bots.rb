class CreateBots < ActiveRecord::Migration
  def change
    create_table :bots do |t|
      t.string :name
      t.string :facebook_page_id
      t.string :facebook_page_access_token
      t.string :google_access_token
      t.string :google_token_expires_at
      t.string :google_refresh_token
      t.string :google_spreadsheet_key
      t.string :google_spreadsheet_title

      t.timestamps null: false
    end
  end
end
