Feature: As a user I need to be able to search for shops using a search bar so I can find a specific store faster.

    Background:
        Given the user is on the search page
        And there are no shops that match the name "car repair"

    Scenario: User makes a searches for a store by keyword
        When the user types "fruit" in the search bar
        And the user submits the search
        Then the system should display a list of all stores with "fruit" in their name

    Scenario: User searches for a store that does not exist
        When the user searches for "car repair"
        Then the system should display a message like "No stores found"

    Scenario: User searches with an empty input
        When the user submits an empty search
        Then the system should prompt the user to type something in the search bar and try again