Feature: As a user I want to be notified of events like eco-markets or new stores in my area so that I can stay informed.

    Background:
        Given the user has enabled notifications for events and new store openings

    Scenario: Receive a notification for an upcoming eco-market
        When  a new eco-market event is scheduled in the user’s area
        Then the user should receive a notification with the event details

    Scenario: User taps on a notification
        Given the user has received a notification about an upcoming event or a store opening
        When the user user taps on the notification
        Then the app should open directly onto the event or store detail page

    Scenario: User disables notifications
        When the user disables notifications in the application's settings
        Then the system should no longer send push notifications about stores or eco-markets