#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
  echo -e "\n~~ Test environment ~~\n"
  echo -e "--dbname=worldcuptest\n"
  PARAMETER=true
  echo $($PSQL "TRUNCATE teams, games")
elif [[ $1 == "production" ]]
then
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
  echo -e "\n~~ Production environment ~~\n"
  echo -e "--dbname=worldcup\n"
  PARAMETER=true
  echo $($PSQL "TRUNCATE teams, games")
else
  echo "Add either the parameter 'test' or 'production' when executing the script."
  PARAMETER=false
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# Note! I did change the code above, but only so that I wouldn't accidentally execute the script outside of the test environment.

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != year && $PARAMETER == true ]]
  then
    # get team_id
    WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    # if winner not found
    if [[ -z $WINNER_TEAM_ID ]]
    then
      # insert name
      INSERT_TEAMS_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      echo "Inserted into teams, $WINNER"
    fi
     # if opponent not found
    if [[ -z $OPPONENT_TEAM_ID ]]
    then
      # insert name
      INSERT_TEAMS_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      echo "Inserted into teams, $OPPONENT"
    fi
    # get new team_id's
    WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # Insert game data
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, winner_id, opponent_id, winner_goals, opponent_goals, round) VALUES($YEAR, $WINNER_TEAM_ID, $OPPONENT_TEAM_ID, $WINNER_GOALS, $OPPONENT_GOALS, '$ROUND')")
    echo "Inserted into games, $YEAR, $WINNER_TEAM_ID, $OPPONENT_TEAM_ID, $WINNER_GOALS, $OPPONENT_GOALS, $ROUND"
  fi
done