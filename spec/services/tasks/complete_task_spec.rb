require 'rails_helper'

RSpec.describe Tasks::CompleteTask do
  describe '.call' do
    context 'when the task is not yet done' do
      let(:task) { create(:task) }

      it 'succeeds' do
        result = described_class.call(task)
        expect(result).to be_success
        expect(result.error).to be_nil
      end

      it 'marks the task as done and stamps completed_at' do
        described_class.call(task)
        expect(task.reload).to be_done
        expect(task.completed_at).to be_present
      end
    end

    context 'when the task is already done' do
      let(:task) { create(:task, :done) }

      it 'fails with an explanatory error' do
        result = described_class.call(task)
        expect(result).not_to be_success
        expect(result.error).to eq('Task is already done')
      end

      it 'does not change the original completion time' do
        original = task.completed_at
        described_class.call(task)
        expect(task.reload.completed_at).to be_within(1.second).of(original)
      end
    end

    context 'when persistence fails' do
      let(:task) { create(:task) }

      it 'returns a failure result with the validation message' do
        invalid = build(:task)
        invalid.errors.add(:base, 'boom')
        allow(task).to receive(:complete!).and_raise(ActiveRecord::RecordInvalid.new(invalid))

        result = described_class.call(task)
        expect(result).not_to be_success
        expect(result.error).to include('boom')
      end
    end
  end
end
