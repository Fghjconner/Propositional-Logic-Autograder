Feature: Engine
  Test the engine module to see that everything works properly
  
  Background: Navigate to our Heroku
    When Selenium is set up
    Then I can go to our heroku deployment
  
  Scenario: Empty submission
    When I submit an empty form
    Then I should get "Ugly" as a response