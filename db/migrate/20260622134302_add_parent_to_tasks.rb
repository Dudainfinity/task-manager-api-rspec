class AddParentToTasks < ActiveRecord::Migration[8.1]
  def change
    # Self-reference: a task may be a subtask of another task (nil = top-level).
    add_reference :tasks, :parent, null: true, foreign_key: { to_table: :tasks }
  end
end
