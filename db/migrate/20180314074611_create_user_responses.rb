class CreateUserResponses < ActiveRecord::Migration
  def change
    create_table :user_responses do |t|
      t.string :user_session_id
      t.integer :question_id
      t.string :value

      t.timestamps null: false
    end
  end
end
