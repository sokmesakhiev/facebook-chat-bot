# frozen_string_literal: true

namespace :db do
  desc 'prepare to run the test'
  task prepare_for_test: :environment do
    sh 'rake db:drop RAILS_ENV=test'
    sh 'rake db:create RAILS_ENV=test'
    sh 'rake db:schema:load RAILS_ENV=test'
  end

  desc 'prepare for development'
  task prepare_for_dev: :environment do
    sh 'rake db:drop RAILS_ENV=development'
    sh 'rake db:create RAILS_ENV=development'
    sh 'rake db:migrate RAILS_ENV=development'
    sh 'rake db:seed RAILS_ENV=development'
  end
end
