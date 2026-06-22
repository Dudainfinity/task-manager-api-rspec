require 'rails_helper'

RSpec.describe Projects::ProgressCalculator do
  let(:project) { create(:project) }
  subject(:calculator) { described_class.new(project) }

  describe '#percentage' do
    it 'is 0 when there are no tasks' do
      expect(calculator.percentage).to eq(0)
    end

    it 'is 100 when all tasks are done' do
      create_list(:task, 3, :done, project: project)
      expect(calculator.percentage).to eq(100)
    end

    it 'computes the rounded percentage of done tasks' do
      create_list(:task, 2, :done, project: project)
      create(:task, project: project)
      # 2 of 3 done => 66.66 -> 67
      expect(calculator.percentage).to eq(67)
    end
  end

  describe '#counts_by_status' do
    it 'returns zero for every status when empty' do
      expect(calculator.counts_by_status).to eq('todo' => 0, 'in_progress' => 0, 'done' => 0)
    end

    it 'counts tasks grouped by status, keeping all keys present' do
      create(:task, :done, project: project)
      create(:task, :in_progress, project: project)
      create(:task, :in_progress, project: project)

      expect(calculator.counts_by_status).to eq('todo' => 0, 'in_progress' => 2, 'done' => 1)
    end
  end

  describe '#total and #done_count' do
    it 'reports the totals' do
      create_list(:task, 2, :done, project: project)
      create(:task, project: project)

      expect(calculator.total).to eq(3)
      expect(calculator.done_count).to eq(2)
    end
  end
end
