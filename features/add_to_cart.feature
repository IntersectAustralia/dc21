@javascript
Feature: View the list of data files
  In order to find what I need
  As a user
  I want to view a list of data files

  Background:
    Given I am logged in as "admin@intersect.org.au"
    And I have data files
      | filename     | uploaded_by|
      | datafile.dat | admin@intersect.org.au           |
      | sample.txt   | admin@intersect.org.au           |
      | sample2.txt  | admin@intersect.org.au            |

  Scenario: Add to cart from view details page
    Given I am on the data file details page for sample.txt
    Then I should see link "Add to Cart"
    When I click on "Add to Cart"
    Then I should see "File was successfully added to cart."
    And I should be on the data file details page for sample.txt
    And I should not see link "Add to Cart"

  Scenario: Add to cart button should be grey and disabled after clicking
    Given I am on the list data files page
    Then I should see the add to cart link for datafile.dat
    And I should see the add to cart link for sample.txt
    When I add sample.txt to the cart
    And I should see the add to cart link for datafile.dat
    And the add to cart link for sample.txt should be disabled
    And the add to cart link for datafile.dat should not be disabled

  Scenario: When coming back to view details page later, remove_from_cart show if already in cart
    Given I am on the data file details page for sample.txt
    And I click on "Add to Cart"
    When I am on the data file details page for sample.txt
    Then I should not see link "Add to Cart"
    And I should see link "Remove from Cart"

  Scenario: remove from cart from the view details page
    Given I am on the data file details page for sample.txt
    And I click on "Add to Cart"
    When I am on the data file details page for sample.txt
    And I click on "Remove from Cart"
    And I should see "File was successfully removed from cart."

  Scenario: When coming back to list of files page later, add to cart doesn't show if already in cart
    Given I am on the list data files page
    And I add sample.txt to the cart
    When I am on the list data files page
    Then I should see the add to cart link for datafile.dat
    And I should not see the add to cart link for sample.txt

  Scenario: Add all to cart from list of files
    Given I am on the list data files page
    Then I should see "0 Files in Cart"
    Then I should see link "Add All"
    And I click on "Add All"
    Then I confirm the popup
    Then I should see "3 Files in Cart"
    And I should not see the add to cart link for sample.txt
    And I should not see the add to cart link for datafile.dat
    And I should not see the add to cart link for sample2.txt

  Scenario: Cart details page should inform user if empty (and prevent download/package options)
    Given I am on the edit cart page
    Then I should see "Your cart is empty."
    And I should not see "Download" within "#content_container"
    And I should not see "Package" within "#content_container"

  Scenario: Cart details page should list all cart items
    Given I am on the list data files page
    And I add sample.txt to the cart
    And I add sample2.txt to the cart
    Then I should see "2 Files in Cart"
    When I am on the edit cart page
    Then I should see "sample.txt"
    And I should see "sample2.txt"
    And I remove sample.txt from the cart
    And I should see "File was successfully removed from cart."
    And I should not see "sample.txt"
    And I should see "sample2.txt"
    And I follow "Package"
    And I should be on the create package page

  Scenario: Cart details persist after logout, and are retrieved when user next logs in
    Given I am on the list data files page
    And I add sample.txt to the cart
    Then I should see "1 File in Cart"
    And I logout
    When I am logged in as "admin@intersect.org.au"
    And I am on the list data files page
    Then I should see "1 File in Cart"
    And I should not see the add to cart link for sample.txt
    And I should see the add to cart link for datafile.dat

  Scenario: number of items in cart updates upon adding from list of files
    Given I am on the list data files page
    Then I should see "0 Files in Cart"
    When I add sample.txt to the cart
    Then I should see "1 File in Cart"

  Scenario: number of items in cart updates upon removing items from list of files
    Given I am on the list data files page
    Then I should see "0 Files in Cart"
    When I add sample.txt to the cart
    And I should see "1 File in Cart"
    Then I am on the edit cart page
    When I remove sample.txt from the cart
    Then I should see "Your cart is empty"

  Scenario: number of items in cart updates upon adding from list of files
    Given I am on the list data files page
    Then I should see "0 Files in Cart"
    When I add sample.txt to the cart
    Then I should see "1 File in Cart"

  Scenario: Removal of data file from server should automatically reflect in cart
    Given I am on the list data files page
    Then I should see "0 Files in Cart"
    Then I should see "Add All"
    And I click on "Add All"
    Then I confirm the popup
    Then I should see "3 Files in Cart"
    Then I am on the data file details page for sample.txt
    And I click on "Delete This File"
    Then I confirm the popup
    And I wait for the page
    Then I should see "2 Files in Cart"

  Scenario: Clearing of cart
    Given I am on the list data files page
    And I add sample.txt to the cart
    And I add sample2.txt to the cart
    Then I should see "2 Files in Cart"
    When I am on the edit cart page
    Then I should see "sample.txt"
    And I should see "sample2.txt"
    And I follow "Remove All"
    And I confirm the popup
    And I should see "Your cart was cleared."
    And I should not see "0 files in cart."

  Scenario: All Add to Cart on Dashboard
    Given I am on the home page
    Then I should see "Add All"
    And I click on "Add All"
    Then I confirm the popup
    Then I should see "3 Files in Cart"
