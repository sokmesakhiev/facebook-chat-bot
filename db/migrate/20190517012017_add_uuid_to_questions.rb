class AddUuidToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :uuid, :string, index: true
  end
end
