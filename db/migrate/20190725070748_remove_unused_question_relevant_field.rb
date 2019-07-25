class RemoveUnusedQuestionRelevantField < ActiveRecord::Migration
  def change
    remove_column :questions, :relevant_id, :integer
    remove_column :questions, :operator, :string
    remove_column :questions, :relevant_value, :string
  end
end
