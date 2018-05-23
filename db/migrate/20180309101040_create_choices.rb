class CreateChoices < ActiveRecord::Migration
  def change
    create_table :choices do |t|
      t.integer :question_id
      t.string :name
      t.string :label

      t.timestamps null: false
    end
  end
end
