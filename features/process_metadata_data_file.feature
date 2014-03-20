Feature: Process Data files
  In order to manage my data
  As a user
  I want to manually invoke processing of data files

  Background:
    Given I have a user "api@intersect.org.au" with role "Non-Institutional User"
    Given I have a user "admin@intersect.org.au" with role "Administrator"
    Given I have a user "researcher@intersect.org.au" with role "Institutional User"
    And I have the following system configuration
      | ocr_types  | sr_types    |
      | image/jpeg | audio/x-wav |
    And I have data files
      | filename     | path                 | created_at       | uploaded_by          | format      | experiment    | file_processing_description | file_processing_status |
      | Test_OCR.jpg | samples/Test_OCR.jpg | 30/11/2011 10:15 | api@intersect.org.au | image/jpeg  | My Experiment | Description of my file      | RAW                    |
      | Test_OCR.png | samples/Test_OCR.png | 30/11/2011 10:15 | api@intersect.org.au | image/jpeg  | My Experiment | Description of my file      | RAW                    |
      | Test_SR.wav  | samples/Test_SR.wav  | 30/11/2011 10:16 | api@intersect.org.au | audio/x-wav | My Experiment | Description of my file      | RAW                    |
      | Test_SR.mp3  | samples/Test_SR.mp3  | 30/11/2011 10:16 | api@intersect.org.au | audio/x-wav | My Experiment | Description of my file      | RAW                    |
      | sample1.txt  | samples/sample1.txt  | 30/11/2011 10:16 | api@intersect.org.au | text/plain  | My Experiment | Description of my file      | RAW                    |

# EYETRACKER-137

  Scenario Outline: Non supported type does not see the process button
    And I am logged in as "<email>"
    Given I am on the data file details page for sample1.txt
    And I should not see "OCR"
    And I should not see "SR"
  Examples:
    | email                       |
    | admin@intersect.org.au      |
    | researcher@intersect.org.au |
    | api@intersect.org.au        |

# EYETRACKER-137 EYETRACKER-151 EYETRACKER-140 EYETRACKER-197

  Scenario Outline: Check UUID and children are created for a manually invoked ocr/sr processing, with correct user's identified for creating output files
    And I am logged in as "<email>"
    Given I am on the data file details page for <file>
    And file "<file>" should be created by "api@intersect.org.au"
    And I should not see "<not see>"
    And I follow "<see>"
    And I should see "Data file has been queued for processing."
    And I should not see "Creation status"
    And I should see details displayed
      | Parents  | No parent files defined. |
      | Children | <file>.txt               |
    Then file "<file>.txt" should have a UUID created
    And file "<file>.txt" should be created by "<email>"
    And I should not see "<not see>"
    And I follow "<see>"
    And I should see "Data file has been queued for processing."
    And I should not see "Creation status"
    And I should see details displayed
      | Parents  | No parent files defined. |    |
      | Children | <file>.txt\n<file>_1.txt | no |
    Then file "<file>_1.txt" should have a UUID created
    And file "<file>_1.txt" should be created by "<email>"
  Examples:
  | file         | email                       | see | not see |
  | Test_OCR.jpg | admin@intersect.org.au      | OCR | SR      |
  | Test_OCR.jpg | researcher@intersect.org.au | OCR | SR      |
  | Test_OCR.png | admin@intersect.org.au      | OCR | SR      |
  | Test_OCR.png | researcher@intersect.org.au | OCR | SR      |
  | Test_SR.wav  | admin@intersect.org.au      | SR  | OCR     |
  | Test_SR.wav  | researcher@intersect.org.au | SR  | OCR     |
  | Test_SR.mp3  | admin@intersect.org.au      | SR  | OCR     |
  | Test_SR.mp3  | researcher@intersect.org.au | SR  | OCR     |
