class AccessGroup < ActiveRecord::Base
  has_many :the_aggregated_users, :class_name => "AccessGroupUser"
  has_one :the_primary_user, :class_name => "AccessGroupUser", :conditions => {:primary => true}, :dependent => :destroy
  has_many :list_of_users, :class_name => "AccessGroupUser", :conditions => {:primary => false}, :dependent => :destroy

  has_one :primary_user,
          :through => :the_primary_user,
          :class_name => 'User',
          :source => :user

  has_many :users,
           :through => :list_of_users,
           :class_name => 'User',
           :source => :user,
           :order => 'users.last_name, users.first_name'

  has_many :aggregated_users,
           :through => :the_aggregated_users,
           :class_name => 'User',
           :source => :user,
           :order => 'users.last_name, users.first_name'

  accepts_nested_attributes_for :primary_user
  accepts_nested_attributes_for :users
  accepts_nested_attributes_for :aggregated_users

  validates_presence_of :name, :primary_user
  validates_length_of :description, :maximum => 10.kilobytes

  scope :all, order(:name)

  def activate
    self.status = true
    save!(:validate => false)
  end

  def deactivate
    self.status = false
    save!(:validate => false)
  end
end