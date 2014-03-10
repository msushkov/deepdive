#! /usr/bin/env bash

export DBNAME=deepdive_spouse
export PGUSER=${PGUSER:-`whoami`}
export PGPASSWORD=${PGPASSWORD:-}

dropdb deepdive_spouse
createdb deepdive_spouse

psql -d deepdive_spouse < schema.sql
#psql -d deepdive_spouse -c "COPY document FROM STDIN CSV;" < data/articles_dump.csv

# comment this line if you choose to run the first extractor in appliation.conf, which will
# do the NLP processing in full (we include sentences_dump.csv so you don't have to run this)
#psql -d deepdive_spouse -c "COPY sentence FROM STDIN CSV;" < data/sentences_dump.csv

# MAKE SURE YOU HAVE TAC_2010_KBP_Source_Data.tgz in examples/kbp/data/entity-linking

# populate the document table with raw text
cd data/entity-linking
tar -xzvf kbp2010source TAC_2010_KBP_Source_Data.tgz
i=0
FILES=$(find data/entity-linking/kbp2010source -type f -name *.sgm)

for f in $FILES
do
	# docid is the filename
	docid=`basename $f`
	docid="${docid/.txt/}" # get rid of the .txt extension

	# print to stdin: docid<tab>raw_text
	tr '\n' ' ' < $f | tr '\t' ' ' | awk -v id=$docid '{ line=id"\t"$0 } END { print line }' \
	| psql -c "COPY document(id, text) FROM STDIN DELIMITER AS E'\t';" $DB_NAME

	if [ $(( i % 1000 )) -eq 0 ]
		then echo "$i"
	fi

	let i++
done
cd ../..


# populate the entity table
psql -d deepdive_spouse < data/entity-linking/entity.sql

# populate the positive_example table
psql -d deepdive_spouse -c \
	"COPY positive_example FROM STDIN CSV WITH NULL AS 'NIL' DELIMITER AS E'\t';" \
	< data/entity-linking/training.tsv