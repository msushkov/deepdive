# the raw text documents
DROP TABLE IF EXISTS document CASCADE;
CREATE TABLE document(
  id text primary key,
  text text
);

# result of doing NLP processing on raw documents
DROP TABLE IF EXISTS sentence CASCADE;
CREATE TABLE sentence(
  id bigserial primary key, 
  document_id text not null references document(id),
  sentence text, 
  words text[],
  pos_tags text[],
  dependencies text[],
  ner_tags text[]
);

# mentions of people in the sentences
DROP TABLE IF EXISTS person_mention CASCADE;
CREATE TABLE person_mention(
  id bigserial primary key, 
  doc_id text not null references document(id),
  sentence_id bigint references sentence(id),
  start_position int,
  length int,
  text text
);

##
# ENTITY LINKING
##

# entities
DROP TABLE IF EXISTS entity CASCADE;
CREATE TABLE entity(
  id text primary key,
  text_contents text not null,
  type text
);

# positive examples - training data provided by KBP
DROP TABLE IF EXISTS el_positive_example CASCADE;
CREATE TABLE el_positive_example(
  doc_id text not null references document(id),
  text_contents text,
  eid text,
  primary key (doc_id, text_contents)
);

# (entity, mention) pairs that could potentially be linked
DROP TABLE IF EXISTS candidate_link CASCADE;
CREATE TABLE el_candidate_link(
  id bigserial primary key,
  eid text not null references entity(id),
  mid bigserial not null references person_mention(id),
  is_correct boolean
);

# a negative example (e2, m1): given a positive example (e1, m1), generate all
# pairs (e2, m1) such that e2 != e1 (for al the other entities, mark that mention as false)
DROP VIEW IF EXISTS negative_example CASCADE;
CREATE VIEW el_negative_example AS
  SELECT c2.mid AS \"mid\", c2.eid AS \"eid\" FROM 
    (candidate_link AS c INNER JOIN mention AS m ON m.id = c.mid) AS c1,
    candidate_link AS c2, positive_example AS p
    WHERE c1.c.eid = p.eid AND c1.c.eid <> c2.eid AND c1.cmid = c2.mid AND p.doc_id = c1.m.doc_id
    AND p.text_contents = c1.m.text_contents;

# populated using positive and negative examples (is_correct = True for pos., False for neg.)
DROP TABLE IF EXISTS evidence CASCADE;
CREATE TABLE el_evidence(
  id bigserial primary key,
  link_id bigint references el_candidate_link(id),
  is_correct boolean
);

# the feature type for the entity-mention link
CREATE TABLE el_link_feature(
  id bigserial primary key,
  link_id bigint not null references el_candidate_link(id),
  feature text
);

##
# RELATION EXTRACTION
##

DROP TABLE IF EXISTS has_spouse CASCADE;
CREATE TABLE has_spouse(
  id bigserial primary key, 
  person1_id bigint references person_mention(id),
  person2_id bigint references person_mention(id),
  sentence_id bigint references sentence(id),
  description text,
  is_true boolean
);

DROP TABLE IF EXISTS has_spouse_feature CASCADE;
CREATE TABLE has_spouse_feature(
  id bigserial primary key, 
  relation_id bigint references has_spouse(id),
  feature text
);