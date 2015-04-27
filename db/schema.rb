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

ActiveRecord::Schema.define(:version => 20150427062716) do

  create_table "access_group_users", :force => true do |t|
    t.integer  "access_group_id"
    t.integer  "user_id"
    t.boolean  "primary",         :default => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  create_table "access_groups", :force => true do |t|
    t.string   "name"
    t.boolean  "status",      :default => true
    t.text     "description"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "bootsy_image_galleries", :force => true do |t|
    t.integer  "bootsy_resource_id"
    t.string   "bootsy_resource_type"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "bootsy_images", :force => true do |t|
    t.string   "image_file"
    t.integer  "image_gallery_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "column_details", :force => true do |t|
    t.string   "name"
    t.string   "unit"
    t.string   "data_type"
    t.integer  "position"
    t.integer  "data_file_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "column_details", ["data_file_id"], :name => "index_column_details_on_data_file_id"

  create_table "column_mappings", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "data_file_labels", :id => false, :force => true do |t|
    t.integer "data_file_id"
    t.integer "label_id"
  end

  create_table "data_file_relationships", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "child_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "data_files", :force => true do |t|
    t.string   "filename",                          :default => ""
    t.string   "format"
    t.text     "path"
    t.datetime "created_at",                                               :null => false
    t.datetime "updated_at",                                               :null => false
    t.integer  "created_by_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "interval"
    t.string   "file_processing_status"
    t.text     "file_processing_description",       :default => ""
    t.integer  "experiment_id"
    t.float    "file_size"
    t.boolean  "published",                         :default => false
    t.datetime "published_date"
    t.integer  "published_by_id"
    t.text     "external_id",                       :default => ""
    t.text     "title",                             :default => ""
    t.string   "transfer_status"
    t.string   "uuid"
    t.text     "access",                            :default => "Private"
    t.boolean  "access_to_all_institutional_users", :default => true
    t.boolean  "access_to_user_groups"
  end

  create_table "data_files_tags", :id => false, :force => true do |t|
    t.integer "data_file_id"
    t.integer "tag_id"
  end

  create_table "data_files_users", :id => false, :force => true do |t|
    t.integer "data_file_id", :null => false
    t.integer "user_id",      :null => false
  end

  add_index "data_files_users", ["data_file_id", "user_id"], :name => "index_data_files_users_on_data_file_id_and_user_id"

  create_table "datafile_accesses", :force => true do |t|
    t.integer  "data_file_id"
    t.integer  "access_group_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "experiment_for_codes", :force => true do |t|
    t.integer  "experiment_id"
    t.string   "url"
    t.string   "name"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "experiment_for_codes", ["experiment_id"], :name => "index_experiment_for_codes_on_experiment_id"

  create_table "experiment_parameters", :force => true do |t|
    t.integer  "experiment_id"
    t.integer  "parameter_category_id"
    t.integer  "parameter_sub_category_id"
    t.integer  "parameter_modification_id"
    t.decimal  "amount"
    t.string   "comments"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "parameter_unit_id"
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
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.integer  "facility_id"
    t.integer  "parent_experiment_id"
  end

  create_table "facilities", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
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
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "labels", :force => true do |t|
    t.string "name"
  end

  create_table "metadata_items", :force => true do |t|
    t.string   "key"
    t.string   "value"
    t.integer  "data_file_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "metadata_items", ["data_file_id"], :name => "index_metadata_items_on_data_file_id"

  create_table "parameter_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "parameter_modifications", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "parameter_sub_categories", :force => true do |t|
    t.string   "name"
    t.integer  "parameter_category_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "parameter_sub_categories", ["parameter_category_id"], :name => "index_parameter_sub_categories_on_parameter_category_id"

  create_table "parameter_units", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "system_configurations", :force => true do |t|
    t.string   "name",                               :default => "DIVER"
    t.datetime "created_at",                                                                             :null => false
    t.datetime "updated_at",                                                                             :null => false
    t.string   "level1",                             :default => "Facility"
    t.string   "level1_plural",                      :default => "Facilities"
    t.string   "level2",                             :default => "Experiment"
    t.string   "level2_plural",                      :default => "Experiments"
    t.string   "research_centre_name", :limit => 80, :default => "Enter your research centre name here", :null => false
    t.string   "entity",               :limit => 80, :default => "Enter your institution name here",     :null => false
    t.string   "address1",             :limit => 80, :default => "Enter your address"
    t.string   "address2",             :limit => 80, :default => ""
    t.string   "address3",             :limit => 80, :default => ""
    t.string   "telephone_number",     :limit => 80, :default => ""
    t.string   "email",                :limit => 80, :default => ""
    t.string   "description",          :limit => 80, :default => ""
    t.string   "urls",                 :limit => 80, :default => ""
    t.boolean  "level2_parameters",                  :default => true
    t.boolean  "auto_ocr_on_upload",                 :default => false
    t.text     "auto_ocr_regex"
    t.boolean  "auto_sr_on_upload",                  :default => false
    t.text     "auto_sr_regex"
    t.text     "ocr_types",                          :default => "image/jpeg, image/png"
    t.text     "sr_types",                           :default => "audio/x-wav, audio/mpeg"
    t.string   "ocr_cloud_host"
    t.string   "ocr_cloud_id"
    t.string   "ocr_cloud_token"
    t.string   "sr_cloud_host"
    t.string   "sr_cloud_id"
    t.string   "sr_cloud_token"
    t.text     "dashboard_contents"
  end

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
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
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
    t.string   "authentication_token"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
