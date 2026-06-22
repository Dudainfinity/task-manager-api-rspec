module Projects
  # Computes progress statistics for a project's tasks.
  class ProgressCalculator
    def initialize(project)
      @project = project
    end

    # Integer percentage (0–100) of tasks that are done.
    def percentage
      return 0 if total.zero?

      ((done_count.to_f / total) * 100).round
    end

    # Breakdown of task counts grouped by status, always including every status key.
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
