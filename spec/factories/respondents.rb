FactoryBot.define do
  factory :respondent do
    bot
    question
    user_session_id '11223344'
    version '1'
    state 'in-progress'
  end
end
