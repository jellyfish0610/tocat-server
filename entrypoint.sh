#!/bin/bash
set -e

[[ $DEBUG == true ]] && set -x

case ${1} in
  app:init|app:start|app:rake)

    case ${1} in
      app:start)
	  sleep 1
	  env |sed 's/^\(.*\)$/export \1/g' >/root/.profile
          cd $TOCAT_HOME && envsubst < lib/google_app_secrets.json > config/google_app_secrets.json
	  cd $TOCAT_HOME && bundle exec whenever -w;
	  service rsyslog start
	  service sendmail start
	  service cron start
          cd $TOCAT_HOME && bundle exec rake db:migrate && bundle exec thin -C config/thin.yml -a 0.0.0.0 -p 3000 start;
        ;;
      app:init)
          sleep 1
	  env |sed 's/^\(.*\)$/export \1/g' >/root/.profile
          cd $TOCAT_HOME && envsubst < lib/google_app_secrets.json > config/google_app_secrets.json
          bundle exec rake db:create
          bundle exec rake db:migrate
          cd $TOCAT_HOME && bundle exec whenever -w;
	  service rsyslog start
	  service sendmail start
          service cron start
          ;;
      app:rake)
        shift 1
        bundle exec rake $@
        ;;
    esac
    ;;
  app:help)
    echo "Available options:"
    echo " app:start          - Starts the tocat server (default)"
    echo " app:init           - Initialize the tocat server (e.g. create databases), but don't start it."
    echo " app:rake <task>    - Execute a rake task."
    echo " [command]          - Execute the specified command, eg. bash."
    ;;
  *)
    exec "$@"
    ;;
esac
