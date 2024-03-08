#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi
echo $($PSQL "TRUNCATE TABLE teams CASCADE")

# Do not change code above this line. Use the PSQL variable above to query your database.
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
# IGNORE FIRST LINE
if [[ $YEAR != "year" ]]
then
  # GET THE WINNING TEAM
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  # IF TEAM IS NOT FOUND, ADD TO TEAMS TABLE
  if [[ -z $WINNER_ID ]]
  then
    INSERT_WINNER_ID=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
    if [[ $INSERT_WINNER_ID = "INSERT 0 1" ]]
    then
      echo Inserted team $WINNER
    fi
    # GET ADDED TEAM'S ID
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  fi

  # GET THE OPPONENT TEAM
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  # IF OPPONENT TEAM IS NOT FOUND, ADD TO TEAMS TABLE
  if [[ -z $OPPONENT_ID ]]
  then
    INSERT_OPPONENT_ID=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
    if [[ $INSERT_OPPONENT_ID = "INSERT 0 1" ]]
    then
      echo Inserted opponent team $OPPONENT
    fi
    # GET ADDED TEAM'S ID
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  fi

  # TEAMS ADDED, NOW ADD INFORMATION TO GAMES TABLE
  INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
fi
done
