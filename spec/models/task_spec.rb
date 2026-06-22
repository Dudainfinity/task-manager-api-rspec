require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:project) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(todo: 0, in_progress: 1, done: 2) }
    it { is_expected.to define_enum_for(:priority).with_values(low: 0, medium: 1, high: 2) }
  end

  describe 'validations' do
    subject { build(:task) }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_length_of(:title).is_at_least(2).is_at_most(150) }
  end

  it 'has a valid factory' do
    expect(build(:task)).to be_valid
  end

  describe 'position auto-assignment' do
    let(:project) { create(:project) }

    it 'assigns 1 to the first task' do
      expect(create(:task, project: project).position).to eq(1)
    end

    it 'increments the position for subsequent tasks' do
      create(:task, project: project)
      expect(create(:task, project: project).position).to eq(2)
    end

    it 'respects an explicitly provided position' do
      expect(create(:task, project: project, position: 9).position).to eq(9)
    end
  end

  describe 'scopes' do
    let(:project) { create(:project) }
    let!(:overdue_task)  { create(:task, :overdue, project: project) }
    let!(:done_task)     { create(:task, :done, due_date: Date.current - 5, project: project) }
    let!(:today_task)    { create(:task, project: project, due_date: Date.current) }

    it '.overdue returns past-due tasks that are not done' do
      expect(project.tasks.overdue).to contain_exactly(overdue_task)
    end

    it '.due_today returns tasks due today and not done' do
      expect(project.tasks.due_today).to contain_exactly(today_task)
    end

    it '.ordered sorts by position' do
      expect(project.tasks.ordered.to_a).to eq(project.tasks.order(:position, :id).to_a)
    end
  end

  describe '#overdue?' do
    it 'is true for a past-due, unfinished task' do
      expect(build(:task, due_date: Date.current - 1)).to be_overdue
    end

    it 'is false when there is no due date' do
      expect(build(:task, due_date: nil)).not_to be_overdue
    end

    it 'is false when the task is already done' do
      expect(build(:task, :done, due_date: Date.current - 1)).not_to be_overdue
    end
  end

  describe '#complete!' do
    it 'marks the task as done and stamps completed_at' do
      task = create(:task)
      expect(task.complete!).to be_truthy
      expect(task).to be_done
      expect(task.completed_at).to be_present
    end

    it 'returns false when the task is already done' do
      expect(create(:task, :done).complete!).to be(false)
    end
  end

  describe '#reopen!' do
    it 'moves a done task back to todo and clears completed_at' do
      task = create(:task, :done)
      expect(task.reopen!).to be_truthy
      expect(task).to be_todo
      expect(task.completed_at).to be_nil
    end

    it 'returns false when the task is not done' do
      expect(create(:task).reopen!).to be(false)
    end
  end
end
