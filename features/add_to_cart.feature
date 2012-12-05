@javascript
Feature: View the list of data files
  In order to find what I need
  As a user
  I want to view a list of data files

  Background:
    Given I am logged in as "georgina@intersect.org.au"
    And I have data files
      | filename     |
      | datafile.dat |
      | sample.txt   |

  Scenario: Add to cart from view details page
    Given I am on the data file details page for sample.txt
    Then I should see button "Add to Cart"
    When I press "Add to Cart"
    Then I should see "File was successfully added to cart."
    And I should be on the data file details page for sample.txt
    And I should not see button "Add to Cart"

  Scenario: Add to cart from the list of files
    Given I am on the list data files page
    Then I should see the add to cart link for datafile.dat
    And I should see the add to cart link for sample.txt
    When I add sample.txt to the cart
    And I should see the add to cart link for datafile.dat
    And I should not see the add to cart link for sample.txt

  Scenario: When coming back to view details page later, add to cart doesn't show if already in cart
    Given I am on the data file details page for sample.txt
    And I press "Add to Cart"
    When I am on the data file details page for sample.txt
    Then I should not see button "Add to Cart"

  Scenario: When coming back to list of files page later, add to cart doesn't show if already in cart
    Given I am on the list data files page
    And I add sample.txt to the cart
    When I am on the list data files page
    Then I should see the add to cart link for datafile.dat
    And I should not see the add to cart link for sample.txt
