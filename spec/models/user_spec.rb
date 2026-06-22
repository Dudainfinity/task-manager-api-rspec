require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:projects).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_least(2).is_at_most(100) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }

    it 'rejects malformed emails' do
      expect(build(:user, email: 'not-an-email')).not_to be_valid
    end
  end

  describe 'email normalization' do
    it 'downcases and strips the email before saving' do
      user = create(:user, email: '  MixedCase@Example.COM  ')
      expect(user.email).to eq('mixedcase@example.com')
    end
  end

  it 'has a valid factory' do
    expect(build(:user)).to be_valid
  end
end
