[![CircleCI](https://circleci.com/gh/pribytkovskiy/refactoring-example/tree/develop.svg?style=svg)](https://circleci.com/gh/pribytkovskiy/refactoring-example/tree/develop)

[![Maintainability](https://api.codeclimate.com/v1/badges/913a75e8b7e487ba9945/maintainability)](https://codeclimate.com/github/pribytkovskiy/refactoring-example/maintainability)


# Refactor Me

## What is it?

It's a bank application that allows to work with
* Accounts
* Cards
* Money transfers


All the code is in the `account.rb`

## Task

There are a lot of code smells in code of the application.
Our aim is to refactor all the code and remove those code smells
Here is some requirements/rules for refactoring:

- All the specs on all public methods must pass
- You mustn't change too much code in specs
- You mustn't change the logic of application while refactoring!!!
- Rubocop and fasterer must have zero number of errors/warnings
- You must refactor the code from the hughest code smells to the little one
- You could create separate classes

## Public methods

### Account

- creation
- destroy
- load

### Card

- creation
- show all
- destroy

### Money
- put
- withdraw
- send
