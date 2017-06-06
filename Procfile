web: bundle exec rails s -p $PORT
job: bundle exec sidekiq -e production
worker: bundle exec rake jobs:work
