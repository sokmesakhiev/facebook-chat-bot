FactoryBot.define do
  factory :bot do
    name  { FFaker::Name.name }
    facebook_page_id            '1512165178836125'
    facebook_page_access_token  'aabbccdd'
    published                   true

    trait :with_simple_surveys_and_choices do
      after(:create) do |bot, evaluator|
        surveys = [
          { type: Questions::TextQuestion.name, name: 'username', label: 'What is your name?' },
          { type: Questions::IntegerQuestion.name, name: 'age', label: 'How old are you?' },
          { type: Questions::SelectOneQuestion.name, select_name: 'sex', name: 'sex', label: 'What is your sex?' },
          { type: Questions::DateQuestion.name, name: 'dob', label: 'When is your birth date?' },
          { type: Questions::SelectMultipleQuestion.name, select_name: 'favorite_foods', name: 'favorite_foods', label: 'What are your favorite foods?' }
        ]
        surveys.each do |question|
          bot.questions.create!(question)
        end

        choices = [
          { list_name: 'sex', name: 'female', label: 'Female' },
          { list_name: 'sex', name: 'male', label: 'Male' },
          { list_name: 'favorite_foods', name: 'sea_food', label: 'Sea Food' },
          { list_name: 'favorite_foods', name: 'salad', label: 'Salad' },
          { list_name: 'favorite_foods', name: 'piza', label: 'Piza' },
          { list_name: 'favorite_foods', name: 'korean_food', label: 'Korean Food' }
        ]

        choices.each do |choice|
          question = bot.questions.find_by(select_name: choice[:list_name])
          choice.delete(:list_name)
          question.choices.create!(choice)
        end
      end
    end

    trait :with_skip_logic_surveys_and_choices do
      transient do
        count 4
      end

      after(:create) do |bot, evaluator|
        surveys = [
          { id: 1, type: Questions::SelectOneQuestion.name, select_name: 'yes_no', name: 'likes_pizza', label: 'Do you like pizza?' },
          { id: 2, type: Questions::SelectMultipleQuestion.name, select_name: 'pizza_toppings', name: 'favorite_topping', label: 'Favorite toppings', relevant_id: 1, operator: '==', relevant_value: 'yes' },
          { id: 3, type: Questions::TextQuestion.name, name: 'favorite_cheese', label: 'What is your favorite type of cheese?', relevant_id: 2, operator: 'selected', relevant_value: 'cheese' },
          { id: 4, type: Questions::TextQuestion.name, name: 'thank', label: 'Thank you!' }
        ]
        evaluator.count.times do |i|
          bot.questions.create!(surveys[i])
        end

        choices = [
          { list_name: 'yes_no', name: 'yes', label: 'Yes' },
          { list_name: 'yes_no', name: 'no', label: 'No' },
          { list_name: 'pizza_toppings', name: 'cheese', label: 'Cheese' },
          { list_name: 'pizza_toppings', name: 'pepperoni', label: 'Pepperoni' },
          { list_name: 'pizza_toppings', name: 'sausage', label: 'Sausage' },
        ]

        choices.each do |choice|
          question = bot.questions.find_by(select_name: choice[:list_name])
          choice.delete(:list_name)
          question.choices.create!(choice)
        end
      end
    end
  end
end
