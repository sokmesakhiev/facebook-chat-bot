class AddBotToUserResponse < ActiveRecord::Migration
  def change
    add_column :user_responses, :bot_id, :integer
  end
end
