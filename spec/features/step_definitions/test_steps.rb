check = 0

When ("I add {int} and {int}") do |one, two|
  check = one + two
end

Then("I should get {int}") do |result|
  expect(check).to eq(result)
end