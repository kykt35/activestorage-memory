# frozen_string_literal: true

module Activestorage::Memory
  class Engine < ::Rails::Engine
    isolate_namespace Activestorage::Memory
  end
end
