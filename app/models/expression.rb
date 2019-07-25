class Expression
  attr_accessor :conditions

  EXPRESSION_OR = 'or'
  EXPRESSION_AND = 'and'
  WHILTELIST_EXPRESSIONS = [EXPRESSION_OR, EXPRESSION_AND]

  def initialize conditions = []
    @conditions = conditions
  end

  def kind; raise 'you have to implement in subclass' end
  def exit_value; 'you have to implement in subclass' end

  def append_conditions! relevant_attr
    relevant_attr.downcase.split(kind.to_s).each do |condition|
      conditions << Parsers::ConditionParser.parse(condition.strip)
    end
  end

  def self.of expression = EXPRESSION_OR
    raise "Unknown Expression #{expression}" unless WHILTELIST_EXPRESSIONS.include? expression.downcase

    "Expressions::#{expression.camelcase}Expression".constantize.new
  end

  def self.has_multiple_mode? text
    has_expression_or?(text) and has_expression_and?(text)
  end

  def self.has_expression_or? text
    text.downcase.include?(EXPRESSION_OR)
  end

  def self.has_expression_and? text
    text.downcase.include?(EXPRESSION_AND)
  end

  def self.from_xlsform_relevant relevant_attr
    raise 'Question is supported only a single expression(OR or AND)' if has_multiple_mode?(relevant_attr)

    expression = has_expression_and?(relevant_attr) ? of(EXPRESSION_AND) : of(EXPRESSION_OR)
    expression.append_conditions!(relevant_attr)
    expression
  end
end
