class Expressions::AndExpression < Expression
  def kind
    :and
  end

  def exit_value
    false
  end
end
