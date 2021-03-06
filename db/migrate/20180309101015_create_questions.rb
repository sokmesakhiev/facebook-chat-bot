class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.integer :bot_id
      t.string :question_type
      t.string :select_name
      t.string :name
      t.string :label
      t.integer :relevant_id
      t.string :operator
      t.string :relevant_value

      t.timestamps null: false
    end
  end
end
