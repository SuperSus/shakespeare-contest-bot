# frozen_string_literal: true

class QuizController < ApplicationController
  include QuizSolver

  def index 
    render plain:  JSON.pretty_generate(REQUESTS)
  end

  def receive_task
    answer = solver(params[:level], params[:question])

    REQUESTS << { reqest: params }

    return unless answer   

    respond = respond_task(answer, params[:id]) 
    
    REQUESTS << { respond: respond.body, task_id: params[:id] }

    logger.debug "respond -- #{respond.body} | -- answer #{answer} "
  end

  private

  def solver(level, question)
    case 
    when level == 1
      find_1(question)
    when [2, 3, 4].include?(level)
      find_2_3_4(question)
    when level == 5 
      find_5(question)
    when [6, 7].include?(level)
      find_6_7(question)
    when 8
      find_8(question)
    end
  end

  def respond_task(answer, task_id)
    uri = URI('https://shakespeare-contest.rubyroidlabs.com/quiz')

    parameters = {
      answer: answer,
      token: '95458fe98ef25cc8c8150afe7eb2a93d',
      task_id: task_id
    }
    Net::HTTP.post_form(uri, parameters)
  end
end
