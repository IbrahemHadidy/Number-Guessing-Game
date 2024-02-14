#!/bin/bash

# Function to execute psql with predefined options
number_guess_psql() {
  psql --username=freecodecamp --dbname=number_guess -t --no-align -q -c "$@" 
}

echo -e "\n~~~~ Welcome to the Number Guessing Game! ~~~~"

echo -e "Enter your username:"
read username

result=$(number_guess_psql "SELECT name FROM users WHERE name = '$username'")
if [[ $result ]]; then
  # Get the user's best guess count and games played
  USER_ID=$(number_guess_psql "SELECT id FROM users WHERE name = '$username'")
  best_game=$(number_guess_psql "SELECT min(guesses) FROM games WHERE id = $USER_ID")
  games_played=$(number_guess_psql "SELECT COUNT(*) FROM games WHERE id = $USER_ID")
  echo -e "\nWelcome back, $username! You have played $games_played games, and your best game took $best_game guesses."
else
  # Add the new user to the database
  number_guess_psql "INSERT INTO users (name) VALUES ('$username')"
  USER_ID=$(number_guess_psql "SELECT id FROM users WHERE name = '$username'")
  echo -e "\nWelcome, $username! It looks like this is your first time here."
fi

secret_number=$((1 + RANDOM % 10))
number_of_guesses=0
guessed=0

echo -e "\nGuess the secret number between 1 and 1000:"

while [[ $guessed = 0 ]]; do
  read guess
  # Check if the input is an integer
  if [[ ! $guess =~ ^[0-9]+$ ]]; then
    echo -e "\nThat is not an integer, guess again:"
  else
    ((number_of_guesses++)) 
    if (( guess == secret_number )); then
      echo -e "\nYou guessed it in $number_of_guesses tries. The secret number was $secret_number. Nice job!"
      number_guess_psql "insert into games(id, guesses) values($USER_ID, $number_of_guesses)"
      guessed=1
    elif (( guess > secret_number )); then
      echo -e "\nIt's lower than that, guess again:"
    else
      echo -e "\nIt's higher than that, guess again:"
    fi
  fi
done