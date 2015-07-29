class Language < ActiveRecord::Base
  validates_presence_of :language_name
end