@announce
Feature: Building the site
  Scenario: Every resource has a history
    Given a fixture app "app-with-history"
    When I run `middleman build --verbose`
    Then the file "build/index.html" should contain 'Initial author: Florian Gilcher'
    Then the file "build/index.html" should contain 'Github profile: https://github.com/skade'
    Then the file "build/index.html" should contain 'Authors: Florian Gilcher, Foo bar'
    Then the file "build/index.html" should contain 'Contributors: Foo bar'
    Then the file "build/index.html" should contain 'Page Info: index.html.erb'
    Then the file "build/index.html" should contain 'Edit URL: https://github.com/skade/remote-test/edit/master/source/index.html.erb'
