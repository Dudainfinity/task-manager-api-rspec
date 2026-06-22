class Project < ApplicationRecord
  belongs_to :user
  has_many :tasks, dependent: :destroy

  validates :name, presence: true, length: { minimum: 2, maximum: 120 }

  # Porcentagem (0–100) de tarefas concluídas. Delega para o service object.
  def progress
    Projects::ProgressCalculator.new(self).percentage
  end

  # Um projeto está completo quando tem tarefas e todas estão concluídas.
  def completed?
    tasks.any? && tasks.where.not(status: Task.statuses[:done]).none?
  end
end
