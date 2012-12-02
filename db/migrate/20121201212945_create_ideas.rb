class CreateIdeas < ActiveRecord::Migration
  def change
    create_table :ideas do |t|
      t.string :title

      t.references :parent

      t.integer :priority

      t.timestamps
    end
  end
end
