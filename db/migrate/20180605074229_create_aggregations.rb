class CreateAggregations < ActiveRecord::Migration
  def change
    create_table :aggregations do |t|
      t.string :name
      t.decimal :score_from
      t.decimal :score_to
      t.string :result
      t.integer :bot_id

      t.timestamps
    end
  end
end
