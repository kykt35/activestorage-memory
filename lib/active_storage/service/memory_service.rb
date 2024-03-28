# frozen_string_literal: true

module ActiveStorage
  # ActiveStorage in-memory service
  class Service::MemoryService < ActiveStorage::Service
    attr_reader :store

    def initialize(**config)
      super
      @store = {}
      @config = config
    end

    def upload(key, io, **)
      instrument(:upload, key: key) do
        store[key] = io.read
      end
    end

    def download(key, &block)
      if block_given?
        instrument(:streaming_download, key: key) do
          stream key, &block
        end
      else
        instrument(:download, key: key) do
          io = StringIO.new(store.fetch(key))
          io.set_encoding(io.string.encoding)
          io
        rescue KeyError
          raise ActiveStorage::FileNotFoundError
        end
      end
    end

    def delete(key)
      instrument(:delete, key: key) do
        store.delete(key)
      rescue KeyError
        # Ignore key errors
      end
    end

    def exist?(key)
      instrument(:exist, key: key) do |payload|
        answer = store.key?(key)
        payload[:exist] = answer
        answer
      end
    end

    def url(key)
      instrument(:url, key: key) do
        # FIXME: - this should be a URL that can be used to directly download the file
        "memory://#{key}"
      end
    end

    private

    def stream(key)
      io = StringIO.new(store.fetch(key))
      while data = io.read(5.megabytes)
        yield data
      end
    rescue KeyError
      raise ActiveStorage::FileNotFoundError
    end
  end
end
