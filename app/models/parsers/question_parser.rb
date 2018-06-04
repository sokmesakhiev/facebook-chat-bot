class Parsers::QuestionParser
  def self.parse type
    "Questions::#{type.camelcase}Question".constantize.new
  end
end
