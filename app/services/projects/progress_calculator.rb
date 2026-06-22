module Projects
  # Calcula as estatísticas de progresso das tarefas de um projeto.
  class ProgressCalculator
    def initialize(project)
      @project = project
    end

    # Porcentagem inteira (0–100) de tarefas concluídas.
    def percentage
      return 0 if total.zero?

      ((done_count.to_f / total) * 100).round
    end

    # Contagem de tarefas agrupada por status, sempre incluindo todas as chaves de status.
    def counts_by_status
      base = Task.statuses.keys.index_with(0)
      base.merge(tasks.group(:status).count)
    end

    def total
      @total ||= tasks.count
    end

    def done_count
      @done_count ||= tasks.where(status: Task.statuses[:done]).count
    end

    private

    attr_reader :project

    def tasks
      project.tasks
    end
  end
end
