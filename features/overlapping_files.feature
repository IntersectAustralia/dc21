Feature: Overlapping Files
  In order to remove duplicate data
  As a technician
  I want to overwrite overlapped files
  And I don't want to overlap mismatching files

  Background:
    Given I have a user "researcher@intersect.org.au" with role "Institutional User"
    Given I have a user "other@intersect.org.au" with role "Institutional User"
    And I am logged in as "researcher@intersect.org.au"
    And I have experiment "My Experiment"

  Scenario: Safe overlap one file supplying description and experiment
    Given I upload "samples/subsetted/range_aug_1_aug_31/WTC01_Table1.dat" with type "RAW" and description "orig desc" and experiment "My Experiment"
    And I upload "samples/WTC01_Table1.dat" with type "RAW" and description "new description" and experiment "My Experiment"
    When I am on the list data files page
    Then I should see only these rows in "exploredata" table
      | Filename         | Added by                    | Type |
      | WTC01_Table1.dat | researcher@intersect.org.au | RAW  |
    When I follow the view link for data file "WTC01_Table1.dat"
    Then I should see details displayed
      | Type        | RAW             |
      | Description | new description |
      | Experiment  | My Experiment   |

  Scenario: Safe overlap one file inherits description
    Given I upload "samples/subsetted/range_aug_1_aug_31/WTC01_Table1.dat" with type "RAW" and description "orig desc" and experiment "My Experiment"
    And I upload "samples/WTC01_Table1.dat" with type "RAW" and description "" and experiment "My Experiment"
    When I am on the list data files page
    Then I should see only these rows in "exploredata" table
      | Filename         | Added by                    | Type |
      | WTC01_Table1.dat | researcher@intersect.org.au | RAW  |
    When I follow the view link for data file "WTC01_Table1.dat"
    Then I should see details displayed
      | Type        | RAW       |
      | Description | orig desc |

  Scenario: Safe overlap removes replaced files from carts and adds new one to carts
    Given I have uploaded "subsetted/range_oct_10_oct_12/weather_station_05_min_10_to_12.dat" as "other@intersect.org.au" with type "RAW"
    And I have uploaded "subsetted/range_oct_13_oct_15/weather_station_05_min_13_to_15.dat" as "other@intersect.org.au" with type "RAW"
    And the cart for "researcher@intersect.org.au" contains "weather_station_05_min_10_to_12.dat"
    And the cart for "researcher@intersect.org.au" contains "weather_station_05_min_13_to_15.dat"
    And the cart for "other@intersect.org.au" contains "weather_station_05_min_10_to_12.dat"
    Then the cart for "other@intersect.org.au" should contain 1 file
    And the cart for "researcher@intersect.org.au" should contain 2 files
    When I upload "samples/weather_station_05_min.dat" with type "RAW" and description "new description" and experiment "My Experiment"
    Then I should see "Carts have been updated."
    And I am on the list data files page
    Then I should see only these rows in "exploredata" table
      | Filename                   | Added by                    | Type |
      | weather_station_05_min.dat | other@intersect.org.au | RAW  |
    And the cart for "other@intersect.org.au" should contain only file "weather_station_05_min.dat"
    And the cart for "researcher@intersect.org.au" should contain only file "weather_station_05_min.dat"

  Scenario: Safe overlap doesn't show carts message if no files in carts
    Given I have uploaded "subsetted/range_oct_10_oct_12/weather_station_05_min_10_to_12.dat" as "other@intersect.org.au" with type "RAW"
    And I have uploaded "subsetted/range_oct_13_oct_15/weather_station_05_min_13_to_15.dat" as "other@intersect.org.au" with type "RAW"
    When I upload "samples/weather_station_05_min.dat" with type "RAW" and description "new description" and experiment "My Experiment"
    Then I should not see "Carts have been updated."
    And I am on the list data files page
    Then I should see only these rows in "exploredata" table
      | Filename                   | Added by                    | Type |
      | weather_station_05_min.dat | other@intersect.org.au | RAW  |
    And the cart for "other@intersect.org.au" should be empty
    And the cart for "researcher@intersect.org.au" should be empty

  Scenario: Identical file is considered a safe overlap and inherits description when none entered
    Given I upload "samples/subsetted/range_aug_1_aug_31/WTC01_Table1.dat" with type "RAW" and description "orig desc" and experiment "My Experiment"
    When I upload "samples/subsetted/range_aug_1_aug_31/WTC01_Table1.dat" with type "RAW" and description "" and experiment "My Experiment"
    And I am on the list data files page
    Then I should see only these rows in "exploredata" table
      | Filename         | Added by                    | Type |
      | WTC01_Table1.dat | researcher@intersect.org.au | RAW  |
    When I follow the view link for data file "WTC01_Table1.dat"
    Then I should see details displayed
      | Type        | RAW       |
      | Description | orig desc |

  Scenario: Identical file is considered a safe overlap and keeps entered description when entered
    Given I upload "samples/subsetted/range_aug_1_aug_31/WTC01_Table1.dat" with type "RAW" and description "orig desc" and experiment "My Experiment"
    When I upload "samples/subsetted/range_aug_1_aug_31/WTC01_Table1.dat" with type "RAW" and description "new desc" and experiment "My Experiment"
    And I am on the list data files page
    Then I should see only these rows in "exploredata" table
      | Filename         | Added by                    | Type |
      | WTC01_Table1.dat | researcher@intersect.org.au | RAW  |
    When I follow the view link for data file "WTC01_Table1.dat"
    Then I should see details displayed
      | Type        | RAW      |
      | Description | new desc |

  Scenario Outline: Outcome of all possible overlap scenarios (overlaps a single file only with identical content)
    Given I upload "samples/overlap_tests/8_9_10_oct.dat" with type "RAW" and description "orig desc" and experiment "My Experiment"
    When I upload "<new file>" with type "RAW" and description "new desc" and experiment "My Experiment"
    Then I should see "<message>"
    And file "<new file>" should have type "<resulting type>"
    And there should be files named "<files afterwards>" in the system
    And there should be files named "<deleted files>" that were deleted
  Examples:
    | new file                                    | resulting type | files afterwards                 | message                                                                                                      | comment                             | deleted files  |
    | samples/overlap_tests/6_oct.dat             | RAW            | 8_9_10_oct.dat, 6_oct.dat        | File uploaded successfully.                                                                                  | no overlap                          |                |
    | samples/overlap_tests/6_7_oct.dat           | RAW            | 8_9_10_oct.dat, 6_7_oct.dat      | File uploaded successfully.                                                                                  | no overlap - adjacent               |                |
    | samples/overlap_tests/6_7_8_oct.dat         | ERROR          | 8_9_10_oct.dat, 6_7_8_oct.dat    | File cannot safely replace existing files. File has been saved with type ERROR. Overlaps with 8_9_10_oct.dat | unsafe - doesn't cover              |                |
    | samples/overlap_tests/6_7_8_9_oct.dat       | ERROR          | 8_9_10_oct.dat, 6_7_8_9_oct.dat, | File cannot safely replace existing files. File has been saved with type ERROR. Overlaps with 8_9_10_oct.dat | unsafe - doesn't cover              |                |
    | samples/overlap_tests/6_7_8_9_10_oct.dat    | RAW            | 6_7_8_9_10_oct.dat               | The file replaced one or more other files with similar data. Replaced files: 8_9_10_oct.dat                  | safe - starts before, stops at same | 8_9_10_oct.dat |
    | samples/overlap_tests/6_7_8_9_10_11_oct.dat | RAW            | 6_7_8_9_10_11_oct.dat            | The file replaced one or more other files with similar data. Replaced files: 8_9_10_oct.dat                  | safe - starts before, stops after   | 8_9_10_oct.dat |
    | samples/overlap_tests/8_9_oct.dat           | ERROR          | 8_9_10_oct.dat, 8_9_oct.dat      | File cannot safely replace existing files. File has been saved with type ERROR. Overlaps with 8_9_10_oct.dat | unsafe - doesn't cover              |                |
    | samples/overlap_tests/8_9_10_oct.dat        | RAW            | 8_9_10_oct.dat                   | The file replaced one or more other files with similar data. Replaced files: 8_9_10_oct.dat                  | exact match                         |                |
    | samples/overlap_tests/8_9_10_11_oct.dat     | RAW            | 8_9_10_11_oct.dat                | The file replaced one or more other files with similar data. Replaced files: 8_9_10_oct.dat                  | safe - starts at same, ends after   | 8_9_10_oct.dat |
    | samples/overlap_tests/9_oct.dat             | ERROR          | 8_9_10_oct.dat, 9_oct.dat        | File cannot safely replace existing files. File has been saved with type ERROR. Overlaps with 8_9_10_oct.dat | unsafe - doesn't cover              |                |
    | samples/overlap_tests/9_10_oct.dat          | ERROR          | 8_9_10_oct.dat, 9_10_oct.dat     | File cannot safely replace existing files. File has been saved with type ERROR. Overlaps with 8_9_10_oct.dat | unsafe - doesn't cover              |                |
    | samples/overlap_tests/9_10_11_oct.dat       | ERROR          | 8_9_10_oct.dat, 9_10_11_oct.dat  | File cannot safely replace existing files. File has been saved with type ERROR. Overlaps with 8_9_10_oct.dat | unsafe - doesn't cover              |                |
    | samples/overlap_tests/11_oct.dat            | RAW            | 8_9_10_oct.dat, 11_oct.dat       | File uploaded successfully.                                                                                  | no overlap - adjacent               |                |
    | samples/overlap_tests/12_oct.dat            | RAW            | 8_9_10_oct.dat, 12_oct.dat       | File uploaded successfully.                                                                                  | no overlap                          |                |

  Scenario Outline: Outcome of overlap scenarios where it could be safe but the content doesn't match
    Given I upload "samples/overlap_tests/8_9_10_oct.dat" with type "RAW" and description "orig desc" and experiment "My Experiment"
    When I upload "<new file>" with type "RAW" and description "new desc" and experiment "My Experiment"
    Then I should see "<message>"
    And file "<new file>" should have type "<resulting type>"
    And there should be files named "<files afterwards>" in the system
  Examples:
    | new file                                            | resulting type | files afterwards                              | message                                                                                                      | comment                             |
    | samples/overlap_tests/6_7_8_9_10_oct_altered.dat    | ERROR          | 8_9_10_oct.dat, 6_7_8_9_10_oct_altered.dat    | File cannot safely replace existing files. File has been saved with type ERROR. Overlaps with 8_9_10_oct.dat | safe - starts before, stops at same |
    | samples/overlap_tests/6_7_8_9_10_11_oct_altered.dat | ERROR          | 8_9_10_oct.dat, 6_7_8_9_10_11_oct_altered.dat | File cannot safely replace existing files. File has been saved with type ERROR. Overlaps with 8_9_10_oct.dat | safe - starts before, stops after   |
    | samples/overlap_tests/8_9_10_oct_altered.dat        | ERROR          | 8_9_10_oct.dat, 8_9_10_oct_altered.dat        | File cannot safely replace existing files. File has been saved with type ERROR. Overlaps with 8_9_10_oct.dat | exact match                         |
    | samples/overlap_tests/8_9_10_11_oct_altered.dat     | ERROR          | 8_9_10_oct.dat, 8_9_10_11_oct_altered.dat     | File cannot safely replace existing files. File has been saved with type ERROR. Overlaps with 8_9_10_oct.dat | safe - starts at same, ends after   |

  Scenario Outline: Overlaps scenarios where overlap checking doesn't come into play for various reasons
    Given I upload "samples/overlap_tests/8_9_10_oct.dat" with type "<old type>" and description "orig desc" and experiment "My Experiment"
    When I upload "<new file>" with type "<new type>" and description "new desc" and experiment "My Experiment"
    Then I should see "<message>"
    And file "<new file>" should have type "<resulting type>"
    And there should be files named "<files afterwards>" in the system
  Examples:
    | new file                                            | old type  | new type  | resulting type | files afterwards                              | message                     | comment                                           |
    | samples/overlap_tests/6_7_8_oct.dat                 | RAW       | PROCESSED | PROCESSED      | 8_9_10_oct.dat, 6_7_8_oct.dat                 | File uploaded successfully. | unsafe - doesn't cover but is processed           |
    | samples/overlap_tests/6_7_8_oct.dat                 | PROCESSED | RAW       | RAW            | 8_9_10_oct.dat, 6_7_8_oct.dat                 | File uploaded successfully. | unsafe - doesn't cover but original was processed |
    | samples/overlap_tests/6_7_8_oct_altered_station.dat | RAW       | RAW       | RAW            | 8_9_10_oct.dat, 6_7_8_oct_altered_station.dat | File uploaded successfully. | unsafe - doesn't cover but station name mismatch  |
    | samples/overlap_tests/6_7_8_oct_altered_table.dat   | RAW       | RAW       | RAW            | 8_9_10_oct.dat, 6_7_8_oct_altered_table.dat   | File uploaded successfully. | unsafe - doesn't cover but table name mismatch    |

  Scenario: Overlap where new file safely overlaps multiple old files
    Given I upload "samples/overlap_tests/8_9_10_oct.dat" with type "RAW" and description "D1" and experiment "My Experiment"
    And I upload "samples/overlap_tests/11_oct.dat" with type "RAW" and description "D2" and experiment "My Experiment"
    When I upload "samples/overlap_tests/8_9_10_11_oct.dat" with type "RAW" and description "D3" and experiment "My Experiment"
    Then I should see "The file replaced one or more other files with similar data. Replaced files: 8_9_10_oct.dat, 11_oct.dat"
    And file "8_9_10_11_oct.dat" should have type "RAW"
    And there should be files named "8_9_10_11_oct.dat" in the system
    And there should be files named "8_9_10_oct.dat, 11_oct.dat" that were deleted

  Scenario: Overlap where new file safely overlaps one file but unsafely overlaps another
    Given I upload "samples/overlap_tests/8_9_10_oct.dat" with type "RAW" and description "D1" and experiment "My Experiment"
    And I upload "samples/overlap_tests/11_oct.dat" with type "RAW" and description "D2" and experiment "My Experiment"
    When I upload "samples/overlap_tests/9_10_11_oct.dat" with type "RAW" and description "D3" and experiment "My Experiment"
    Then I should see "File cannot safely replace existing files. File has been saved with type ERROR. Overlaps with 8_9_10_oct.dat"
    And file "9_10_11_oct.dat" should have type "ERROR"
    And there should be files named "8_9_10_oct.dat, 11_oct.dat, 9_10_11_oct.dat" in the system

  Scenario: Overlap where new file safely overlaps one file and doesn't overlap another at all
    Given I upload "samples/overlap_tests/8_9_10_oct.dat" with type "RAW" and description "D1" and experiment "My Experiment"
    And I upload "samples/overlap_tests/12_oct.dat" with type "RAW" and description "D2" and experiment "My Experiment"
    When I upload "samples/overlap_tests/8_9_10_11_oct.dat" with type "RAW" and description "D3" and experiment "My Experiment"
    Then I should see "The file replaced one or more other files with similar data. Replaced files: 8_9_10_oct.dat"
    And file "8_9_10_11_oct.dat" should have type "RAW"
    And there should be files named "8_9_10_11_oct.dat, 12_oct.dat" in the system
    And there should be files named "8_9_10_oct.dat" that were deleted

  #EYETRACKER-181
  Scenario: Overlap TOA5 file should maintain parent/child relationships of replaced files
    Given I have uploaded "full_files/weather_station/weather_station_15_min.dat" with type "RAW"
    And I have uploaded "WTC01_Table1.dat" with type "RAW"
    And I have uploaded "sample3.txt" with type "RAW"
    And I have uploaded "package1.zip" with type "RAW"
    And I have uploaded "Test_OCR.jpg" with type "RAW"
    And I have uploaded "toa5.dat" with parents "WTC01_Table1.dat, sample3.txt" and children "package1.zip, Test_OCR.jpg"
    And I upload "samples/toa5.dat" with type "RAW" and description "old TOA5" and experiment "My Experiment" and parents "weather_station_15_min.dat"
    When I upload "samples/toa5.dat" with type "RAW" and description "new TOA5" and experiment "My Experiment"
    Then I should see "The file replaced one or more other files with similar data. Replaced files: toa5.dat"
    And file "toa5.dat" should have parents "weather_station_15_min.dat,WTC01_Table1.dat,sample3.txt"
    And file "toa5.dat" should have children "package1.zip,Test_OCR.jpg"
    And there should be files named "toa5.dat, weather_station_15_min.dat, sample3.txt, WTC01_Table1.dat, package1.zip, Test_OCR.jpg" in the system

  #EYETRACKER-181
  @javascript
  Scenario: Overlap TOA5 file should not produce parent relationships where a file is both parent and child, should not be able to add child as parent during mass update
    Given I have uploaded "1.dat" as "researcher@intersect.org.au" with type "RAW"
    And I have uploaded "sample1.txt" as "researcher@intersect.org.au" with parents "1.dat"
    And I have uploaded "2.dat" as "researcher@intersect.org.au" with parents "sample1.txt"
    When I upload "samples/3.dat" with type "RAW" and description "Problem 2" and experiment "My Experiment"
    Then I should see "The file replaced one or more other files with similar data. Replaced files: 1.dat, 2.dat"
    And file "3.dat" should have children "sample1.txt"
    And file "3.dat" should have parents ""
    And I fill in "Parents" with "sample1.txt" within the file area for '3.dat'
    Then I should see "No matches found"
    And there should be files named "sample1.txt, 3.dat" in the system

