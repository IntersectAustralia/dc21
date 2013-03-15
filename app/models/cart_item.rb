class CartItem < ActiveRecord::Base
  belongs_to :data_file
  belongs_to :user
  attr_accessible :user_id, :data_file_id

  validates_uniqueness_of :data_file_id, :scope => [:user_id]
  validates_presence_of :data_file_id
  validates_presence_of :user_id

  scope :data_file_with_earliest_start_time, lambda { |user_id| where("cart_items.user_id" => user_id).joins(:data_file).merge(DataFile.earliest_start_time) }
  scope :data_file_with_latest_end_time, lambda { |user_id| where("cart_items.user_id" => user_id).joins(:data_file).merge(DataFile.latest_end_time)}
end
