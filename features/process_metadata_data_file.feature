Feature: Process Data files
  In order to manage my data
  As a user
  I want to manually invoke processing of data files

  Background:
    Given I have a user "admin@intersect.org.au" with role "Administrator"
    Given I have a user "researcher@intersect.org.au" with role "Researcher"
    And I am logged in as "admin@intersect.org.au"
    And I have the following system configuration
      | ocr_types  | sr_types    |
      | image/jpeg | audio/x-wav |
    And I have data files
      | filename     | path                 | created_at       | uploaded_by                 | format      | experiment    | file_processing_description | file_processing_status |
      | Test_OCR.jpg | samples/Test_OCR.jpg | 30/11/2011 10:15 | researcher@intersect.org.au | image/jpeg  | My Experiment | Description of my file      | RAW                    |
      | Test_SR.wav  | samples/Test_SR.wav  | 30/11/2011 10:16 | researcher@intersect.org.au | audio/x-wav | My Experiment | Description of my file      | RAW                    |
      | sample1.txt  | samples/sample1.txt  | 30/11/2011 10:16 | researcher@intersect.org.au | text/plain  | My Experiment | Description of my file      | RAW                    |

# EYETRACKER-137

  Scenario: Non supported type does not see the process button
    Given I am on the data file details page for sample1.txt
    And I should not see "OCR"
    And I should not see "SR"

# EYETRACKER-137 EYETRACKER-151 EYETRACKER-140

  Scenario: Check UUID and children are created for a manually invoked image file
    Given I am on the data file details page for Test_OCR.jpg
    And I should not see "SR"
    And I follow "OCR"
    And I should see "Data file has been queued for processing."
    And I should not see "Creation status"
    And I should see details displayed
      | Parents  | No parent files defined. |
      | Children | Test_OCR.jpg.txt         |
    Then file "Test_OCR.jpg.txt" should have a UUID created
    And I should not see "SR"
    And I follow "OCR"
    And I should see "Data file has been queued for processing."
    And I should not see "Creation status"
    And I should see details displayed
      | Parents  | No parent files defined.             |
      | Children | Test_OCR.jpg.txt\nTest_OCR.jpg_1.txt |
    Then file "Test_OCR.jpg_1.txt" should have a UUID created

# EYETRACKER-137 EYETRACKER-151 EYETRACKER-140

  Scenario: Check UUID and children are created for a manually invoked mp3 or wav file
    Given I am on the data file details page for Test_SR.wav
    And I should not see "OCR"
    And I follow "SR"
    And I should see "Data file has been queued for processing."
    And I should see details displayed
      | Parents  | No parent files defined. |
      | Children | Test_SR.wav.txt          |
    And I should not see "Creation status"
    Then file "Test_SR.wav.txt" should have a UUID created
    And I should not see "OCR"
    And I follow "SR"
    And I should see "Data file has been queued for processing."
    And I should not see "Creation status"
    And I should see details displayed
      | Parents  | No parent files defined.           |
      | Children | Test_SR.wav.txt\nTest_SR.wav_1.txt |
    Then file "Test_SR.wav_1.txt" should have a UUID created
