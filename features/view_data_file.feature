Feature: View the details of a data file
  In order to find out more
  As a user
  I want to view the details of a data file

  Background:
    Given I am logged in as "georgina@intersect.org.au"
    And I have data files
      | filename     | created_at       | uploaded_by               | start_time           | end_time                | interval |
      | datafile.dat | 30/11/2011 10:15 | georgina@intersect.org.au |                      |                         |          |
      | sample.txt   | 01/12/2011 13:45 | sean@intersect.org.au     | 1/6/2010 6:42:01 UTC | 30/11/2011 18:05:23 UTC |  300     |

  Scenario: Navigate from list and view a data file
    When I am on the list data files page
    And I follow the view link for data file "sample.txt"
    Then I should see details displayed
      | Name            | sample.txt            |
      | Date added      | 2011-12-01 13:45      |
      | Added by        | sean@intersect.org.au |
      | Start time      | 2010-06-01  6:42:01   |
      | End time        | 2011-11-30 18:05:23   |
      | Sample Interval | 5 minutes             |

  Scenario: View a data file with no start/end times
    When I am on the data file details page for datafile.dat
    Then I should see details displayed
      | Name        | datafile.dat              |
      | Date added  | 2011-11-30 10:15          |
      | Added by    | georgina@intersect.org.au |
      | File format | Unknown                   |

  Scenario: Navigate back to the list
    When I am on the data file details page for sample.txt
    And I follow "Back"
    Then I should be on the list data files page

  Scenario: Must be logged in to view the details
    Then users should be required to login on the data file details page for sample.txt