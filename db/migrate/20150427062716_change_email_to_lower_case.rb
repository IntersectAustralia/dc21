class ChangeEmailToLowerCase < ActiveRecord::Migration
  def up
    if %w[MySQL PostgreSQL].include? ActiveRecord::Base.connection.adapter_name
      execute "UPDATE users SET email = LOWER(email)"
    else
      User.all.each do |user|
        user.update_attributes email: user.email.downcase
      end
    end
  end

  def down
  end
end
