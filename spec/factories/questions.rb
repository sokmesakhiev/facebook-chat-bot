# == Schema Information
#
# Table name: questions
#
#  id             :integer          not null, primary key
#  bot_id         :integer
#  type           :string(255)
#  select_name    :string(255)
#  name           :string(255)
#  label          :text
#  relevant_id    :integer
#  operator       :string(255)
#  relevant_value :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  media_image    :string(255)
#  description    :text
#  required       :boolean          default(FALSE)
#  uuid           :string(255)
#

FactoryBot.define do
  factory :question do
    name { FFaker::Name.name }
    bot

    trait :integer do
      label 'integer'
      type Questions::IntegerQuestion.name
    end

    trait :date do
      label 'date'
      type Questions::DateQuestion.name
    end

    trait :text do
      label 'text'
      type Questions::TextQuestion.name
    end

    trait :select_one do
      select_name { FFaker::Name.name }
      label 'select_one'
      type Questions::SelectOneQuestion.name
    end

    trait :select_multiple do
      select_name { FFaker::Name.name }
      label 'select_multiple'
      type Questions::SelectMultipleQuestion.name
    end

    trait :unknown do
      label 'unknown'
      type 'unknown'
    end
  end

  factory :text_question, parent: :question, class: 'Questions::TextQuestion' do

  end

  factory :select_one_question, parent: :question, class: 'Questions::SelectOneQuestion' do
    
  end
end
