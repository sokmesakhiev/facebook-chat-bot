class AddStateToRespondents < ActiveRecord::Migration
  def change
    add_column :respondents, :state, :string
  end
end
