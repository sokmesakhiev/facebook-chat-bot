class AddIndexQuestionAndRespondentToSurveys < ActiveRecord::Migration
  def change
    add_index :surveys, [:question_id, :respondent_id], unique: true
  end
end
