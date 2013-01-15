class SequenceHelper
  def self.next_available(used_numbers)
    return 1 if used_numbers.empty?

    current_number = 1
    used_numbers.each do |used_number|
      return current_number if current_number < used_number
      current_number += 1
    end

    # if we got here, just increment one more since its a continuous sequence
    current_number
  end
end