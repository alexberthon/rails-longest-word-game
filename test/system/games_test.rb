require "application_system_test_case"

class GamesTest < ApplicationSystemTestCase
  test "Going to /new gives us a new random grid to play with" do
    visit new_url
    assert test: "New game"
    assert_selector "li", count: 10
  end

  test "Filling in a random word should result in an error saying the word is not in the grid" do
    visit new_url
    fill_in "attempt", with: "AIENFOOPAZ"
    click_on "Send"
    assert_text "is not in the grid"
  end

  test "Filling in non-English word should result in an error saying the word is not a valid English word" do
    visit new_url
    fill_in "attempt", with: "R"
    click_on "Send"
    assert_text "is not an English word"
  end
end
