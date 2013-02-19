class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.string :name
      t.integer :id
      t.integer :visits

      t.timestamps
    end
  end
end
