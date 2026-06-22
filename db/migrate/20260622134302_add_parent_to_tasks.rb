class AddParentToTasks < ActiveRecord::Migration[8.1]
  def change
    # Auto-referência: uma tarefa pode ser subtarefa de outra (nil = nível raiz).
    add_reference :tasks, :parent, null: true, foreign_key: { to_table: :tasks }
  end
end
