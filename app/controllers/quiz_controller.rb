class QuizController < ApplicationController
  def index
    render html: "#{params.inspect}"
  end

  def receive_task
    answer = solver(params[:level], params[:question])

    respond_task(answer, params[:task_id])

    #return render head :ok
  end

  private

  def solver(level, question)
    case level
    when 1
      $loader.storage_1(question)
    when 2
      $loader.find_2e(question)
    end
  end

  def respond_task(answer, task_id)
    uri = URI("https://shakespeare-contest.rubyroidlabs.com/quiz")

    parameters = {
      answer: answer,
      token: '95458fe98ef25cc8c8150afe7eb2a93d',
      task_id: task_id
    }
    Net::HTTP.post_form(uri, parameters)
  end
end
