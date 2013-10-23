Feature: View the dashboard main page

  Background:
    Given I am logged in as "admin@intersect.org.au"

  Scenario: Dashboard shows recent uploaded files
    Given I have uploaded "sample1.txt" as "admin@intersect.org.au"
    And I have uploaded "WTC01_Table1.dat" as "admin@intersect.org.au"
    When I am on the home page
    Then I should see "exploredata" table with
      | Filename         | Added by               |
      | WTC01_Table1.dat | admin@intersect.org.au |
      | sample1.txt      | admin@intersect.org.au |

  Scenario: Dashboard shows 5 most recent files
    Given I have data files
      | filename    | created_at       | uploaded_by            |
      | sample1.txt | 04/12/2010 13:45 | sean@intersect.org.au  |
      | sample2.txt | 31/11/2011 10:15 | admin@intersect.org.au |
      | sample3.txt | 01/12/2010 13:45 | sean@intersect.org.au  |
      | sample4.txt | 30/11/2010 10:15 | admin@intersect.org.au |
      | sample5.txt | 30/11/2011 10:15 | admin@intersect.org.au |
      | sample6.txt | 04/12/2011 13:45 | sean@intersect.org.au  |
      | sample7.txt | 01/12/2011 13:45 | sean@intersect.org.au  |
    When I am on the home page
    Then I should see "exploredata" table with
      | Filename    | Added by               |
      | sample6.txt | sean@intersect.org.au  |
      | sample7.txt | sean@intersect.org.au  |
      | sample2.txt | admin@intersect.org.au |
      | sample5.txt | admin@intersect.org.au |
      | sample1.txt | sean@intersect.org.au  |
