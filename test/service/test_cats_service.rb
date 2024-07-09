# frozen_string_literal: true

require_relative '../helper'
describe 'CatsService' do
  describe 'best_price' do
    it 'should return the best price' do
      result = CatsService.best_price
      _(result['price']).must_equal 20
      _(result.keys).must_equal %w[name price location image shop]
    end

    it 'should return the best price without using cache' do
      result = CatsService.best_price(use_cache: false)
      _(result['price']).must_equal 20
    end

    it "should return the best price 'curl' cat" do
      result = CatsService.best_price(name: 'curl')
      _(result['name']).must_equal 'American Curl'
      _(result['price']).must_equal 450
    end
  end
end
