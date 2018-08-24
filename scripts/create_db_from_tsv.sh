#!/bin/bash

FILE=$1

if [ "${FILE}" == "" ] ; then
  echo "usage: create_db_from_tsv.sh <path/to/file.tsv>"
  exit 2
fi

if [ ! -f ${FILE} ] ; then
  echo "no such file:${FILE}"
fi

NAME=`echo ${FILE} | sed 's/\.tsv/.sqlite/g'`

if [ "$NAME" == "$FILE" ] ; then
  NAME="${FILE}.sqlite"
fi

SQL="/tmp/fse-setup.sql"
echo "CREATE TABLE fse (id INTEGER,fullpath TEXT,filename TEXT,type TEXT,flags TEXT,approx_dates_plus_minus_one_day DATE,mask INTEGER,node_id TEXT,record_end_offset INTEGER,source TEXT,source_modified_time DATETIME);" > ${SQL}
echo ".mode tabs " >> ${SQL}
echo ".headers on" >> ${SQL}
echo ".import \"${FILE}\" fse" >> ${SQL}

echo "creating database and importing TSV"

cat "${SQL}" | sqlite3 "${NAME}"

echo "creating fullname index..."

sqlite3 "${NAME}" "CREATE INDEX idx_fse_fullpath ON fse(fullpath)"

exit 0
