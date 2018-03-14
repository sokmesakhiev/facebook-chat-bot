class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.integer :bot_id
      t.string :question_type
      t.string :select_name
      t.string :name
      t.string :label
    end
  end
end
