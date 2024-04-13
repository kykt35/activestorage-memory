# frozen_string_literal: true

module ActiveStorage::Memory
  class Engine < ::Rails::Engine
    isolate_namespace ActiveStorage::Memory
  end
end
