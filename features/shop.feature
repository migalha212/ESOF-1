Feature: As a user i want to be able to see an establishments whole profile such as product origins and practices so that i can make better informed decisions

    Background: 
        Given the user is on the shop list or map page

    Scenario: Opening an establishment's page
        When the user clicks on a store's profile
        Then the system should display the corresponding store profile along with all available details like name, products for sale and address

    Scenario: Customer reviews and ratings
        Given the user has opened a store's page
        When the user scrolls to the reviews section
        Then reviews and ratings on the corresponding shop should be displayed