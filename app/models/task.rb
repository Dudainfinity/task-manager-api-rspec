class Task < ApplicationRecord
  belongs_to :project
  belongs_to :parent, class_name: "Task", optional: true
  has_many :subtasks, class_name: "Task", foreign_key: :parent_id, inverse_of: :parent, dependent: :destroy

  enum :status, { todo: 0, in_progress: 1, done: 2 }
  enum :priority, { low: 0, medium: 1, high: 2 }

  validates :title, presence: true, length: { minimum: 2, maximum: 150 }
  validates :status, presence: true
  validates :priority, presence: true

  before_validation :set_position, on: :create

  scope :overdue,   -> { where.not(status: statuses[:done]).where(due_date: ..Date.current - 1) }
  scope :due_today, -> { where.not(status: statuses[:done]).where(due_date: Date.current) }
  scope :ordered,   -> { order(:position, :id) }

  # Verdadeiro quando a tarefa está com o prazo vencido e ainda não foi concluída.
  def overdue?
    due_date.present? && due_date < Date.current && !done?
  end

  # Marca a tarefa como concluída e registra o horário. Idempotente:
  # retorna false se ela já estava concluída.
  def complete!
    return false if done?

    update!(status: :done, completed_at: Time.current)
  end

  # Reabre uma tarefa concluída de volta para "todo" e limpa o horário de conclusão.
  def reopen!
    return false unless done?

    update!(status: :todo, completed_at: nil)
  end

  private

  def set_position
    self.position = (project&.tasks&.maximum(:position) || 0) + 1 if position.to_i.zero?
  end
end
