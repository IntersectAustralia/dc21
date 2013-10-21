Feature: Manage experiment parameter metadata
  In order to make data more useful to others
  As a researcher
  I want to describe the parameters of my experiment

  Background:
    Given I am logged in as "admin@intersect.org.au"
    And I have the standard set of experiment parameter lookup values
    And I have experiment "Weather Station Experiment"
    And I have experiment "Another Experiment"
    And I have experiment parameters
      | experiment                 | category    | sub_category    | modification  | amount | units     | comments                   |
      | Weather Station Experiment | Atmosphere  | Carbon Dioxide  | Above ambient | 20     | PPM       | A comment about atmosphere |
      | Weather Station Experiment | Temperature | Air Temperature | Below ambient | 25     | Degrees C |                            |
      | Weather Station Experiment | Light       | Natural         | Excluded      |        |           | A comment about the light  |
      | Another Experiment         | Light       | Natural         | Above ambient | 22     |           | A comment about the light  |

  Scenario: View the list of parameters under an experiment
    When I am on the view experiment page for 'Weather Station Experiment'
    Then I should see "experiment_parameters" table with
      | Category    | Subcategory     | Modification  | Amount | Units     | Comments                   |
      | Atmosphere  | Carbon Dioxide  | Above ambient | 20.0   | PPM       | A comment about atmosphere |
      | Light       | Natural         | Excluded      |        |           | A comment about the light  |
      | Temperature | Air Temperature | Below ambient | 25.0   | Degrees C |                            |

  Scenario: View the list when there's nothing to show
    Given I have no experiment parameters
    When I am on the view experiment page for 'Weather Station Experiment'
    Then I should see "There are no parameters to display"

  @javascript
  Scenario: Subcategory dropdown populates based on the category dropdown on create screen
    Given I am on the create experiment parameter page for 'Weather Station Experiment'
    Then the "Category" select should contain
      | Please select a category |
      | Atmosphere               |
      | Humidity                 |
      | Light                    |
      | Temperature              |
    And the "Subcategory" select should contain
      | Please select a category first |
    When I select "Atmosphere" from "Category"
    Then the "Subcategory" select should contain
      | Please select a subcategory |
      | Carbon Dioxide              |
      | Nitrogen                    |
      | Oxygen                      |
  # Change category back to nothing, subcategory switches back too
    When I select "Please select a category" from "Category"
    Then the "Subcategory" select should contain
      | Please select a category first |

  @javascript
  Scenario: Subcategory select doesn't contain 'please select' prompt if there's only one possibility
    Given I am on the create experiment parameter page for 'Weather Station Experiment'
    When I select "Humidity" from "Category"
    Then the "Subcategory" select should contain
      | Normal |

  Scenario: Modification and units dropdowns are populated from the lookup tables
    Given I am on the create experiment parameter page for 'Weather Station Experiment'
    Then the "Modification" select should contain
      | Please select   |
      | Above ambient   |
      | Absolute target |
      | Below ambient   |
      | Excluded        |
    And the "Units" select should contain
      | Please select |
      | Degrees C     |
      | Litres        |
      | Lumens        |
      | Millilitres   |
      | PPM           |

  Scenario: Create a parameter
    Given I am on the view experiment page for 'Weather Station Experiment'
    When I follow "New Parameter"
    And I select "Light" from "Category"
    And I select "Ultraviolet" from "Subcategory"
    And I select "Absolute target" from "Modification"
    And I fill in "Amount" with "10.22"
    And I select "Lumens" from "Units"
    And I fill in "Comments" with "My comment"
    And I press "Save"
    Then I should be on the view experiment page for 'Weather Station Experiment'
    And I should see "experiment_parameters" table with
      | Category    | Subcategory     | Modification    | Amount | Units     | Comments                   |
      | Atmosphere  | Carbon Dioxide  | Above ambient   | 20.0   | PPM       | A comment about atmosphere |
      | Light       | Natural         | Excluded        |        |           | A comment about the light  |
      | Light       | Ultraviolet     | Absolute target | 10.22  | Lumens    | My comment                 |
      | Temperature | Air Temperature | Below ambient   | 25.0   | Degrees C |                            |

  Scenario: Create a parameter with a validation error
    Given I am on the create experiment parameter page for 'Weather Station Experiment'
    And I select "Light" from "Category"
    And I select "Ultraviolet" from "Subcategory"
    And I press "Save"
    Then I should see "Parameter modification can't be blank"

  @javascript
  Scenario: Subcategory dropdown remains populated on validation error
    Given I am on the create experiment parameter page for 'Weather Station Experiment'
    And I select "Light" from "Category"
    And I select "Ultraviolet" from "Subcategory"
    And I press "Save"
    Then "Light" should be selected in the "Category" select
    And "Ultraviolet" should be selected in the "Subcategory" select
    And the "Subcategory" select should contain
      | Please select a subcategory |
      | Infrared                    |
      | Natural                     |
      | Ultraviolet                 |

  Scenario: Cancel out of create
    Given I am on the create experiment parameter page for 'Weather Station Experiment'
    And I follow "Cancel"
    Then I should be on the view experiment page for 'Weather Station Experiment'

  Scenario: Edit an experiment parameter
    Given I am on the view experiment page for 'Weather Station Experiment'
    And I follow the edit link for the experiment parameter for "Temperature"
    Then "Temperature" should be selected in the "Category" select
    And "Air Temperature" should be selected in the "Subcategory" select
    And "Below ambient" should be selected in the "Modification" select
    And the "Amount" field should contain "25.0"
    And "Degrees C" should be selected in the "Units" select
    When I select "Light" from "Category"
    And I select "Ultraviolet" from "Subcategory"
    And I select "Absolute target" from "Modification"
    And I fill in "Amount" with "10.22"
    And I select "Lumens" from "Units"
    And I fill in "Comments" with "My comment"
    And I press "Save"
    Then I should be on the view experiment page for 'Weather Station Experiment'
    And I should see "experiment_parameters" table with
      | Category   | Subcategory    | Modification    | Amount | Units  | Comments                   |
      | Atmosphere | Carbon Dioxide | Above ambient   | 20.0   | PPM    | A comment about atmosphere |
      | Light      | Natural        | Excluded        |        |        | A comment about the light  |
      | Light      | Ultraviolet    | Absolute target | 10.22  | Lumens | My comment                 |

  @javascript
  Scenario: Subcategory dropdown should be populated correctly when editing
    Given I am on the view experiment page for 'Weather Station Experiment'
    And I follow the edit link for the experiment parameter for "Temperature"
    Then "Temperature" should be selected in the "Category" select
    And "Air Temperature" should be selected in the "Subcategory" select
    And "Below ambient" should be selected in the "Modification" select
    And the "Subcategory" select should contain
      | Please select a subcategory |
      | Air Temperature             |
      | Soil Temperature            |

  @javascript
  Scenario: Edit with a validation error
    Given I am on the view experiment page for 'Weather Station Experiment'
    And I follow the edit link for the experiment parameter for "Temperature"
    And I select "Please select a subcategory" from "Subcategory"
    And I press "Save"
    Then I should see "Parameter sub category can't be blank"

  Scenario: Cancel out of editing
    Given I am on the view experiment page for 'Weather Station Experiment'
    And I follow the edit link for the experiment parameter for "Temperature"
    And I follow "Cancel"
    Then I should be on the view experiment page for 'Weather Station Experiment'

  @javascript
  Scenario: Delete
    Given I am on the view experiment page for 'Weather Station Experiment'
    When I follow the delete link for experiment parameter "Temperature"
    And I confirm the popup
    Then I should see "The experiment parameter has been deleted."
    Then I should see "experiment_parameters" table with
      | Category   | Subcategory    | Modification  | Amount | Units | Comments                   |
      | Atmosphere | Carbon Dioxide | Above ambient | 20.0   | PPM   | A comment about atmosphere |
      | Light      | Natural        | Excluded      |        |       | A comment about the light  |

  @javascript
  Scenario: Cancel out of delete
    Given I am on the view experiment page for 'Weather Station Experiment'
    When I follow the delete link for experiment parameter "Temperature"
    And I dismiss the popup
    Then I should see "experiment_parameters" table with
      | Category    | Subcategory     | Modification  | Amount | Units     | Comments                   |
      | Atmosphere  | Carbon Dioxide  | Above ambient | 20.0   | PPM       | A comment about atmosphere |
      | Light       | Natural         | Excluded      |        |           | A comment about the light  |
      | Temperature | Air Temperature | Below ambient | 25.0   | Degrees C |                            |

  Scenario: Must be logged in to view the create, edit pages
    Then users should be required to login on the create experiment parameter page for 'Weather Station Experiment'
    Then users should be required to login on the edit experiment parameter page for 'Atmosphere'
