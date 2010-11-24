@envjs @campaigns
Feature: Campaigns

  Scenario: Adding my name to a campaign
    Given a campaign exists
    When  I go to the campaign page
    Then  I should see the campaign summary
    And   I submit the address form with my information
    Then  I should see my congress people
    And   I should see the campaign body
    When  I select my congress people
    And   I sign the campaign
    And   I pay for the letters with my credit card
    Then  My letters should be on their way
