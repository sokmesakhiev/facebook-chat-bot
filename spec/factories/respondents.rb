# == Schema Information
#
# Table name: respondents
#
#  id                  :integer          not null, primary key
#  user_session_id     :string(255)
#  current_question_id :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  bot_id              :integer
#  version             :integer
#  state               :string(255)
#

FactoryBot.define do
  factory :respondent do
    bot
    question
    user_session_id '11223344'
    version '1'
    state 'in-progress'
  end
end
