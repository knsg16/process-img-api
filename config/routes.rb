Rails.application.routes.draw do
  get 'images', to: 'images#resize'
end
