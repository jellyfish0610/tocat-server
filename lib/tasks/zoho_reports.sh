#!/bin/bash

rm /tmp/zohoreports*.csv

bundle exec rake zoho:export
bundle exec rake budget:parse

curl -XPOST -F ZOHO_FILE=@/tmp/zohoreports_accounts.csv "https://reportsapi.zoho.com/api/$ZOHO_LOGIN/OpsWay Group/TOCAT_Accounts?ZOHO_ACTION=IMPORT&authtoken=$ZOHO_TOKEN&ZOHO_IMPORT_TYPE=TRUNCATEADD&ZOHO_AUTO_IDENTIFY=true&ZOHO_ON_IMPORT_ERROR=ABORT&ZOHO_OUTPUT_FORMAT=JSON&ZOHO_API_VERSION=1.0&ZOHO_CREATE_TABLE=false"

curl -XPOST -F ZOHO_FILE=@/tmp/zohoreports_transactions.csv "https://reportsapi.zoho.com/api/$ZOHO_LOGIN/OpsWay Group/TOCAT_Transactions?ZOHO_ACTION=IMPORT&authtoken=$ZOHO_TOKEN&ZOHO_IMPORT_TYPE=TRUNCATEADD&ZOHO_AUTO_IDENTIFY=true&ZOHO_ON_IMPORT_ERROR=ABORT&ZOHO_OUTPUT_FORMAT=JSON&ZOHO_API_VERSION=1.0&ZOHO_CREATE_TABLE=false"

curl -XPOST -F ZOHO_FILE=@/tmp/zohoreports_orders.csv "https://reportsapi.zoho.com/api/$ZOHO_LOGIN/OpsWay Group/TOCAT_Orders?ZOHO_ACTION=IMPORT&authtoken=$ZOHO_TOKEN&ZOHO_IMPORT_TYPE=TRUNCATEADD&ZOHO_AUTO_IDENTIFY=true&ZOHO_ON_IMPORT_ERROR=ABORT&ZOHO_OUTPUT_FORMAT=JSON&ZOHO_API_VERSION=1.0&ZOHO_CREATE_TABLE=false"

curl -XPOST -F ZOHO_FILE=@/tmp/zohoreports_teams.csv "https://reportsapi.zoho.com/api/$ZOHO_LOGIN/OpsWay Group/TOCAT_Teams?ZOHO_ACTION=IMPORT&authtoken=$ZOHO_TOKEN&ZOHO_IMPORT_TYPE=TRUNCATEADD&ZOHO_AUTO_IDENTIFY=true&ZOHO_ON_IMPORT_ERROR=ABORT&ZOHO_OUTPUT_FORMAT=JSON&ZOHO_API_VERSION=1.0&ZOHO_CREATE_TABLE=false"

curl -XPOST -F ZOHO_FILE=@/tmp/zohoreports_users.csv "https://reportsapi.zoho.com/api/$ZOHO_LOGIN/OpsWay Group/TOCAT_Users?ZOHO_ACTION=IMPORT&authtoken=$ZOHO_TOKEN&ZOHO_IMPORT_TYPE=TRUNCATEADD&ZOHO_AUTO_IDENTIFY=true&ZOHO_ON_IMPORT_ERROR=ABORT&ZOHO_OUTPUT_FORMAT=JSON&ZOHO_API_VERSION=1.0&ZOHO_CREATE_TABLE=false"

curl -XPOST -F ZOHO_FILE=@/tmp/zohoreports_invoices.csv "https://reportsapi.zoho.com/api/$ZOHO_LOGIN/OpsWay Group/TOCAT_Invoices?ZOHO_ACTION=IMPORT&authtoken=$ZOHO_TOKEN&ZOHO_IMPORT_TYPE=TRUNCATEADD&ZOHO_AUTO_IDENTIFY=true&ZOHO_ON_IMPORT_ERROR=ABORT&ZOHO_OUTPUT_FORMAT=JSON&ZOHO_API_VERSION=1.0&ZOHO_CREATE_TABLE=false"

curl -XPOST -F ZOHO_FILE=@/tmp/zohoreports_tasks.csv "https://reportsapi.zoho.com/api/$ZOHO_LOGIN/OpsWay Group/TOCAT_Tasks?ZOHO_ACTION=IMPORT&authtoken=$ZOHO_TOKEN&ZOHO_IMPORT_TYPE=TRUNCATEADD&ZOHO_AUTO_IDENTIFY=true&ZOHO_ON_IMPORT_ERROR=ABORT&ZOHO_OUTPUT_FORMAT=JSON&ZOHO_API_VERSION=1.0&ZOHO_CREATE_TABLE=false"

curl -XPOST -F ZOHO_FILE=@/tmp/zohoreports_taskorders.csv "https://reportsapi.zoho.com/api/$ZOHO_LOGIN/OpsWay Group/TOCAT_TaskOrders?ZOHO_ACTION=IMPORT&authtoken=$ZOHO_TOKEN&ZOHO_IMPORT_TYPE=TRUNCATEADD&ZOHO_AUTO_IDENTIFY=true&ZOHO_ON_IMPORT_ERROR=ABORT&ZOHO_OUTPUT_FORMAT=JSON&ZOHO_API_VERSION=1.0&ZOHO_CREATE_TABLE=false"

#WorkDone
curl -XPOST -F ZOHO_FILE=@/tmp/delta_budget.csv "https://reportsapi.zoho.com/api/$ZOHO_LOGIN/OpsWay Group/TOCAT_WorkDone?ZOHO_ACTION=IMPORT&authtoken=$ZOHO_TOKEN&ZOHO_IMPORT_TYPE=TRUNCATEADD&ZOHO_AUTO_IDENTIFY=true&ZOHO_ON_IMPORT_ERROR=ABORT&ZOHO_OUTPUT_FORMAT=JSON&ZOHO_API_VERSION=1.0&ZOHO_CREATE_TABLE=false"