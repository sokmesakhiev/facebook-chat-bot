class RenameQuestionUserToRespondent < ActiveRecord::Migration
  def change
    rename_table :question_users, :respondents
  end
end
