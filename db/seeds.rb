# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).


unless %w(qa development test staging).include?(Rails.env)
  if Tag.first.present? || ParameterCategory.first.present? || Role.first.present?
    puts "----------\nYou cannot reseed an existing live deployment!\nIf something has genuinely gone wrong then this is not the way to fix it\nConsider lodging a support ticket.\n----------"
    raise StandardError, "FATAL: running db:seed more than once on a live deployment"
  end
end

require File.dirname(__FILE__) + '/seed_helper.rb'

create_sequences
create_roles
create_parameter_categories
create_tags
