Feature: View the details of a data file
  In order to find out more
  As a user
  I want to view the details of a data file

  Background:
    Given I am logged in as "georgina@intersect.org.au"
    And I have data files
      | filename   | created_at       | uploaded_by           |
      | sample.txt | 01/12/2011 13:45 | sean@intersect.org.au |

  Scenario: Navigate from list and view a data file
    When I am on the list data files page
    And I follow "sample.txt"
    Then I should see details displayed
      | Name       | sample.txt            |
      | Date added | 2011-12-01 13:45      |
      | Added by   | sean@intersect.org.au |

  Scenario: Navigate back to the list
    When I am on the data file details page for sample.txt
    And I follow "Back"
    Then I should be on the list data files page

  Scenario: Must be logged in to view the details
    Then users should be required to login on the data file details page for sample.txt