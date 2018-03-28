Feature: Engine
  Test the engine module to see that everything works properly
  
  Scenario: Parse letter
    When I parse the letter A
    Then I should see A
    