require File.dirname(__FILE__) + '/../../db/seed_helper.rb'

task seed_languages: :environment do
  seed_languages
end