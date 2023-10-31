#!/bin/bash

set -e

[ -n "${HOST}" ] || export HOST="localhost"
[ -n "${PORT}" ] || export PORT="5432"
[ -n "${USER}" ] || export USER="odoo"
[ -n "${PASSWORD}" ] || export PASSWORD="odoo"
[ -n "${DB_TIMEOUT}" ] || export DB_TIMEOUT=30

DB_ARGS=""
check_config(){
    param="${1}"
    value="${2}"
    if grep -q -E "^\s*\b${param}\b\s*=" "${ODOO_RC}"; then
        value=$(grep -E "^\s*\b${param}\b\s*=" "${ODOO_RC}" | cut -d " " -f3 | sed 's/["\n\r]//g')
    fi
    DB_ARGS="${DB_ARGS} --${param} ${value}"
}
check_config "db_host"     $HOST
check_config "db_port"     $PORT
check_config "db_user"     $USER
check_config "db_password" $PASSWORD

case "$1" in
    odoo)
        shift
        wait-for-psql.py ${DB_ARGS} --timeout=${DB_TIMEOUT}
        echo odoo/odoo -c ${ODOO_RC} "$@" ${DB_ARGS}
        odoo/odoo -c ${ODOO_RC} "$@" ${DB_ARGS}
        ;;
    odoo-bin)
        shift
        wait-for-psql.py ${DB_ARGS} --timeout=${DB_TIMEOUT}
        echo odoo/odoo-bin -c ${ODOO_RC} "$@" ${DB_ARGS}
        odoo/odoo-bin -c ${ODOO_RC} "$@" ${DB_ARGS}
        ;;
    *)
        exec "$@"
        ;;
esac
