Feature: Test Parallel
  Scenario: Test a parallel given
  Given I have a simple background
  When I have a thing to do
  Then I have done the thing

  Scenario: Another parallel test
  Given I have another simple background
  When I have some other thing to do
  Then I should have done the thing
  