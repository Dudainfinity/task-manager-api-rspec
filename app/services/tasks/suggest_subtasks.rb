module Tasks
  # Uses Claude (Anthropic API) to break a task down into suggested subtasks.
  #
  #   result = Tasks::SuggestSubtasks.call(task)
  #   result.success?  # => true / false
  #   result.subtasks  # => [{ title: "...", priority: "high" }, ...]
  #   result.error     # => nil or a provider error message
  #
  # Structured output is guaranteed by forcing a single tool call, so the
  # response is always a validated list of subtasks (no brittle text parsing).
  class SuggestSubtasks
    MODEL = "claude-opus-4-8".freeze
    MAX_SUGGESTIONS = 5

    Result = Struct.new(:success, :subtasks, :error, keyword_init: true) do
      def success? = success
    end

    TOOL = {
      name: "record_subtasks",
      description: "Record the list of suggested subtasks for the given task.",
      input_schema: {
        type: "object",
        properties: {
          subtasks: {
            type: "array",
            items: {
              type: "object",
              properties: {
                title: { type: "string", description: "Short, actionable subtask title" },
                priority: { type: "string", enum: %w[low medium high] }
              },
              required: %w[title priority],
              additionalProperties: false
            }
          }
        },
        required: %w[subtasks],
        additionalProperties: false
      }
    }.freeze

    def self.call(task, client: nil)
      new(task, client: client).call
    end

    def initialize(task, client: nil)
      @task = task
      @client = client || Anthropic::Client.new
    end

    def call
      message = @client.messages.create(
        model: MODEL,
        max_tokens: 1024,
        tools: [ TOOL ],
        tool_choice: { type: "tool", name: "record_subtasks" },
        messages: [ { role: "user", content: prompt } ]
      )

      Result.new(success: true, subtasks: extract_subtasks(message), error: nil)
    rescue Anthropic::Errors::APIError => e
      Result.new(success: false, subtasks: [], error: e.message)
    end

    private

    def prompt
      lines = [
        "Break the following task into up to #{MAX_SUGGESTIONS} concrete, actionable subtasks.",
        "Task title: #{@task.title}"
      ]
      lines << "Description: #{@task.description}" if @task.description.present?
      lines << "Call the record_subtasks tool with a short title and a priority " \
               "(low, medium, or high) for each subtask."
      lines.join("\n")
    end

    def extract_subtasks(message)
      block = message.content.find { |content_block| content_block.type == :tool_use }
      return [] if block.nil?

      items = block.input.to_h.deep_symbolize_keys[:subtasks] || []
      items.first(MAX_SUGGESTIONS).map do |item|
        { title: item[:title].to_s, priority: item[:priority].to_s }
      end
    end
  end
end
