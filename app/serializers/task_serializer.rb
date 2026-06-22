class TaskSerializer
  include JSONAPI::Serializer

  attributes :title, :description, :status, :priority, :due_date, :position, :completed_at, :parent_id

  attribute :overdue do |task|
    task.overdue?
  end

  attribute :subtasks_count do |task|
    task.subtasks.size
  end

  belongs_to :project
end
