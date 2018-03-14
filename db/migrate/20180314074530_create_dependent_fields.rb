class CreateDependentFields < ActiveRecord::Migration
  def change
    create_table :dependent_fields do |t|
      t.integer :question_id
      t.string :operator
      t.string :value
    end
  end
end
