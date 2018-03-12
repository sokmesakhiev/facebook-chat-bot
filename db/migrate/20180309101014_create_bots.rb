class CreateBots < ActiveRecord::Migration
  def change
    create_table :bots do |t|
      t.string :name
    end
  end
end
