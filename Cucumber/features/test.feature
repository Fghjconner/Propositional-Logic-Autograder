Feature: Test
  This is a sample feature test, and not an actual one
  
  Scenario: Adding
    When I add 1 and 2
    Then I should get 3
  
  Scenario: Search Google
    When I search Google for "cucumber"
    Then there should be a result for "cucumber.io/"