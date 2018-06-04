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
