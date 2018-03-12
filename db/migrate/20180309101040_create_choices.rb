class CreateChoices < ActiveRecord::Migration
  def change
    create_table :choices do |t|
      t.integer :survey_id
      t.string :name
      t.string :label
    end
  end
end
