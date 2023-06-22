#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ STARBUCKER SALON ~~~~~\n"

echo -e "Welcome to the Starbucker Salon!.How may I help you?\n" 

MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
    echo "$SERVICES" | while read SERVICE_ID NAME
   do
   echo -e "$SERVICE_ID)$NAME" | sed 's/|//g'
  done
  
  read SERVICE_ID_SELECTED
    if [[  $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
    VALID_SELECTION=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED ")
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED ")
    fi
  # if no times are available
  if [[ -z $VALID_SELECTION ]]; then
      MENU "Invalid option chosen. Please try again.\n"
    else
      # Get customer info
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")

        # if customer doesn't exist
        if [[ -z $CUSTOMER_NAME ]]; then
        # Customer doesn't exist, prompt for name and insert new customer
        echo -e "\nThis number has no recorded history with us. What's your name?"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
      fi

      echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
        ADD_APPOINTMENT=$($PSQL "INSERT INTO appointments (time,name,customer_id,service_id ) VALUES ('$SERVICE_TIME', '$CUSTOMER_NAME', $CUSTOMER_ID,$SERVICE_ID_SELECTED);")
        echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    
  fi
}
MENU
