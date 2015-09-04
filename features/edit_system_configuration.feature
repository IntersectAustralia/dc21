Feature: Edit system configuration
  In order to configure the system to my organisation's details
  As an administrator
  I want to edit the system name and other fields

  Background:
    Given I have users
      | email                     | first_name | last_name |
      | cindy@intersect.org.au    | Cindy      | Wang      |
      | georgina@intersect.org.au | Georgina   | Edwards   |
    And I have the usual roles
    And "georgina@intersect.org.au" has role "Administrator"
    And "cindy@intersect.org.au" has role "Researcher"
    And I have facilities
      | name                |
      | ROS Weather Station |
    And I have experiments
      | name            | description    | start_date | end_date | subject | facility            | parent | access_rights                                    |
      | Weather Station | Blah Blah Blah | 2011-10-30 |          | Rain    | ROS Weather Station |        | http://creativecommons.org/licenses/by-sa/4.0    |
    And I have languages
      | language_name         | iso_code |
      | English               | en       |
      | French                | fr       |
      | Chinese (Traditional) | zh-hant  |

# EYETRACKER-1 EYETRACKER-95

  Scenario: Edit system config fields as admin
    Given I am logged in as "georgina@intersect.org.au"
    And I am on the edit system config page
    When I fill in "Name" with "Hello world"
    And I select "Always" from "Email Level"
    And I press "Update"
    Then I should see "System configuration updated successfully."

