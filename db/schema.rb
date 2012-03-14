# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120313223533) do

  create_table "column_details", :force => true do |t|
    t.string   "name"
    t.string   "unit"
    t.string   "data_type"
    t.integer  "position"
    t.integer  "data_file_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "column_details", ["data_file_id"], :name => "index_column_details_on_data_file_id"

  create_table "column_mappings", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "data_files", :force => true do |t|
    t.string   "filename"
    t.string   "format"
    t.string   "path"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "interval"
    t.string   "file_processing_status"
    t.string   "file_processing_description"
    t.integer  "experiment_id"
  end

  create_table "experiment_for_codes", :force => true do |t|
    t.integer  "experiment_id"
    t.string   "url"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "experiment_for_codes", ["experiment_id"], :name => "index_experiment_for_codes_on_experiment_id"

  create_table "experiment_parameters", :force => true do |t|
    t.integer  "experiment_id"
    t.integer  "parameter_category_id"
    t.integer  "parameter_sub_category_id"
    t.integer  "parameter_modification_id"
    t.decimal  "amount"
    t.string   "units"
    t.string   "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "experiment_parameters", ["parameter_category_id"], :name => "index_experiment_parameters_on_parameter_category_id"
  add_index "experiment_parameters", ["parameter_modification_id"], :name => "index_experiment_parameters_on_parameter_modification_id"
  add_index "experiment_parameters", ["parameter_sub_category_id"], :name => "index_experiment_parameters_on_parameter_sub_category_id"

  create_table "experiments", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.date     "start_date"
    t.date     "end_date"
    t.string   "subject"
    t.string   "access_rights"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "facility_id"
    t.integer  "parent_experiment_id"
  end

  create_table "facilities", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.float    "a_lat"
    t.float    "a_long"
    t.float    "b_lat"
    t.float    "b_long"
  end

  create_table "facility_contacts", :force => true do |t|
    t.integer  "facility_id"
    t.integer  "user_id"
    t.boolean  "primary",     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "metadata_items", :force => true do |t|
    t.string   "key"
    t.string   "value"
    t.integer  "data_file_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "metadata_items", ["data_file_id"], :name => "index_metadata_items_on_data_file_id"

  create_table "parameter_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "parameter_modifications", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "parameter_sub_categories", :force => true do |t|
    t.string   "name"
    t.integer  "parameter_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "parameter_sub_categories", ["parameter_category_id"], :name => "index_parameter_sub_categories_on_parameter_category_id"

  create_table "parameter_units", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "failed_attempts",                       :default => 0
    t.datetime "locked_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "status"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "authentication_token"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
