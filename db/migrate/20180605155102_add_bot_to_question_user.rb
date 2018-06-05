class AddBotToQuestionUser < ActiveRecord::Migration
  def change
    add_column :question_users, :bot_id, :integer
  end
end
