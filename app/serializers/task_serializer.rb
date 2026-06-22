class TaskSerializer
  include JSONAPI::Serializer

  attributes :title, :description, :status, :priority, :due_date, :position, :completed_at

  attribute :overdue do |task|
    task.overdue?
  end

  belongs_to :project
end
