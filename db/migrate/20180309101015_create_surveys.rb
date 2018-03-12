class CreateSurveys < ActiveRecord::Migration
  def change
    create_table :surveys do |t|
      t.integer :bot_id
      t.string :question_type
      t.string :name
      t.string :label
      t.string :relevant
      t.string :hint
      t.string :constraint
      t.string :constraint_message
      t.string :relevant
      t.string :calculation
      t.boolean :required, default: false
      t.string :required_message
    end
  end
end
