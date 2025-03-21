Feature: As a user I need to be able to filter through a list of shops so I can find stores that better fit my needs.

    Background:
        Given the user is on the shop list page

    Scenario: User applies a filter 
        When the user selects "Homemade products" category filter
        And applies the filter
        Then only shops with the "Homemade products" tag should be displayed

    Scenario: No stores match the selected filters
        Given the user applies filters that do not match any shop
        Then the system should display a message like "No matches found"

    Scenario: User clears all filters
        Given the user applied filters
        When the user clicks "Clear all filters"
        Then all filters should be turned off
        And the full list of stores displayed again