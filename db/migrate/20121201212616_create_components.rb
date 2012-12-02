class CreateComponents < ActiveRecord::Migration
  def change
    create_table :components do |t|
      t.references :idea
      t.references :parent

      t.integer :priority

      t.text :body

      t.timestamps
    end
  end
end
