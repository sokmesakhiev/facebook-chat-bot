class AddVersionToQuestionUsers < ActiveRecord::Migration
  def change
    add_column :question_users, :version, :integer
  end
end
