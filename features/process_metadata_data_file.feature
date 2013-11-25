Feature: Process Data files
  In order to manage my data
  As a user
  I want to manually invoke processing of data files

 Background:
    Given I have a user "admin@intersect.org.au" with role "Administrator"
    Given I have a user "researcher@intersect.org.au" with role "Researcher"
    And I am logged in as "admin@intersect.org.au"
    And I have data files
      | filename     | path                 | created_at       | uploaded_by                 | format      | experiment     | file_processing_description | file_processing_status |
      | Test_OCR.jpg | samples/Test_OCR.jpg |30/11/2011 10:15  | researcher@intersect.org.au | image/jpeg  | My Experiment  | Description of my file      | RAW                    |
      | Test_SR.wav  | samples/Test_SR.wav  |30/11/2011 10:16  | researcher@intersect.org.au | audio/x-wav | My Experiment  | Description of my file      | RAW                    |

  @wip @javascript

  Scenario: Must be logged in to view the show page
    Then users should be required to login on the data file details page

  Scenario: Check no UUID is created for a non-uploaded file
    Given I am on the data file details page for Test_OCR.jpg
    Then file "Test_OCR.jpg" should not have a UUID created

  # EYETRACKER-137
  Scenario: Check UUID is created for a manually invoked image file
    Given I am on the data file details page for Test_OCR.jpg
    And I follow "Start Metadata extraction" 
    And I should see "Data file has been queued for processing."
    Then file "Test_OCR.jpg" should have a UUID created

  # EYETRACKER-137
  Scenario: Check UUID is created for a manually invoked mp3 or wav file
    Given I am on the data file details page for Test_SR.wav
    And I follow "Start Metadata extraction" 
    And I should see "Data file has been queued for processing."
    Then file "Test_SR.wav" should have a UUID created
