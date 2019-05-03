class AddMediaImageToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :media_image, :string
  end
end
