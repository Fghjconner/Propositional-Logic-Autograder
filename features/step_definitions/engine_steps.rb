require 'rubygems'
require 'selenium-webdriver'

driver = Selenium::WebDriver.for :firefox

When ("Selenium is set up") do 
  
end

Then ("I can go to our heroku deployment") do 
  driver.get "https://rocky-refuge-53175.herokuapp.com/"
end

#---------------------------------

When ("I submit an empty form") do 
  element = driver.find_element :name => "commit"
  element.submit
end

Then (/^I should get "(.+)" as a response$/) do |resp|
  expect(driver.body).to include(resp)
end

And ("I search for cheese") do
    element = driver.find_element :name => "q"
    element.send_keys "Cheese!"
    element.submit
end

Then ("I should see cheese") do 
    puts "Page title is #{driver.title}"
    
    wait = Selenium::WebDriver::Wait.new(:timeout => 10)
    wait.until { driver.title.downcase.start_with? "cheese!" }
    
    puts "Page title is #{driver.title}"
end

driver.quit