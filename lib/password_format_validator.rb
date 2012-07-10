class PasswordFormatValidator < ActiveModel::EachValidator
  PASS_REGEX = /^.*(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#%;:'"$^&*()_+={}|<>?,.~`\-\[\]\/\\]).*$/
  FAIL_STRING = "must be between 6 and 20 characters long and contain at least one uppercase letter, one lowercase letter, one digit and one symbol"
  def validate_each(object, attribute, value)
    unless value =~ PASS_REGEX
      object.errors[attribute] << (options[:message] || FAIL_STRING)
    end
  end
end