FactoryBot.define do
  factory :bot do
    name  { FFaker::Name.name }

    trait :with_simple_surveys_and_choices do
      after(:create) do |bot, evaluator|
        surveys = [
          { question_type: 'text', name: 'username', label: 'What is your name?' },
          { question_type: 'num', name: 'age', label: 'How old are you?' },
          { question_type: 'select_one', select_name: 'sex', name: 'sex', label: 'What is your sex?' },
          { question_type: 'date', name: 'dob', label: 'When is your birth date?' },
          { question_type: 'select_many', select_name: 'favorite_foods', name: 'favorite_foods', label: 'What are your favorite foods?' }
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
      facebook_page_id            '1512165178836125'
      facebook_page_access_token  'token'

      after(:create) do |bot, evaluator|
        surveys = [
          { id: 1, question_type: 'select_one', select_name: 'yes_no', name: 'likes_pizza', label: 'Do you like pizza?' },
          { id: 2, question_type: 'select_multiple', select_name: 'pizza_toppings', name: 'favorite_topping', label: 'Favorite toppings', relevant_id: 1, operator: '==', relevant_value: 'yes' },
          { id: 3, question_type: 'text', name: 'favorite_cheese', label: 'What is your favorite type of cheese?', relevant_id: 2, operator: 'selected', relevant_value: 'cheese' },
          { id: 4, question_type: 'text', name: 'thank', label: 'Thank you!' }
        ]
        surveys.each do |question|
          bot.questions.create!(question)
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
