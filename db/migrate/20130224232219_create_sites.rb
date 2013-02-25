class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.string :name
      t.integer :id
      t.integer :totalvisits
      t.decimal :avgduration, :precision => 18, :scale => 3

      t.timestamps
    end
  end
end
