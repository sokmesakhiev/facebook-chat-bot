class AddIndexBotAndNameToQuestions < ActiveRecord::Migration
  def change
    add_index :questions, [:bot_id, :name], unique: true
  end
end