# EYETRACKER-151 EYETRACKER-152 EYETRACKER-185

  Scenario: View system config fields as admin
    Given I am logged in as "georgina@intersect.org.au"
    And I am on the system config page
    Then I should see details displayed
      | Local System Name              | DIVER                                |
      | Research Centre Name           | Enter your research centre name here |
      | Overarching Entity             | Enter your institution name here     |
      | Address                        | Enter your address                   |
      | Telephone Numbers              |                                      |
      | Email                          |                                      |
      | Description                    |                                      |
      | URLs                           |                                      |
      | Auto OCR on Upload             | Disabled                             |
      | Auto OCR Regular Expression    |                                      |
      | OCR Supported MIME Types       | image/jpeg, image/png                |
      | ABBYY Host                     |                                      |
      | ABBYY App Name                 |                                      |
      | ABBYY Password                 | *****                                |
      | Auto SR on Upload              | Disabled                             |
      | Auto SR Regular Expression     |                                      |
      | SR Supported MIME Types        | audio/x-wav, audio/mpeg              |
      | Koemei Host                    |                                      |
      | Koemei Login                   |                                      |
      | Koemei Password                | *****                                |
      | Project Parameters             | Enabled                              |
      | Type of Org Unit (Singular)    | Facility                             |
      | Type of Org Unit (Plural)      | Facilities                           |
      | Type of Project (Singular)     | Experiment                           |
      | Type of Project (Plural)       | Experiments                          |
      | Language                       |                                      |
      | Open Access Rights Text        |                                      |
      | Conditional Access Rights Text |                                      |
      | Restricted Access Rights Text  |                                      |
      | Rights Statement               |                                      |
      | Maximum Package Size           | Unlimited                            |
      | Email Level                    |                                      |
      | Research Librarian Email List  |                                      |

  Scenario: Access system config edit page as non-admin
    Given I am logged in as "cindy@intersect.org.au"
    And I am on the edit system config page
    Then I should see "You are not authorized to access this page."
    And I am on the system config page
    Then I should see "You are not authorized to access this page."

  Scenario: Check all mandatory fields are filled in
    Given I am logged in as "georgina@intersect.org.au"
    And I am on the edit system config page
    When I fill in "Name" with ""
    And I fill in "Research Centre Name" with ""
    And I fill in "Entity" with ""
    And I fill in "Type of Org Unit (Singular)" with ""
    And I fill in "Type of Org Unit (Plural)" with ""
    And I fill in "Type of Project (Singular)" with ""
    And I fill in "Type of Project (Plural)" with ""
    And I press "Update"
    Then I should not see "System configuration updated successfully."
    And I should see "Please correct the following before continuing:"
    And I should see "Name can't be blank"
    And I should see "Research centre name can't be blank"
    And I should see "Entity can't be blank"
    And I should see "Type of Org Unit (Singular) can't be blank"
    And I should see "Type of Org Unit (Plural) can't be blank"
    And I should see "Type of Project (Singular) can't be blank"
    And I should see "Type of Project (Plural) can't be blank"

  # EYETRACKER-151 EYETRACKER-152 EYETRACKER-185
  Scenario: Check edited changes are kept after update
    Given I am logged in as "georgina@intersect.org.au"
    And I am on the edit system config page
    When I fill in the following:
      | Local System Name                 | Hello                                                          |
      | Research Centre Name              | World                                                          |
      | Entity                            | !                                                              |
      | Address                           | Test 1                                                         |
      | Telephone Numbers                 | +61 2 23456789                                                 |
      | Email                             | test@test.org.au                                               |
      | Description                       |                                                                |
      | URLs                              | http://www.test.edu.au/hie                                     |
      | Auto OCR on Upload                | on                                                             |
      | Auto OCR Regular Expression       | 1234                                                           |
      | OCR Supported MIME Types          | image/jpeg                                                     |
      | OCR Supported MIME Types          | image/png                                                      |
      | OCR Supported MIME Types          | audio/x-wav                                                    |
      | ABBYY Host                        | Test ABBYY Host                                                |
      | ABBYY App Name                    | Test ABBYY App Name                                            |
      | ABBYY Password                    | Test ABBYY Password                                            |
      | Auto SR on Upload                 | on                                                             |
      | Auto SR Regular Expression        | 1234                                                           |
      | SR Supported MIME Types           | audio/x-wav                                                    |
      | SR Supported MIME Types           | audio/mpeg                                                     |
      | SR Supported MIME Types           | image/jpeg                                                     |
      | Koemei Host                       | www.koemei.com                                                 |
      | Koemei Login                      | test@intersect.org.au                                          |
      | Koemei Password                   | Test Koemei Password                                           |
      | system_configuration[language_id] | English                                                        |
      | Open Access Rights Text           | Open Access Rights Text                                        |
      | Conditional Access Rights Text    | Conditional Access Rights Text                                 |
      | Restricted Access Rights Text     | Restricted Access Rights Text                                  |
      | Rights statement                  | Organic chia pork belly tilde tattooed blog raw denim leggings |
      | Maximum Package Size              | 9.9                                                            |
      | system_configuration[email_level] | Always                                                         |
    And I press "Update"
    And I should be on the system config page
    Then I should see details displayed
      | Local System Name             | Hello                                                          |
      | Research Centre Name          | World                                                          |
      | Overarching Entity            | !                                                              |
      | Address                       | Test 1                                                         |
      | Telephone Numbers             | +61 2 23456789                                                 |
      | Email                         | test@test.org.au                                               |
      | Description                   |                                                                |
      | URLs                          | http://www.test.edu.au/hie                                     |
      | Auto OCR on Upload            | Enabled                                                        |
      | Auto OCR Regular Expression   | 1234                                                           |
      | OCR Supported MIME Types      | audio/x-wav, image/jpeg, image/png                             |
      | ABBYY Host                    | Test ABBYY Host                                                |
      | ABBYY App Name                | Test ABBYY App Name                                            |
      | ABBYY Password                | *****                                                          |
      | Auto SR on Upload             | Enabled                                                        |
      | Auto SR Regular Expression    | 1234                                                           |
      | SR Supported MIME Types       | audio/mpeg, audio/x-wav, image/jpeg                            |
      | Koemei Host                   | www.koemei.com                                                 |
      | Koemei Login                  | test@intersect.org.au                                          |
      | Koemei Password               | *****                                                          |
      | Language                      | English                                                        |
      | Open Access Rights Text       | Open Access Rights Text                                        |
      | Conditional Access Rights Text| Conditional Access Rights Text                                 |
      | Restricted Access Rights Text | Restricted Access Rights Text                                  |
      | Rights Statement              | Organic chia pork belly tilde tattooed blog raw denim leggings |
      | Maximum Package Size          | 9.9 bytes                                                      |
      | Email Level                   | Always                                                         |
    And the system configuration should have
      | ocr_cloud_token | Test ABBYY Password  |
      | sr_cloud_token  | Test Koemei Password |
    And I am on the edit system config page
    When I fill in the following:
      | ABBYY Password  |  |
      | Koemei Password |  |
    And I press "Update"
    And I should be on the system config page
    And the system configuration should have
      | ocr_cloud_token | Test ABBYY Password  |
      | sr_cloud_token  | Test Koemei Password |

  Scenario: Update organisation level 1 and level 2 names
    Given I am logged in as "georgina@intersect.org.au"
    And I am on the system config page
    Then I should see details displayed
      | Type of Org Unit (Singular) | Facility    |
      | Type of Org Unit (Plural)   | Facilities  |
      | Type of Project (Singular)  | Experiment  |
      | Type of Project (Plural)    | Experiments |
    When I am on the view facility page for 'ROS Weather Station'
    Then I should see "Facilities / ROS Weather Station"
    And I should see "Facility"
    And I should see "Edit Facility"
    And I should see "New Experiment"
    And I should see "Experiments"
    When I click on "Edit Facility"
    Then I should see "Facilities / ROS Weather Station / Edit"
    And I should see "Edit Facility"
    When I am on the view experiment page for 'Weather Station'
    Then I should see "Details for the Weather Station Experiment"
    And I should see "Edit Experiment"
    When I am on the edit experiment page for 'Weather Station'
    Then I should see "Facilities / Experiments / Weather Station / Edit"
    And I should see "Edit Experiment"
    When I am on the edit system config page
    And I fill in the following:
      | Type of Org Unit (Singular) | L1 sing |
      | Type of Org Unit (Plural)   | L1 plu  |
      | Type of Project (Singular)  | L2 sing |
      | Type of Project (Plural)    | L2 plu  |
    And I select "Always" from "Email Level"
    And I press "Update"
    And I am on the system config page
    Then I should see details displayed
      | Type of Org Unit (Singular) | L1 sing |
      | Type of Org Unit (Plural)   | L1 plu  |
      | Type of Project (Singular)  | L2 sing |
      | Type of Project (Plural)    | L2 plu  |
    When I am on the view facility page for 'ROS Weather Station'
    Then I should see "L1 plu / ROS Weather Station"
    And I should see "L1 sing"
    And I should see "Edit L1 sing"
    And I should see "New L2 sing"
    And I should see "L2 plu"
    When I click on "Edit L1 sing"
    Then I should see "L1 plu / ROS Weather Station / Edit"
    And I should see "Edit L1 sing"
    When I am on the view experiment page for 'Weather Station'
    Then I should see "Details for the Weather Station L2 sing"
    And I should see "Edit L2 sing"
    When I am on the edit experiment page for 'Weather Station'
    Then I should see "L1 plu / L2 plu / Weather Station / Edit"
    And I should see "Edit L2 sing"

