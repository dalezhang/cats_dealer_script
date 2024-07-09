# frozen_string_literal: true

require './service/cats_service'

puts 'Best price from all: '
result = CatsService.best_price
puts result
puts '=========================='

puts "Best price with name like 'curl'"
result = CatsService.best_price(name: 'curl')
puts result
puts '=========================='

puts 'Best price without using cache'
result = CatsService.best_price(use_cache: false)
puts result
puts '=========================='
