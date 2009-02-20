DROP TABLE IF EXISTS hypertable;
CREATE TABLE hypertable (
apple,
banana
);
insert into hypertable VALUES ('2007-12-02 08:00:00', 'foo', 'apple:0', 'nothing'), ('2007-12-02 08:00:01', 'foo', 'apple:1', 'nothing'), ('2007-12-02 08:00:02', 'foo', 'apple:2', 'nothing');
insert into hypertable VALUES ('2007-12-02 08:00:03', 'foo', 'banana:0', 'nothing'), ('2007-12-02 08:00:04', 'foo', 'banana:1', 'nothing'), ('2007-12-02 08:00:05', 'bar', 'banana:2', 'nothing');
select * from hypertable display_timestamps;
delete "apple:1" from hypertable where row = 'foo' timestamp '2007-12-02 08:00:01';
select * from hypertable display_timestamps;
delete banana from hypertable where row = 'foo';
select * from hypertable display_timestamps;
insert into hypertable VALUES ('how', 'apple:0', 'nothing'), ('how', 'apple:1', 'nothing'), ('how', 'apple:2', 'nothing');
insert into hypertable VALUES ('now', 'banana:0', 'nothing'), ('now', 'banana:1', 'nothing'), ('now', 'banana:2', 'nothing');
insert into hypertable VALUES ('2007-12-02 08:00:00', 'lowrey', 'apple:0', 'nothing'), ('2007-12-02 08:00:00', 'season', 'apple:1', 'nothing'), ('2007-12-02 08:00:00', 'salt', 'apple:2', 'nothing');
insert into hypertable VALUES ('2028-02-17 08:00:01', 'lowrey', 'apple:0', 'nothing');
insert into hypertable VALUES ('2028-02-17 08:00:00', 'season', 'apple:1', 'nothing');
drop table if exists Pages;
create table Pages ("refer-url", "http-code", timestamp, rowkey, ACCESS GROUP default ("refer-url", "http-code"), ACCESS GROUP misc (timestamp, rowkey));
insert into Pages VALUES ('2008-01-28 22:00:03',  "calendar.boston.com/abington-ma/venues/show/457680-the-cellar-tavern", 'http-code', '200');
select "http-code" from Pages where ROW = "calendar.boston.com/abington-ma/venues/show/457680-the-cellar-tavern" display_timestamps;
delete * from Pages where ROW = "calendar.boston.com/abington-ma/venues/show/457680-the-cellar-tavern" TIMESTAMP '2008-01-28 22:00:10';
select "http-code" from Pages where ROW = "calendar.boston.com/abington-ma/venues/show/457680-the-cellar-tavern" display_timestamps;
DROP TABLE IF EXISTS Pages_clone;
CREATE TABLE Pages_clone LIKE Pages;
SHOW CREATE TABLE Pages_clone;
DROP TABLE IF EXISTS hypertable;
CREATE TABLE hypertable (
a,
b
);
INSERT INTO hypertable VALUES ('2008-06-28 01:00:00', 'k1', 'a', 'a11'),('2008-06-28 01:00:00', 'k1', 'b', 'b11');
INSERT INTO hypertable VALUES ('2008-06-28 01:00:01', 'k2', 'a', 'a21'),('2008-06-28 01:00:01', 'k2', 'b', 'b21');
INSERT INTO hypertable VALUES ('2008-06-28 01:00:02', 'k2', 'b', 'b22');
INSERT INTO hypertable VALUES ('2008-06-28 01:00:03', 'k1', 'a', 'a22');
SELECT * FROM hypertable WHERE ROW = 'k1' AND TIMESTAMP < '2008-06-28 01:00:01' DISPLAY_TIMESTAMPS;
DROP TABLE IF EXISTS hypertable;
CREATE TABLE hypertable ( TestColumnFamily );
LOAD DATA INFILE ROW_KEY_COLUMN=rowkey "hypertable_test.tsv" INTO TABLE hypertable;
SELECT * FROM hypertable;
DROP TABLE IF EXISTS test;
CREATE TABLE test ( e, d );
INSERT INTO test VALUES("k1", "e", "x");
INSERT INTO test VALUES("k1", "d", "x");
DELETE d FROM test WHERE ROW = "k1";
SELECT * FROM test;
DROP TABLE IF EXISTS test;
CREATE TABLE test ( c, b );
INSERT INTO test VALUES('2008-06-30 00:00:01', "k1", "b", "x");
INSERT INTO test VALUES('2008-06-30 00:00:02', "k1", "c", "c1");
INSERT INTO test VALUES('2008-06-30 00:00:03', "k1", "c", "c2");
INSERT INTO test VALUES('2008-07-28 00:00:01', "a", "b", "n");
INSERT INTO test VALUES('2008-07-28 00:00:02', "az", "b", "n");
INSERT INTO test VALUES('2008-07-28 00:00:03', "b", "b", "n");
INSERT INTO test VALUES('2008-07-28 00:00:04', "bz", "b", "n");
INSERT INTO test VALUES('2008-07-28 00:00:05', "c", "b", "n");
INSERT INTO test VALUES('2008-07-28 00:00:06', "cz", "b", "n");
INSERT INTO test VALUES('2008-07-28 00:00:07', "d", "b", "n");
INSERT INTO test VALUES('2008-07-28 00:00:08', "dz", "b", "n");
INSERT INTO test VALUES('2008-07-28 00:00:09', "e", "b", "n");
INSERT INTO test VALUES('2008-07-28 00:00:10', "fz", "b", "n");
INSERT INTO test VALUES('2008-07-28 00:00:11', "g", "b", "n");
INSERT INTO test VALUES('2008-07-28 00:00:12', "gz", "b", "n");
SELECT * FROM test WHERE ('z' < ROW < 'a');
DELETE c FROM test WHERE ROW = "k1";
SELECT * FROM test WHERE TIMESTAMP < '2008-06-30 00:00:04';
SELECT * FROM test WHERE ('a' < ROW < 'b');
SELECT * FROM test WHERE ('a' < ROW <= 'b');
SELECT * FROM test WHERE ('a' <= ROW < 'b');
SELECT * FROM test WHERE ('a' <= ROW <= 'b');
SELECT * FROM test WHERE ('a' <= ROW <= 'e') and TIMESTAMP < '2008-07-28 00:00:04';
SELECT * FROM test WHERE ('a' <= ROW <= 'e') and TIMESTAMP > '2008-07-28 00:00:04';
SELECT * FROM test WHERE ('a' <= ROW <= 'e') and '2008-07-28 00:00:02' <= TIMESTAMP <= '2008-07-28 00:00:07';
SELECT * FROM test WHERE ('a' <= ROW <= 'e') and '2008-07-28 00:00:02' <= TIMESTAMP < '2008-07-28 00:00:07';
SELECT * FROM test WHERE ('a' <= ROW <= 'e') and '2008-07-28 00:00:02' < TIMESTAMP <= '2008-07-28 00:00:07';
SELECT * FROM test WHERE ('a' <= ROW <= 'e') and '2008-07-28 00:00:02' < TIMESTAMP < '2008-07-28 00:00:07';
SELECT * FROM test WHERE ROW =^ 'b';
SELECT * FROM test WHERE (ROW = 'a' or ROW = 'c' or ROW = 'g');
SELECT * FROM test WHERE ('a' < ROW <= 'c' or ROW = 'g' or ROW = 'c');
SELECT * FROM test WHERE (ROW < 'c' or ROW > 'd');
SELECT * FROM test WHERE (ROW < 'b' or ROW =^ 'b');
DROP TABLE IF EXISTS test;
CREATE TABLE test ( tag );
INSERT INTO test VALUES("how", "tag:A", "n");
INSERT INTO test VALUES("now", "tag:a", "n");
INSERT INTO test VALUES("brown", "tag:aa", "n");
INSERT INTO test VALUES("cow", "tag:aal", "n");
INSERT INTO test VALUES("how", "tag:aalii", "n");
INSERT INTO test VALUES("now", "tag:aam", "n");
INSERT INTO test VALUES("brown", "tag:Aani", "n");
INSERT INTO test VALUES("cow", "tag:aardvark", "n");
INSERT INTO test VALUES("how", "tag:aardwolf", "n");
INSERT INTO test VALUES("now", "tag:Aaron", "n");
INSERT INTO test VALUES("brown", "tag:Aaronic", "n");
INSERT INTO test VALUES("cow", "tag:Aaronical", "n");
INSERT INTO test VALUES("how", "tag:Aaronite", "n");
INSERT INTO test VALUES("now", "tag:Aaronitic", "n");
INSERT INTO test VALUES("brown", "tag:Aaru", "n");
INSERT INTO test VALUES("cow", "tag:Ab", "n");
INSERT INTO test VALUES("old", "tag:aba", "n");
INSERT INTO test VALUES("macdonald", "tag:Ababdeh", "n");
INSERT INTO test VALUES("had", "tag:Ababua", "n");
INSERT INTO test VALUES("a", "tag:abac", "n");
INSERT INTO test VALUES("farm", "tag:abaca", "n");
INSERT INTO test VALUES("old", "tag:abacate", "n");
INSERT INTO test VALUES("macdonald", "tag:abacay", "n");
INSERT INTO test VALUES("had", "tag:abacinate", "n");
INSERT INTO test VALUES("a", "tag:abacination", "n");
INSERT INTO test VALUES("farm", "tag:abaciscus", "n");
INSERT INTO test VALUES("old", "tag:abacist", "n");
INSERT INTO test VALUES("macdonald", "tag:aback", "n");
INSERT INTO test VALUES("had", "tag:abactinal", "n");
INSERT INTO test VALUES("a", "tag:abactinally", "n");
INSERT INTO test VALUES("farm", "tag:abaction", "n");
INSERT INTO test VALUES("old", "tag:abactor", "n");
INSERT INTO test VALUES("macdonald", "tag:abaculus", "n");
INSERT INTO test VALUES("had", "tag:abacus", "n");
INSERT INTO test VALUES("a", "tag:Abadite", "n");
INSERT INTO test VALUES("farm", "tag:abaff", "n");
INSERT INTO test VALUES("kaui", "tag:abaft", "n");
INSERT INTO test VALUES("maui", "tag:abaisance", "n");
INSERT INTO test VALUES("oahu", "tag:abaiser", "n");
INSERT INTO test VALUES("kaui", "tag:abaissed", "n");
INSERT INTO test VALUES("maui", "tag:abalienate", "n");
INSERT INTO test VALUES("oahu", "tag:abalienation", "n");
INSERT INTO test VALUES("bar", "tag:abalone", "n");
INSERT INTO test VALUES("bar", "tag:Abama", "n");
INSERT INTO test VALUES("bar", "tag:abampere", "n");
INSERT INTO test VALUES("bar", "tag:abandon", "n");
INSERT INTO test VALUES("bar", "tag:abandonable", "n");
INSERT INTO test VALUES("bar", "tag:abandoned", "n");
INSERT INTO test VALUES("bar", "tag:abandonedly", "n");
INSERT INTO test VALUES("bar", "tag:acutonodose", "n");
INSERT INTO test VALUES("foo", "tag:acutorsion", "n");
INSERT INTO test VALUES("foo", "tag:acyanoblepsia", "n");
INSERT INTO test VALUES("foo", "tag:acyanopsia", "n");
INSERT INTO test VALUES("bar", "tag:acyclic", "n");
INSERT INTO test VALUES("foo", "tag:acyesis", "n");
INSERT INTO test VALUES("foo", "tag:acyetic", "n");
INSERT INTO test VALUES("foo", "tag:acystia", "n");
INSERT INTO test VALUES("bar", "tag:ad", "n");
INSERT INTO test VALUES("foo", "tag:Ada", "n");
INSERT INTO test VALUES("foo", "tag:adactyl", "n");
INSERT INTO test VALUES("foo", "tag:adactylia", "n");
INSERT INTO test VALUES("foo", "tag:adactylism", "n");
INSERT INTO test VALUES("foo", "tag:adactylous", "n");
INSERT INTO test VALUES("foo", "tag:adage", "n");
INSERT INTO test VALUES("bar", "tag:adagial", "n");
INSERT INTO test VALUES("foo", "tag:adagietto", "n");
INSERT INTO test VALUES("foo", "tag:adamantoblast", "n");
INSERT INTO test VALUES("bar", "tag:adamantoblastoma", "n");
INSERT INTO test VALUES("foo", "tag:adamantoid", "n");
SELECT * from test WHERE "farm","tag:abaca" < CELL < "had","tag:abacinate";
SELECT * from test WHERE "farm","tag:abaca" <= CELL < "had","tag:abacinate";
SELECT * from test WHERE "farm","tag:abaca" < CELL <= "had","tag:abacinate";
SELECT * from test WHERE "farm","tag:abaca" <= CELL <= "had","tag:abacinate";
SELECT * from test WHERE CELL = "foo","tag:adactylism";
SELECT * from test WHERE CELL =^ "foo","tag:ac";
SELECT * from test WHERE CELL =^ "foo","tag:a";
SELECT * from test WHERE CELL > "old","tag:abacate";
SELECT * from test WHERE CELL >= "old","tag:abacate";
SELECT * from test WHERE "old","tag:foo" < CELL >= "old","tag:abacate";
SELECT * FROM test WHERE ( CELL = "maui","tag:abaisance" OR CELL = "foo","tag:adage" OR CELL = "cow","tag:Ab" OR CELL =^ "foo","tag:acya");
DROP TABLE IF EXISTS test;
CREATE TABLE test ( name, address, tag, phone );
INSERT INTO test VALUES("foo", "name", "Joe");
INSERT INTO test VALUES("foo", "address", "1234 Main Street");
INSERT INTO test VALUES("foo", "tag", "test");
INSERT INTO test VALUES("foo", "tag:height", "5'9");
INSERT INTO test VALUES("foo", "tag:weight", "150lb");
INSERT INTO test VALUES("foo", "phone", "2455542");
SELECT * from test WHERE "foo","tag" <= CELL < "foo","phone";

