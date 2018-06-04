class Questions::SelectMultipleQuestion < Questions::SelectOneQuestion
  def kind
    :checkbox
  end
end
