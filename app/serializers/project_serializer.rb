class ProjectSerializer
  include JSONAPI::Serializer

  attributes :name, :description, :created_at

  attribute :progress do |project|
    project.progress
  end

  attribute :tasks_count do |project|
    project.tasks.size
  end
end