#
# Issue 154
#
CREATE TABLE bug ( F MAX_VERSIONS=1 );
SELECT * FROM bug;
INSERT INTO bug VALUES ('R','F:Q','V1');
SELECT * FROM bug;
DELETE 'F:Q' FROM bug WHERE ROW = 'R';
SELECT * FROM bug;
INSERT INTO bug VALUES ('R','F:Q','V2');
SELECT * FROM bug;
DELETE 'F:Q' FROM bug WHERE ROW = 'R';
SELECT * FROM bug;
INSERT INTO bug VALUES ('R','F:Q','V3');
SELECT * FROM bug;
DELETE 'F:Q' FROM bug WHERE ROW = 'R';
SELECT * FROM bug;
INSERT INTO bug VALUES ('R','F:Q','V4');
SELECT * FROM bug;
DELETE 'F:Q' FROM bug WHERE ROW = 'R';
SELECT * FROM bug;
INSERT INTO bug VALUES ('R','F:Q','V5');
SELECT * FROM bug;
DELETE 'F:Q' FROM bug WHERE ROW = 'R';
SELECT * FROM bug;
INSERT INTO bug VALUES ('R','F:Q','V6');
SELECT * FROM bug;
DROP TABLE bug;
CREATE TABLE bug ( F MAX_VERSIONS=2 );
SELECT * FROM bug;
INSERT INTO bug VALUES ('R','F:Q','V1');
SELECT * FROM bug;
DELETE 'F:Q' FROM bug WHERE ROW = 'R';
SELECT * FROM bug;
INSERT INTO bug VALUES ('R','F:Q','V2');
SELECT * FROM bug;
DELETE 'F:Q' FROM bug WHERE ROW = 'R';
SELECT * FROM bug;
INSERT INTO bug VALUES ('R','F:Q','V3');
SELECT * FROM bug;
DELETE 'F:Q' FROM bug WHERE ROW = 'R';
SELECT * FROM bug;
INSERT INTO bug VALUES ('R','F:Q','V4');
SELECT * FROM bug;
DELETE 'F:Q' FROM bug WHERE ROW = 'R';
SELECT * FROM bug;
INSERT INTO bug VALUES ('R','F:Q','V5');
SELECT * FROM bug;
DELETE 'F:Q' FROM bug WHERE ROW = 'R';
SELECT * FROM bug;
INSERT INTO bug VALUES ('R','F:Q','V6');
INSERT INTO bug VALUES ('R','F:Q','V7');
SELECT * FROM bug;
INSERT INTO bug VALUES ('R','F:Q','V8');
SELECT * FROM bug;
DROP TABLE bug;
DROP TABLE IF EXISTS column_family_ttl;
CREATE TABLE test_column_family_ttl (
apple TTL = 3 seconds,
banana TTL = 6 seconds,
persistent 
);
insert into test_column_family_ttl VALUES ('foo', 'apple:0', 'nothing'), ('foo', 'apple:1', 'nothing'), ('bar', 'apple:2', 'nothing');
insert into test_column_family_ttl VALUES ('foo', 'banana:0', 'nothing'), ('bar', 'banana:1', 'nothing'), ('bar', 'banana:2', 'nothing');
insert into test_column_family_ttl VALUES ('foo', 'persistent:0', 'nothing'), ('foo', 'persistent:1', 'nothing'), ('bar', 'persistent:2', 'nothing');
select * from test_column_family_ttl;
pause 4;
select * from test_column_family_ttl;
pause 4;
select * from test_column_family_ttl;
DROP TABLE test_column_family_ttl;
DROP TABLE IF EXISTS Pages;
CREATE TABLE Pages (
 'refer-url',
 'http-code',
 date,
 ACCESS GROUP default ( 'refer-url', 'http-code' )
);
insert into Pages values("2008-11-11 12:00:00.000000","www.google.com", "refer-url", "www.yahoo.com");
insert into Pages values("2008-11-11 12:00:00.000000","www.google.com", "http-code", "200");
insert into Pages values("2008-11-11 12:00:00.000000","www.google.com", "date", "2008/11/11");
insert into Pages values("2008-11-12 12:00:00.000000","www.google.com", "refer-url", "www.yahoo.com");
insert into Pages values("2008-11-12 12:00:00.000000","www.google.com", "http-code", "404");
insert into Pages values("2008-11-12 12:00:00.000000","www.google.com", "date", "2008/11/12");
select * from Pages display_timestamps;
delete 'http-code' from Pages where row="www.google.com";
select * from Pages display_timestamps;

