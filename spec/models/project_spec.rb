require 'rails_helper'

RSpec.describe Project, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:tasks).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:project) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_least(2).is_at_most(120) }
  end

  it 'has a valid factory' do
    expect(build(:project)).to be_valid
  end

  describe '#progress' do
    it 'returns 0 for a project with no tasks' do
      expect(create(:project).progress).to eq(0)
    end

    it 'delegates to the ProgressCalculator' do
      project = create(:project)
      create(:task, :done, project: project)
      create(:task, project: project)
      expect(project.progress).to eq(50)
    end
  end

  describe '#completed?' do
    let(:project) { create(:project) }

    it 'is false when there are no tasks' do
      expect(project).not_to be_completed
    end

    it 'is false when some tasks are not done' do
      create(:task, :done, project: project)
      create(:task, project: project)
      expect(project).not_to be_completed
    end

    it 'is true when every task is done' do
      create(:task, :done, project: project)
      create(:task, :done, project: project)
      expect(project).to be_completed
    end
  end
end
