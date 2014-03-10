#! /bin/bash

# takes the evidence values and inserts them into the candidate_link table
psql -c """UPDATE candidate_link SET is_correct = 
	(SELECT evidence.is_correct FROM evidence
		WHERE evidence.link_id = candidate_link.id);""" deepdive_spouse
