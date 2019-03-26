Rails.application.routes.draw do
  root 'quiz#index' 
  post 'quiz' => 'quiz#receive_task' 
end
