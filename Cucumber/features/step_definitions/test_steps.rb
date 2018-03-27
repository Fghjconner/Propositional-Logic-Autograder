require 'rails_helper'

check = 0

When ("I add {int} and {int}") do |one, two|
  check = one + two
end

Then("I should get {int}") do |result|
  expect(check).to eq(result)
end

When ("I search Google for {string}") do |query|
  visit 'http://www.google.com/advanced_search?hl=en'
  fill_in 'as_q', :with => query
  click_button 'Search'
end

Then ("there should be a result for {string}") do |expected_result|
  results = all('cite').map { |el| el.text }
  results.should include expected_result
end