class Role < ActiveRecord::Base

  ADMIN_ROLE = 'Administrator'
  has_many :users

  validates :name, :presence => true, :uniqueness => {:case_sensitive => false}

  scope :by_name, order('name')
  scope :superuser_roles, where(:name => ADMIN_ROLE)

  def admin?
    self.name == ADMIN_ROLE
  end

end
