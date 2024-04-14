Rails.application.routes.draw do
  mount Activestorage::Memory::Engine => "/"
end