# EYETRACKER-95

  Scenario: Check that the System Name is visible when logged out
    Given I am logged in as "georgina@intersect.org.au"
    And I am on the edit system config page
    When I fill in "Name" with "Hello world"
    And I select "Always" from "Email Level"
    And I press "Update"
    And I follow "Sign out"
    Then I should see "Hello world"

# EYETRACKER-95

  Scenario: Check that the footer contains Intersect Australia and the system name
    When I am on the new user session page
    Then I should see "Developed by Intersect Australia Ltd. Powered by DC21 Version:"
    Given I am logged in as "georgina@intersect.org.au"
    And I am on the edit system config page
    When I fill in "Name" with "Hi World"
    And I press "Update"
    Then I should see "Developed by Intersect Australia Ltd. Powered by DC21 Version:"
    When I follow "Sign out"
    Then I should see "Developed by Intersect Australia Ltd. Powered by DC21 Version:"

# EYETRACKER-101

  Scenario: Check a long level 2 name is truncated with ellipsis on white button
    Given I am logged in as "georgina@intersect.org.au"
    And I have facility "Facility0" with code "f0"
    And I am on the edit system config page
    When I fill in "Type of Project (Singular)" with "long_name_of_20_char"
    And I select "Always" from "Email Level"
    And I press "Update"
    And I am on the facilities page
    And I follow the view link for facility "Facility0"
    Then I should see "New long_na..."

# EYETRACKER-87

  Scenario: Check level 2 Parameters is initially enabled
    Given I am logged in as "georgina@intersect.org.au"
    And I have facility "Facility0" with code "f0"
    And I have experiment "Experiment 1" which belongs to facility "f0"
    And I am on the system config page
    Then I should see field "Project Parameters" with value "Enabled"
    When I am on the edit system config page
    Then the "Project Parameters" checkbox should be checked
    When I am on the facilities page
    And I follow the view link for facility "Facility0"
    And I follow the view link for experiment "Experiment 1"
    Then I should see "Parameters"
    And I should see "New Parameter"

# EYETRACKER-87

  Scenario: Disabling level 2 Parameters is saved on update
    Given I am logged in as "georgina@intersect.org.au"
    And I have facility "Facility0" with code "f0"
    And I have experiment "Experiment 1" which belongs to facility "f0"
    When I am on the edit system config page
    And I uncheck "Project Parameters"
    And I select "Always" from "Email Level"
    And I press "Update"
    When I should be on the system config page
    When I am on the edit system config page
    Then the "Project Parameters" checkbox should not be checked
    When I am on the system config page
    Then I should see field "Project Parameters" with value "Disabled"
    When I am on the facilities page
    And I follow the view link for facility "Facility0"
    And I follow the view link for experiment "Experiment 1"
    Then I should not see "Parameters"
    And I should not see "New Parameter"


# EYETRACKER-138

  Scenario: Saving invalid regex
    Given I am logged in as "georgina@intersect.org.au"
    And I am on the edit system config page
    When I fill in "Auto OCR Regular Expression" with "(unmatched"
    When I fill in "Auto SR Regular Expression" with "+w"
    And I press "Update"
    And I should see "Auto OCR Regular Expression: end pattern with unmatched parenthesis: /(unmatched/"
    And I should see "Auto SR Regular Expression: target of repeat operator is not specified: /+w/"
