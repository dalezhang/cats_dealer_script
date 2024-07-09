# frozen_string_literal: true

require_relative '../helper'
describe 'SearchFromDataService' do
  before do
    @data = [{ 'a' => 1, 'b' => 1 }, { 'a' => 2, 'b' => 2 }]
    @shop = {
      file_path: "#{File.dirname(File.dirname(__FILE__))}/data/happy_cats.xml",
      file_type: 'xml',
      rename_columns: { 'title' => 'name', 'img' => 'image', 'cost' => 'price' },
      dig_data: %w[cats cat]
    }
  end

  describe 'rename_columns' do
    it 'should rename column b to c' do
      SearchFromDataService.rename_columns(@data, { 'b' => 'c' })
      _(@data.map(&:keys).flatten.include?('b')).must_equal false
      _(@data.map(&:keys).flatten.include?('c')).must_equal true
    end
  end

  describe 'read_data_from_file' do
    it 'should read xml file successful' do
      arr = SearchFromDataService.read_data_from_file(@shop)
      _(arr.size).must_equal 10
      _(arr[0].keys).must_equal %w[title cost location img]
    end

    it 'should read invalid xml file without crush' do
      shop = @shop.dup
      shop[:file_path] = "#{File.dirname(File.dirname(__FILE__))}/data/invalid.xml"
      arr = SearchFromDataService.read_data_from_file(shop)
      _(arr.size).must_equal 0
    end
  end

  describe 'search' do
    it 'should return the min price cat' do
      result = SearchFromDataService.search({ shops: [@shop], shop_name: 'happy_cats' })
      _(result['price']).must_equal 40
      _(result.keys).must_equal %w[name price location image shop]
    end

    it "should return the min price cat with name like 'curl'" do
      result = SearchFromDataService.search({ cat_name: 'curl', shops: [@shop],
                                              shop_name: 'happy_cats' })
      _(result['name']).must_equal 'American Curl'
      _(result['price']).must_equal 650
    end
  end
end
