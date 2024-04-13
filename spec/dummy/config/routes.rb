Rails.application.routes.draw do
  mount ActiveStorage::Memory::Engine => "/"
end
