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
      | sample2.txt  |

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

  Scenario: Add all to cart from list of files
    Given I am on the list data files page
    Then I should see "0 items in cart"
    Then I should see "Add All"
    And I press "Add All"
    Then I wait for the page
    Then I should see "3 items in cart"
    And I should not see the add to cart link for sample.txt
    And I should not see the add to cart link for datafile.dat
    And I should not see the add to cart link for sample2.txt
    And I should not see the add all to cart link

  Scenario: Cart details persist after logout, and are retrieved when user next logs in
    Given I am on the list data files page
    And I add sample.txt to the cart
    Then I should see "1 item in cart"
    And I follow "Sign out"
    When I am logged in as "georgina@intersect.org.au"
    And I am on the list data files page
    Then I should see "1 item in cart"
    And I should not see the add to cart link for sample.txt
    And I should see the add to cart link for datafile.dat

  Scenario: number of items in cart updates upon adding from list of files
    Given I am on the list data files page
    Then I should see "0 items in cart"
    When I add sample.txt to the cart
    Then I should see "1 item in cart"

  Scenario: number of items in cart updates upon removing items from list of files
    Given I am on the list data files page
    Then I should see "0 items in cart"
    When I add sample.txt to the cart
    And I should see "1 item in cart"
    When I remove sample.txt from the cart
    Then I should see "0 items in cart"

   Scenario: number of items in cart updates upon adding from list of files
    Given I am on the list data files page
    Then I should see "0 items in cart"
    When I add sample.txt to the cart
    Then I should see "1 item in cart"