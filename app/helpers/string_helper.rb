module StringHelper
  def to_boolean(value)
    return false if value.nil?
    ["yes", "true"].include?(value.downcase)
  end
end
