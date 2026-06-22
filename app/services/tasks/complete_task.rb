module Tasks
  # Service object que conclui uma tarefa, retornando um pequeno objeto de valor Result.
  #
  #   result = Tasks::CompleteTask.call(task)
  #   result.success? # => true / false
  #   result.error    # => nil ou uma mensagem
  class CompleteTask
    Result = Struct.new(:success, :task, :error, keyword_init: true) do
      def success? = success
    end

    def self.call(task)
      new(task).call
    end

    def initialize(task)
      @task = task
    end

    def call
      return failure("Task is already done") if task.done?

      task.complete!
      Result.new(success: true, task: task, error: nil)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages.to_sentence)
    end

    private

    attr_reader :task

    def failure(message)
      Result.new(success: false, task: task, error: message)
    end
  end
end