#
#ALTER TABLE
#
DROP table if exists Fruits;
CREATE TABLE Fruits (
 'refer-url',
 'http-code',
 ACCESS GROUP ag1 ( 'refer-url'), 
 ACCESS GROUP ag2 ( 'http-code' )
);
insert into Fruits values("www.google.com", "refer-url", "www.yahoo.com");
insert into Fruits values("www.google.com", "http-code", "200");
ALTER TABLE Fruits ADD(
  'Red', 
  ACCESS GROUP ag3 ('Red')
);
insert into Fruits values("www.google.com", "Red", "Apple");
insert into Fruits values("www.yahoo.com", "Red", "Grapefruit");
select * from Fruits;
ALTER TABLE Fruits DROP('http-code');
select * from Fruits where row="www.google.com";
ALTER TABLE Fruits DROP('Red');
insert into Fruits values("www.google.com", "Red", "Dragonfruit");
ALTER TABLE Fruits ADD(
  'Orange', 
  'Red', 
  ACCESS GROUP ag3('Red', 'Orange')
);
insert into Fruits values("www.google.com", "Red", "Raspberry");
insert into Fruits values("www.yahoo.com", "Orange", "Clementine");
select * from Fruits;

ALTER TABLE Fruits Add('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Drop('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Add('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Drop('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Add('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Drop('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Add('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Drop('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Add('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Drop('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Add('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Drop('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Add('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Drop('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Add('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Drop('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Add('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Drop('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Add('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Drop('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Add('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Drop('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Add('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Drop('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Add('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Drop('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Add('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Drop('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Add('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Drop('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Add('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Drop('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Add('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Drop('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Add('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Drop('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Add('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Drop('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Add('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Drop('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Add('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Drop('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Add('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Drop('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Add('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Drop('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Add('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Drop('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Add('1','2','3','4','5','6','7','8','9','10');
ALTER TABLE Fruits Drop('1','2','3','4','5','6','7','8','9','10');
DESCRIBE Table Fruits;
ALTER TABLE Fruits Add('1');
quit;
