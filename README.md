# Facebook Chatbot

The Facebook Chatbot is your toolbox for building bots.

## System dependencies
  * Ruby version: 2.2.5
  * Rails version: 4.1.16
  * Mysql
  * Redis
  * Sidekiq

## Configuration
  * Register and setup [Google app](https://developers.google.com/picker/docs/)


  * Register and setup
    Facebook app for [Chatbot](https://developers.facebook.com/docs/messenger-platform/getting-started/app-setup) and [Login with Facebook](https://revs.runtime-revolution.com/working-with-facebook-using-devise-omniauth-koala-and-rails-5-cde5d032de02)

![alt text](https://raw.githubusercontent.com/sokmesakhiev/facebook-chat-bot/cf5d7c1059ea2e9c7497701c7cde5f38e06db5ae/public/fb_app.png)

## In .env file

The Client ID obtained from the Google API Console. Replace with your own Client ID.
```
GOOGLE_CLIENT_ID=client_id
GOOGLE_CLIENT_SECRET=client_secret
```

For development using localhost
```
GOOGLE_CALLBACK_URL=http://localhost:3000/oauth_callbacks
GOOGLE_CLIENT_ORIGIN=http://localhost:3000
```

The Browser API key obtained from the Google API Console.
```
GOOGLE_API_KEY=api_key
```

For login to sidekiq production, so replace with your own.
```
SIDEKIQ_USERNAME=sidekiq_username
SIDEKIQ_PASSWORD=sidekiq_pwd
```

Replace with your sql user_name and password
```
FACEBOOK_CHAT_BOT_DATABASE_USERNAME=sql_username
FACEBOOK_CHAT_BOT_DATABASE_PASSWORD=sql_password
```

Raplace token with your own token for validation with facebook webhook
```
FACEBOOK_VALIDATION_TOKEN=token
```

The app id and app secret obtained from Facebook developer by creating app.
```
FACEBOOK_APP_ID=app_id
FACEBOOK_APP_SECRET=app_secret
```

## Database creation
* For development:
```
rake db:prepare_for_dev
```
* For Test:
```
rake db:prepare_for_test
```

## How to run the test suite
To run the tests
```
rspec .
```
To run lint

```
rubocop .
```


## Run
* Install redis and start redis with
```
redis-server
```
* Start sidekiq
```
sidekiq
```
* Start project
```
rails s
```
