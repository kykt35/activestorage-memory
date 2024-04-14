# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Activestorage::Memory::MemoryController, type: :request do
  let(:key) { 'file_key' }
  let(:content) { 'content' }
  let(:filename) { 'file.jpg' }
  let(:content_type) { 'image/jpeg' }
  let(:service_name) { :memory }
  let(:disposition) { "inline; filename=\"file.jpg\"; filename*=UTF-8''file.jpg" }
  let(:expires_in) { ActiveStorage.service_urls_expire_in }
  let(:checksum) { OpenSSL::Digest.new('md5', content).base64digest }
  let!(:blob) do
    ActiveStorage::Blob.create_and_upload!(
      key: key,
      io: StringIO.new(content),
      filename: filename,
      content_type: content_type,
      service_name: service_name
    )
  end

  before do
    ActiveStorage::Current.url_options = { only_path: true }
  end

  describe "GET #show" do
    let(:valid_key) do
      ActiveStorage.verifier.generate(
        {
          key: key,
          service_name: service_name,
          content_type: content_type,
          disposition: disposition
        },
        expires_in: expires_in,
        purpose: :blob_key
      )
    end
    let(:invalid_key) { 'invalid_key' }

    subject { get "/rails/active_storage/memory/#{valid_key}/#{filename}" }

    context "when key is valid" do
      it "returns http success if key is valid and file exists" do
        subject
        expect(response).to have_http_status(:success)
        expect(response.body).to eq(content)
      end

      context "when file does not exist" do
        before do
          ActiveStorage::Blob.services.fetch(service_name).delete(key)
        end

        it "returns http not_found" do
          subject
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when key is invalid" do
      subject { get "/rails/active_storage/memory/#{invalid_key}/#{filename}" }

      it "returns http not_found" do
        subject
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "PATCH #update" do
    let(:valid_token) do
      ActiveStorage.verifier.generate(
        {
          key: key,
          service_name: service_name,
          checksum: checksum,
          content_type: content_type,
          content_length: content.length
        },
        purpose: :blob_token
      )
    end
    let(:invalid_token) { 'invalid_token' }

    context "when token is valid" do
      context "when content is acceptable" do
        subject do
          put(
            "/rails/active_storage/memory/#{valid_token}",
            params: content,
            headers: { 'Content-Type' => content_type, 'Content-Length' => content.size }
          )
        end

        it "returns http no_content if token is valid and content is acceptable" do
          subject
          expect(response).to have_http_status(:no_content)
        end
      end

      context "when content is not acceptable" do
        subject do
          put(
            "/rails/active_storage/memory/#{valid_token}",
            params: content,
            headers: { 'Content-Type' => "image/png", 'Content-Length' => content.size }
          )
        end

        it "returns http unprocessable_entity" do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "when token is invalid" do
      subject do
        put(
          "/rails/active_storage/memory/#{invalid_token}",
          params: content,
          headers: { 'Content-Type' => content_type, 'Content-Length' => content.size }
        )
      end

      it "returns http not_found" do
        subject
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
