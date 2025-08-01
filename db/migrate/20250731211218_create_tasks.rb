class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.text :description
      t.string :status, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :tasks, :status
  end
end
