class UserResponseWorker
  include Sidekiq::Worker

  def perform(user_response_id)
    user_response = UserResponse.find(user_response_id)
    question = user_response.question

    return if question.nil?

    ws = BotDriveService.new(question.bot).worksheets[0]
    row_num = find_row_num(ws, user_response.user_session_id)
    col_num = find_col_num(question.bot, question.id)

    ws[row_num, 1] = user_response.user_session_id
    ws[row_num, col_num] = user_response.value
    ws.save
  end

  private

  def find_row_num(ws, user_session_id)
    user_session_ids = (2..ws.num_rows).map { |row| ws[row, 1] }
    last_row_num     = ws.num_rows > 0 ? ws.num_rows : 1
    row_index        = user_session_ids.index { |id| id == user_session_id }
    row_index.present? ? (row_index + 2) : (last_row_num + 1)
  end

  def find_col_num(bot, question_id)
    index = bot.questions.index { |q| q.id == question_id }
    index + 2
  end
end
