require 'rails_helper'

RSpec.describe ActiveStorage::Service::MemoryService do
  let(:service) { ActiveStorage::Service::MemoryService.new }
  let(:content) { 'content' }
  let(:io) { StringIO.new(content) }
  let(:key) { 'key' }
  let(:host) { 'example.com'}

  before do
    ActiveStorage::Current.url_options = { host: host }
  end

  describe '#upload' do
    it 'stores by key' do
      service.upload(key, io)
      expect(service.store[key]).to eq(content)
    end
  end

  describe '#download' do
    context 'when key does not exist' do
      it 'raises ActiveStorage::FileNotFoundError' do
        expect { service.download(key) }.to raise_error(ActiveStorage::FileNotFoundError)
      end
    end

    context 'when key exists' do
      before do
        service.upload(key, io)
      end
      it 'retrieves by key' do
        expect(service.download(key).read).to eq(content)
      end
    end
  end

  describe '#delete' do
    context 'when key does not exist' do
      it 'ignores key errors' do
        expect { service.delete(key) }.not_to raise_error
      end
    end

    context 'when key exists' do
      before do
        service.upload(key, io)
      end

      it 'deletes by key' do
        service.delete(key)
        expect(service.store).not_to have_key(key)
      end
    end
  end

  describe '#exist?' do
    context 'when key does not exist' do
      it 'returns false' do
        expect(service.exist?(key)).to be false
      end
    end

    context 'when key exists' do
      before do
        service.upload(key, io)
      end

      it 'checks by key' do
        expect(service.exist?(key)).to be true
      end
    end
  end

  describe '#url_for_direct_upload' do
    let(:filename) { 'filename' }
    let(:content_type) { 'image/jpeg' }
    let(:content_length) { content.size }
    let(:checksum) {  OpenSSL::Digest.new('md5', content).base64digest }
    let(:service_name) { 'memory' }
    let(:expires_in) { 5.minutes }

    before do
      service.upload(key, io)
    end

    it 'returns a memory url' do
      expect(service.url(key, expires_in:, filename:, content_type:)).to start_with("http://#{host}/")
    end
  end

  describe '#headers_for_direct_upload' do
    let(:content_type) { 'image/jpeg' }

    it 'returns content type' do
      expect(service.headers_for_direct_upload(key, content_type: content_type)).to eq('Content-Type' => content_type)
    end
  end
end
