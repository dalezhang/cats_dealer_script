# frozen_string_literal: true

require 'crack'
require 'json'
class SearchFromDataService
  def self.search(params)
    result_data = []
    (params[:shops] || []).each do |shop|
      best_price = best_price_from_shop(shop, params)
      best_price['shop'] = shop[:shop_name]
      result_data += [best_price]
    end
    result_data = result_data.sort_by { |h| h['price'] }
    result_data.first
  end

  def self.best_price_from_shop(shop, params)
    temp_data = read_data_from_file(shop)
    rename_columns(temp_data, shop[:rename_columns])
    temp_data.map do |h|
      h['price'] = h['price'].to_i
    end
    temp_data = temp_data.select { |h| h['name'].downcase.match?(params[:cat_name].downcase) } if params[:cat_name]
    temp_data = temp_data.sort_by { |h| h['price'] }
    temp_data.first
  end

  def self.read_data_from_file(shop)
    str = File.read(shop[:file_path])
    hash = []
    case shop[:file_type]
    when 'xml'
      hash = Crack::XML.parse(str)
    when 'json'
      hash = JSON.parse str
    else
      return []
    end

    result =  shop[:dig_data].any? ? hash.dig(*shop[:dig_data]) : hash

    result || []
  end

  def self.rename_columns(data, rename_to)
    rename_to ||= {}
    data.map do |shop|
      shop.transform_keys! { |key| rename_to[key] || key }
    end
  end
end
