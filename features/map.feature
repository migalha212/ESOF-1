Feature: As a user I want to be able to see stores laid out on a map so that I can better search for ones near my location

    Background:
        Given the user is on the map view page

    Scenario: Display all stores on the map
        When the map finishes loading
        Then all available and visible stores should be shown as markers on the map

    Scenario: Locate Stores near the user
        When the user grants the application Location access
        Then the map should center on the user's current location
        And display all visible stores in the new map radius

    Scenario: Clicking on a store markers
        When the user click on a store marker
        Then the store profile of the corresponding store should pop up

    Scenario: Moving the map
        When the user moves the map to a new location
        Then the all the stores visible in the new radius should be displayed
