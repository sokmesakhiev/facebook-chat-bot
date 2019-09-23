class Parsers::ConditionParser
  # parse xlsform relevant field http://xlsform.org/en/#relevant
  def self.parse condition = nil
    raise 'Argument condition is missing' if condition.nil?

    field = condition[/\$\{(.+)\}/, 1]
    operator = condition[/(\>\=|\<\=|\!\=|[\+\-\*\>\<\=\|]|div|mod|selected)/, 1]
    value = condition[/[‘|'|"](\w+)[’|'|"]/, 1]

    Condition.new field: field, operator: operator, value: value
  end
end
