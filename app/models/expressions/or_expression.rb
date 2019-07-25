class Expressions::OrExpression < Expression
  def kind
    :or
  end

  def exit_value
    true
  end
end
