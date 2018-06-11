class AddVersionToUserResponses < ActiveRecord::Migration
  def change
    add_column :user_responses, :version, :integer
  end
end
