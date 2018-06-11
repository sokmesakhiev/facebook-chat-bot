class UserResponseWorker
  include Sidekiq::Worker

  def perform(user_response_id)
    user_response = UserResponse.find(user_response_id)
    question = user_response.question

    return if question.nil? || question.bot.nil? || !question.bot.authorized_spreadsheet?

    ws = BotDriveService.new(question.bot).worksheets[0]
    row_num = find_row_num(ws, user_response)
    col_num = find_col_num(question.bot, question.id)

    ws[row_num, 1] = user_response.user_session_id
    ws[row_num, 2] = user_response.version
    ws[row_num, col_num] = user_response.value
    ws.save
  end

  private

  def find_row_num(ws, user_response)
    ws.rows.each_with_index do |row, r|
      return (r + 1) if row[0] == user_response.user_session_id && row[1] == user_response.version.to_s
    end

    return ws.num_rows + 1
  end

  def find_col_num(bot, question_id)
    index = bot.questions.index { |q| q.id == question_id }
    index + 3 # user_session_id, version
  end
end
