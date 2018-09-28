class RenameUserResponseToSurvey < ActiveRecord::Migration
  def change
    rename_table :user_responses, :surveys
  end
end
