class Project < ApplicationRecord
  belongs_to :user
  has_many :tasks, dependent: :destroy

  validates :name, presence: true, length: { minimum: 2, maximum: 120 }

  # Percentage (0–100) of tasks that are done. Delegates to the service object.
  def progress
    Projects::ProgressCalculator.new(self).percentage
  end

  # A project is complete when it has tasks and all of them are done.
  def completed?
    tasks.any? && tasks.where.not(status: Task.statuses[:done]).none?
  end
end
