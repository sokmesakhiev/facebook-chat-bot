class ChangeLabelToBeTextInQuestions < ActiveRecord::Migration
  def change
    change_column :questions, :label, :text
  end
end
