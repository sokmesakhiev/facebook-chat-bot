class UserResponseWorker
  include Sidekiq::Worker

  def perform(survey_id)
    survey = Survey.find(survey_id)
    question = survey.question

    return if question.nil? || question.bot.nil? || !question.bot.authorized_spreadsheet?

    ws = BotDriveService.new(question.bot).worksheets[0]
    row_num = find_row_num(ws, survey)
    col_num = find_col_num(question.bot, question.id)

    ws[row_num, 1] = survey.respondent.user_session_id
    ws[row_num, 2] = survey.respondent.version
    ws[row_num, col_num] = survey.value
    ws.save
  end

  private

  def find_row_num(ws, survey)
    ws.rows.each_with_index do |row, r|
      return (r + 1) if row[0] == survey.respondent.user_session_id && row[1] == survey.respondent.version.to_s
    end

    return ws.num_rows + 1
  end

  def find_col_num(bot, question_id)
    index = bot.questions.index { |q| q.id == question_id }
    index + 3 # user_session_id, version
  end
end
