Feature: Test Parallel 2
  Scenario: Test another parallel given
  Given I have a simple background 2
  When I have a thing to do 2
  Then I have done the thing 2

  Scenario: Another parallel test 2
  Given I have another simple background 2
  When I have some other thing to do 2
  Then I should have done the thing 2
