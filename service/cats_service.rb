# frozen_string_literal: true

require 'yaml'
require_relative '../util/file_downloader'
require_relative './search_from_data_service'
class CatsService
  CURRENT_DIR = File.dirname(__FILE__)
  SHOPS_CONFIG_PATH = "#{File.dirname(CURRENT_DIR)}/shops.yml".freeze

  def self.best_price(name: nil, use_cache: true)
    shops = YAML.load(File.read(SHOPS_CONFIG_PATH))
    params = { cat_name: name, shops: [] }
    threads = []

    shops.each_value do |shop|
      path = "#{File.dirname(CURRENT_DIR)}/tmp/#{shop['file_name']}"
      if use_cache && FileTest.exist?(path)
        params[:shops] << prepare_params(shop, path)
      else
        threads << prepare_download_thread(shop, path, params)
      end
    end

    threads.map(&:join)
    # puts "download_file_errors: \n#{params[:errors].join("\n")}" if params[:errors].any?
    SearchFromDataService.search(params)
  end

  def self.prepare_params(shop, file_path)
    {
      shop_name: shop['shop_name'],
      file_path:,
      file_type: shop['file_type'],
      dig_data: shop['dig_data'] || [],
      rename_columns: shop['rename_columns'] || {}
    }
  end

  def self.prepare_download_thread(shop, file_path, params = {})
    Thread.new do
      FileDownloader.download(shop['url'], file_path)
      if FileTest.exist?(file_path)
        params[:shops] ||= []
        params[:shops] << prepare_params(shop, file_path)
      end
    rescue StandardError => e
      params[:errors] ||= []
      params[:errors] << "Error while download file from url #{shop['url']}: #{e.message}"
      # TODO: Maybe we should let the client know this shop is not available
    end
  end
end
