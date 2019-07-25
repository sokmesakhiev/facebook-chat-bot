class AddIndexBotAndUserSessionToRespondents < ActiveRecord::Migration
  def change
    add_index :respondents, [:user_session_id, :bot_id], unique: true
  end
end
