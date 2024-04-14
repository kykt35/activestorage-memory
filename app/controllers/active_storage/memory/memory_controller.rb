# frozen_string_literal: true

module ActiveStorage::Memory
  class MemoryController < ActiveStorage::BaseController
    skip_forgery_protection

    def show
      key = decode_verified_key

      unless key
        head :not_found
        return
      end

      service = named_memory_service(key[:service_name])
      if service.exist?(key[:key])
        send_data(service.store[key[:key]], content_type: key[:content_type], disposition: key[:disposition])
      else
        head :not_found
      end
    end

    def update
      token = decode_verified_token

      unless token
        head :not_found
        return
      end

      unless acceptable_content?(token)
        head :unprocessable_entity
        return
      end

      named_memory_service(token[:service_name]).upload token[:key], request.body, checksum: token[:checksum]
      head :no_content
    end

    private

    def named_memory_service(name)
      ActiveStorage::Blob.services.fetch(name) do
        ActiveStorage::Blob.service
      end
    end

    def decode_verified_key
      ActiveStorage.verifier.verified(params[:encoded_key], purpose: :blob_key)&.deep_symbolize_keys
    end

    def decode_verified_token
      ActiveStorage.verifier.verified(params[:encoded_token], purpose: :blob_token)&.deep_symbolize_keys
    end

    def acceptable_content?(token)
      token[:content_type] == request.content_mime_type.to_s && token[:content_length] == request.content_length
    end
  end
end
