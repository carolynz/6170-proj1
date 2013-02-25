class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.references :site
      t.string :url
      t.integer :totalvisits
      t.decimal :avgduration, :precision => 18, :scale => 3

      t.timestamps
    end
  end
end
