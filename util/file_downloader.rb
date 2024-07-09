# frozen_string_literal: true

require 'net/http'
require 'uri'

class FileDownloader
  def self.download(url, file_path)
    uri = URI(url)
    response = Net::HTTP.get_response(uri)
    return unless response.is_a?(Net::HTTPSuccess)

    File.open(file_path, 'w') { |file| file << response.body }
  end
end
