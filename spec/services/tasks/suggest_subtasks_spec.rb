require 'rails_helper'

RSpec.describe Tasks::SuggestSubtasks do
  # Lightweight stand-ins for the Anthropic SDK response objects.
  def tool_use_block(subtasks)
    instance_double('Anthropic::ToolUseBlock', type: :tool_use, input: { subtasks: subtasks })
  end

  def message_with(*blocks)
    instance_double('Anthropic::Message', content: blocks)
  end

  # Fake client exposing the same `client.messages.create(...)` surface.
  def fake_client(returning: nil, raising: nil)
    messages = instance_double('Anthropic::Resources::Messages')
    if raising
      allow(messages).to receive(:create).and_raise(raising)
    else
      allow(messages).to receive(:create).and_return(returning)
    end
    instance_double('Anthropic::Client', messages: messages)
  end

  let(:task) { build(:task, title: 'Build login page', description: 'OAuth + email') }

  describe '.call' do
    it 'returns the suggested subtasks on success' do
      message = message_with(tool_use_block([
                                              { title: 'Design the form', priority: 'medium' },
                                              { title: 'Wire up OAuth',    priority: 'high' }
                                            ]))

      result = described_class.call(task, client: fake_client(returning: message))

      expect(result).to be_success
      expect(result.error).to be_nil
      expect(result.subtasks).to eq([
                                      { title: 'Design the form', priority: 'medium' },
                                      { title: 'Wire up OAuth',    priority: 'high' }
                                    ])
    end

    it 'forces a single record_subtasks tool call on the configured model' do
      client = fake_client(returning: message_with(tool_use_block([])))

      described_class.call(task, client: client)

      expect(client.messages).to have_received(:create).with(
        hash_including(
          model: 'claude-opus-4-8',
          tool_choice: { type: 'tool', name: 'record_subtasks' }
        )
      )
    end

    it 'caps the number of suggestions' do
      many = Array.new(8) { |i| { title: "Step #{i}", priority: 'low' } }
      result = described_class.call(task, client: fake_client(returning: message_with(tool_use_block(many))))

      expect(result.subtasks.size).to eq(described_class::MAX_SUGGESTIONS)
    end

    it 'returns an empty list when no tool call is present' do
      text_block = instance_double('Anthropic::TextBlock', type: :text)
      task_without_desc = build(:task, description: nil)

      result = described_class.call(task_without_desc, client: fake_client(returning: message_with(text_block)))

      expect(result).to be_success
      expect(result.subtasks).to eq([])
    end

    it 'returns a failure result when the provider errors' do
      error = Anthropic::Errors::APIError.new(
        url: URI('https://api.anthropic.com/v1/messages'),
        message: 'rate limited'
      )

      result = described_class.call(task, client: fake_client(raising: error))

      expect(result).not_to be_success
      expect(result.subtasks).to eq([])
      expect(result.error).to eq('rate limited')
    end

    it 'builds a real Anthropic::Client when none is injected' do
      client = fake_client(returning: message_with(tool_use_block([])))
      allow(Anthropic::Client).to receive(:new).and_return(client)

      described_class.call(task)

      expect(Anthropic::Client).to have_received(:new)
    end
  end
end
