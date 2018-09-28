class RemoveBotUserSessionAndVersionFromSurvey < ActiveRecord::Migration
  def change
    remove_column :surveys, :bot_id
    remove_column :surveys, :user_session_id
    remove_column :surveys, :version
  end
end
