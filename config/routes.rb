Activestorage::Memory::Engine.routes.draw do
  scope ActiveStorage.routes_prefix do
    get '/memory/:encoded_key/*filename' => 'memory#show', as: :rails_memory_service
    put '/memory/:encoded_token' => 'memory#update', as: :update_rails_memory_service
  end
end
