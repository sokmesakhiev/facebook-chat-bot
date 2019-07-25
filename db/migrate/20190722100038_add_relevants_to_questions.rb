class AddRelevantsToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :relevants, :text
  end
end
