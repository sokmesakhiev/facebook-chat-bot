class Condition
  attr_accessor :field, :operator, :value

  def initialize options = {}
    @field = options[:field] || nil
    @operator = options[:operator] || nil
    @value = options[:value] || nil
  end

end
