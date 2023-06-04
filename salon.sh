#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  
  echo "Welcome to My Salon, how can I help you?" 
  SERVICE_LIST=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICE_LIST" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    [1-5]) SERVICE_MENU ;;
    *) MAIN_MENU "I could not find that service. What would you like today?\n" ;;
  esac

   }

SERVICE_MENU() {
  # get service name
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  # get customer info
  echo -e "\nWhats your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_NAME ]]
  then
    # asking for name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    # insert new customer
    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  
    # ask what time
    echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed 's/ *//g'), $(echo $CUSTOMER_NAME | sed 's/ *//g')?"
    read SERVICE_TIME
  else
    # ask what time
      echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed 's/ *//g'), $(echo $CUSTOMER_NAME | sed 's/ *//g')?"
      read SERVICE_TIME
  fi

  # get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # add appointment
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  # output msg
  echo "I have put you down for a $(echo $SERVICE_NAME | sed 's/ *//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed 's/ *//g')."
  EXIT
}

EXIT() {
 echo -e "\nThank you and welcome again!\n"
}

MAIN_MENU
