class Task < ApplicationRecord
  belongs_to :project

  enum :status, { todo: 0, in_progress: 1, done: 2 }
  enum :priority, { low: 0, medium: 1, high: 2 }

  validates :title, presence: true, length: { minimum: 2, maximum: 150 }
  validates :status, presence: true
  validates :priority, presence: true

  before_validation :set_position, on: :create

  scope :overdue,   -> { where.not(status: statuses[:done]).where(due_date: ..Date.current - 1) }
  scope :due_today, -> { where.not(status: statuses[:done]).where(due_date: Date.current) }
  scope :ordered,   -> { order(:position, :id) }

  # True when the task has a past due date and is not yet done.
  def overdue?
    due_date.present? && due_date < Date.current && !done?
  end

  # Marks the task as done and stamps the completion time. Idempotent-safe:
  # returns false if it was already done.
  def complete!
    return false if done?

    update!(status: :done, completed_at: Time.current)
  end

  # Reopens a completed task back to "todo" and clears the completion time.
  def reopen!
    return false unless done?

    update!(status: :todo, completed_at: nil)
  end

  private

  def set_position
    self.position = (project&.tasks&.maximum(:position) || 0) + 1 if position.to_i.zero?
  end
end
