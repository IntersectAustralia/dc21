Feature: Overlapping Files
  In order to remove duplicate data
  As a technician
  I want to overwrite overlapped files
  And I don't want to overlap mismatching files

  Background:
    Given I have a user "researcher@intersect.org.au" with role "Researcher"
    And I am logged in as "researcher@intersect.org.au"

  Scenario: Safe overlap one file supplying description
    Given I have data files
      | filename              | uploaded_by                 | path                                                  | file_processing_status | experiment | file_processing_description | start_time          | end_time            | format |
      | WTC01_Table1_orig.dat | researcher@intersect.org.au | samples/subsetted/range_aug_1_aug_31/WTC01_Table1.dat | RAW                    | Other      | orig wtc01_table1.dat       | 2011-08-11 19:30:00 | 2011-08-31 23:45:00 | TOA5   |
    And file "WTC01_Table1_orig.dat" has the following metadata
      | key          | value  |
      | station_name | WTC01  |
      | table_name   | Table1 |

    And I am on the upload page
    And I upload "WTC01_Table1.dat" through the applet
    And I follow "Next"

    When I select "RAW" from the select box for "WTC01_Table1.dat"
    And I fill in "file_processing_description" with "new description" for "WTC01_Table1.dat"
    And I press "Done"

    Then I should be on the list data files page
    And I should see only these rows in "exploredata" table
      | Filename         | Added by                    | Start time          | End time            | Processing Status |
      | WTC01_Table1.dat | researcher@intersect.org.au | 2011-08-11  9:30:00 | 2011-11-02 13:00:00 | RAW               |
    When I follow the view link for data file "WTC01_Table1.dat"
    Then I should see details displayed
      | Processing Status | RAW             |
      | Description       | new description |

  Scenario: Safe overlap one file inherits description
    Given I have data files
      | filename              | uploaded_by                 | path                                                  | file_processing_status | experiment | file_processing_description | start_time          | end_time            | format |
      | WTC01_Table1_orig.dat | researcher@intersect.org.au | samples/subsetted/range_aug_1_aug_31/WTC01_Table1.dat | RAW                    | Other      | orig wtc01_table1.dat       | 2011-08-11 19:30:00 | 2011-08-31 23:45:00 | TOA5   |
    And file "WTC01_Table1_orig.dat" has the following metadata
      | key          | value  |
      | station_name | WTC01  |
      | table_name   | Table1 |

    And I am on the upload page
    And I upload "WTC01_Table1.dat" through the applet
    And I follow "Next"

    When I select "RAW" from the select box for "WTC01_Table1.dat"
    And I press "Done"

    Then I should be on the list data files page
    And I should see only these rows in "exploredata" table
      | Filename         | Added by                    | Start time          | End time            | Processing Status |
      | WTC01_Table1.dat | researcher@intersect.org.au | 2011-08-11  9:30:00 | 2011-11-02 13:00:00 | RAW               |
    When I follow the view link for data file "WTC01_Table1.dat"
    Then I should see details displayed
      | Processing Status | RAW                   |
      | Description       | orig wtc01_table1.dat |

  Scenario: Bad overlap does not save
    Given I have data files
      | filename              | uploaded_by                 | path                                                 | file_processing_status | file_processing_description | start_time          | end_time            | format |
      | full_WTC01_Table1.dat | researcher@intersect.org.au | samples/WTC01_Table1.dat                             | RAW                    | original wtc01_table1.dat   | 2011-08-11 19:30:00 | 2011-08-31 23:45:00 | TOA5   |
      | WTC01_Table1_part.dat | researcher@intersect.org.au | subsetted/range_aug_1_aug_31/subset_WTC01_Table1.dat |                        |                             | 2011-08-11 19:30:00 | 2011-08-31 23:45:00 | TOA5   |
    And file "full_WTC01_Table1.dat" has the following metadata
      | key          | value  |
      | station_name | WTC01  |
      | table_name   | Table1 |
    And file "WTC01_Table1_part.dat" has the following metadata
      | key          | value  |
      | station_name | WTC01  |
      | table_name   | Table1 |

    When I am on the list for post processing data files page
    And I select "RAW" from the select box for "WTC01_Table1_part.dat"
    And I press "Done"

    Then I should see postprocess error "overlapped full_WTC01_Table1.dat" for "WTC01_Table1_part.dat"

    @wip
  Scenario: Safe overlap where original file still appears on files pending page because it doesn't have an experiment yet
    Given I have data files
      | filename              | uploaded_by                 | path                                                  | file_processing_status | experiment | file_processing_description | start_time          | end_time            | format |
      | WTC01_Table1_orig.dat | researcher@intersect.org.au | samples/subsetted/range_aug_1_aug_31/WTC01_Table1.dat | RAW                    |            | orig wtc01_table1.dat       | 2011-08-11 19:30:00 | 2011-08-31 23:45:00 | TOA5   |
    And file "WTC01_Table1_orig.dat" has the following metadata
      | key          | value  |
      | station_name | WTC01  |
      | table_name   | Table1 |

    And I am on the upload page
    And I upload "WTC01_Table1.dat" through the applet
    And I follow "Next"

    When I select "RAW" from the select box for "WTC01_Table1.dat"
    And I fill in "file_processing_description" with "new description" for "WTC01_Table1.dat"
    And I press "Done"

    Then I should be on the list data files page
    And I should see only these rows in "exploredata" table
      | Filename         | Added by                    | Start time          | End time            | Processing Status |
      | WTC01_Table1.dat | researcher@intersect.org.au | 2011-08-11  9:30:00 | 2011-11-02 13:00:00 | RAW               |
    When I follow the view link for data file "WTC01_Table1.dat"
    Then I should see details displayed
      | Processing Status | RAW             |
      | Description       | new description |

