# == Schema Information
#
# Table name: surveys
#
#  id            :integer          not null, primary key
#  question_id   :integer
#  value         :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  respondent_id :integer
#

FactoryBot.define do
  factory :survey do
    respondent
    question
    value
  end
end
