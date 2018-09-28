class AddRespondentToSurvey < ActiveRecord::Migration
  def change
    add_reference :surveys, :respondent, index: true
  end
end
