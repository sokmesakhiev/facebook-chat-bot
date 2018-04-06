require 'rails_helper'

RSpec.describe Question do
  it { is_expected.to belong_to(:bot) }
  it { is_expected.to belong_to(:relevant).class_name('Question').with_foreign_key(:relevant_id) }
  it { is_expected.to have_many(:choices).dependent(:destroy) }
  it { is_expected.to have_many(:question_users).with_foreign_key(:current_question_id).dependent(:destroy) }
  it { is_expected.to have_many(:user_responses).dependent(:destroy) }

  # https://github.com/thoughtbot/shoulda-matchers/issues/450
  it '#validate uniqueness' do
    bot = create(:bot)
    Question.create(name: 'username', bot_id: bot.id)

    expect(validate_uniqueness_of(:name).scoped_to(:bot_id).case_insensitive)
  end
end