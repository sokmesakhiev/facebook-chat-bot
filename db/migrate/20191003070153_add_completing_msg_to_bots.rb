class AddCompletingMsgToBots < ActiveRecord::Migration
  def change
    add_column :bots, :completing_msg, :text
  end
end
