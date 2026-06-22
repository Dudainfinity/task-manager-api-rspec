class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.text :description
      t.integer :status, null: false, default: 0
      t.integer :priority, null: false, default: 1
      t.date :due_date
      t.integer :position, null: false, default: 0
      t.datetime :completed_at
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end

    add_index :tasks, :status
    add_index :tasks, %i[project_id position]
  end
end
