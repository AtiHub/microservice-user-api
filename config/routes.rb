Rails.application.routes.draw do
  scope module: 'api' do
    post 'sessions/token', to: 'sessions#token'
  end
end
