class CreateQuestionUsers < ActiveRecord::Migration
  def change
    create_table :question_users do |t|
      t.string :user_session_id
      t.integer :current_question_id
    end
  end
end
