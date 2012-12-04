Feature: View the list of data files
  In order to find what I need
  As a user
  I want to view a list of data files

  Background:
    Given I am logged in as "georgina@intersect.org.au"



  Scenario: Add to cart from view details page
    Given I have data files
      | filename     | created_at       | uploaded_by               | file_processing_status | experiment    |
      | datafile.dat | 30/11/2011 10:15 | georgina@intersect.org.au | RAW                    | My Experiment |
      | sample.txt   | 01/12/2011 13:45 | sean@intersect.org.au     | CLEANSED               | Experiment 2  |
    When I am on the data file details page for sample.txt
    Then I should see button "Add to Cart"
    And I press "Add to Cart"
    And I should see "File was successfully added to cart."
    And I should be on the data file details page for sample.txt

