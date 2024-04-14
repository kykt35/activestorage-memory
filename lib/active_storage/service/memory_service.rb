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

    def upload(key, io, checksum: nil, **)
      instrument(:upload, key: key) do
        store[key] = io.read
        ensure_integrity_of(key, checksum) if checksum
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

    def url_for_direct_upload(key, expires_in:, content_type:, content_length:, checksum:, **)
      instrument :url, key: key do |payload|
        verified_token_with_expiration = generate_verified_token(
          key,
          expires_in: expires_in,
          content_type: content_type,
          content_length: content_length,
          checksum: checksum
        )
        url_helpers.update_rails_memory_service_url(
          verified_token_with_expiration,
          url_options
        ).tap do |generated_url|
          payload[:url] = generated_url
        end
      end
    end

    def headers_for_direct_upload(_key, content_type:, **)
      { 'Content-Type' => content_type }
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

    def url_helpers
      @url_helpers ||= Activestorage::Memory::Engine.routes.url_helpers
    end

    def generate_verified_token(key, expires_in:, content_type:, content_length:, checksum:)
      ActiveStorage.verifier.generate(
        {
          key: key,
          content_type: content_type,
          content_length: content_length,
          checksum: checksum,
          service_name: name
        },
        expires_in: expires_in,
        purpose: :blob_token
      )
    end

    def private_url(key, expires_in:, filename:, content_type:, disposition: :inline, **)
      generate_url(key, expires_in: expires_in, filename: filename, content_type: content_type, disposition: disposition)
    end

    def public_url(key, filename:, content_type: nil, disposition: :attachment, **)
      generate_url(key, expires_in: nil, filename: filename, content_type: content_type, disposition: disposition)
    end

    def generate_url(key, expires_in:, filename:, content_type:, disposition:)
      content_disposition = content_disposition_with(type: disposition, filename: ActiveStorage::Filename.wrap(filename))
      verified_key_with_expiration = ActiveStorage.verifier.generate(
        {
          key: key,
          disposition: content_disposition,
          content_type: content_type,
          service_name: name
        },
        expires_in: expires_in,
        purpose: :blob_key
      )

      if url_options.blank?
        raise ArgumentError, "Cannot generate URL for #{filename} using Memory service, please set ActiveStorage::Current.url_options."
      end

      url_helpers.rails_memory_service_url(verified_key_with_expiration, filename: filename, **url_options)
    end

    def url_options
      ActiveStorage::Current.url_options || Rails.application.default_url_options
    end

    def ensure_integrity_of(key, checksum)
      return if OpenSSL::Digest.new('md5', store[key]).base64digest == checksum

      delete key
      raise ActiveStorage::IntegrityError
    end
  end
end
