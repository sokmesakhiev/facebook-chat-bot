FactoryBot.define do
  factory :bot do
    name  { FFaker::Name.name }

    trait :with_simple_surveys_and_choices do
      after(:create) do |bot, evaluator|
        surveys = [
          { question_type: 'text', name: 'username', label: 'What is your name?' },
          { question_type: 'num', name: 'age', label: 'How old are you?' },
          { question_type: 'select_one', name: 'sex', label: 'What is your sex?' },
          { question_type: 'date', name: 'dob', label: 'When is your birth date?' },
          { question_type: 'select_many', name: 'favorite_foods', label: 'What are your favorite foods?' }
        ]
        surveys.each do |survey|
          bot.surveys.create!(survey)
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
          survey = bot.surveys.find_by(name: choice[:list_name])
          choice.delete(:list_name)
          survey.choices.create!(choice)
        end
      end
    end

    trait :with_skip_logic_surveys_and_choices do
      after(:create) do |bot, evaluator|
        surveys = [
          { question_type: 'select_one yes_no', name: 'likes_pizza', label: 'Do you like pizza?', relevant: '' },
          { question_type: 'select_multiple pizza_toppings', name: 'favorite_topping', label: 'Favorite toppings', relevant: '${likes_pizza} = "yes"' },
          { question_type: 'text', name: 'favorite_cheese', label: 'What is your favorite type of cheese?', relevant: 'selected(${favorite_topping}, "cheese")' },
        ]
        surveys.each do |survey|
          bot.surveys.create!(survey)
        end

        choices = [
          { list_name: 'yes_no', name: 'yes', label: 'Yes' },
          { list_name: 'yes_no', name: 'no', label: 'No' },
          { list_name: 'pizza_toppings', name: 'cheese', label: 'Cheese' },
          { list_name: 'pizza_toppings', name: 'pepperoni', label: 'Pepperoni' },
          { list_name: 'pizza_toppings', name: 'sausage', label: 'Sausage' },
        ]

        choices.each do |choice|
          survey = bot.surveys.where('question_type LIKE ? OR name = ?', "%#{choice[:list_name]}%", choice[:list_name]).first
          # binding.pry
          next if survey.nil?

          choice.delete(:list_name)
          survey.choices.create!(choice)
        end
      end
    end
  end
end
