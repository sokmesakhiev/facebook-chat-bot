class CreateBots < ActiveRecord::Migration
  def change
    create_table :bots do |t|
      t.string :name
      t.string :facebook_page_id
      t.string :facebook_page_access_token
      t.string :google_access_token
      t.string :google_spreadsheet_key
    end
  end
end
