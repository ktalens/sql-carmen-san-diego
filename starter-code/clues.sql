              List of relations
 Schema |       Name       | Type  |  Owner  
--------+------------------+-------+---------
 public | cities           | table | ktalens
 public | countries        | table | ktalens
 public | countrylanguages | table | ktalens
(3 rows)

-- Clue #1: We recently got word that someone fitting Carmen Sandiego's description has been
-- traveling through Southern Europe. She's most likely traveling someplace where she won't be noticed,
-- so find the least populated country in Southern Europe, and we'll start looking for her there.
COUNTRY:
code| name | continent | region | surfacearea  | indepyear | population | lifeexpectancy | gnp | gnpold | localname | governmentform | headofstate | capital | code2 

SELECT 
    name, 
    region, 
    population 
FROM countries 
WHERE continent = 'Europe' 
    AND region = 'Southern Europe' 
ORDER BY population ASC;

RESULTS:
              name               |     region      | population 
---------------------------------+-----------------+------------
 Holy See (Vatican Cities State) | Southern Europe |       1000
 Gibraltar                       | Southern Europe |      25000
 San Marino                      | Southern Europe |      27000
 Andorra                         | Southern Europe |      78000
 Malta                           | Southern Europe |     380200
 Slovenia                        | Southern Europe |    1987800
 Macedonia                       | Southern Europe |    2024000
 Albania                         | Southern Europe |    3401200
 Bosnia and Herzegovina          | Southern Europe |    3972000
 Croatia                         | Southern Europe |    4473000
 Portugal                        | Southern Europe |    9997600
 Greece                          | Southern Europe |   10545700
 Yugoslavia                      | Southern Europe |   10640000
 Spain                           | Southern Europe |   39441700
 Italy                           | Southern Europe |   57680000

-- Clue #2: Now that we're here, we have insight that Carmen was seen attending language classes in
-- this country's officially recognized language. Check our databases and find out what language is
-- spoken in this country, so we can call in a translator to work with you.
SELECT * FROM countrylanguages LIMIT 1;
 countrycode | language | isofficial | percentage 
-------------+----------+------------+------------
 AFG         | Pashto   | t          |       52.4

SELECT name, 
    language, 
    isofficial, 
    percentage 
FROM countries 
LEFT JOIN countrylanguages 
    ON (countries.code=countrylanguages.countrycode) 
WHERE name LIKE 'Holy See%' 
    AND isofficial= 't' 
ORDER BY percentage DESC;

RESULTS:
              name               | language | isofficial | percentage 
---------------------------------+----------+------------+------------
 Holy See (Vatican Cities State) | Italian  | t          |          0
-- Clue #3: We have new news on the classes Carmen attended – our gumshoes tell us she's moved on
-- to a different country, a country where people speak only the language she was learning. Find out which
--  nearby country speaks nothing but that language.
SELECT 
    name, 
    language, 
    isofficial, 
    percentage 
FROM countries 
    LEFT JOIN countrylanguages 
        ON (countries.code=countrylanguages.countrycode) 
WHERE continent = 'Europe' AND region = 'Southern Europe' 
ORDER BY percentage DESC;

RESULTS:
              name               |    language    | isofficial | percentage 
---------------------------------+----------------+------------+------------
 San Marino                      | Italian        | t          |        100
 Bosnia and Herzegovina          | Serbo-Croatian | t          |       99.2
 Portugal                        | Portuguese     | t          |         99
 Greece                          | Greek          | t          |       98.5
 Albania                         | Albaniana      | t          |       97.9
 Croatia                         | Serbo-Croatian | t          |       95.9
 Malta                           | Maltese        | t          |       95.8
 Italy                           | Italian        | t          |       94.1
 Gibraltar                       | English        | t          |       88.9
 Slovenia                        | Slovene        | t          |       87.9
 Yugoslavia                      | Serbo-Croatian | t          |       75.2
 Spain                           | Spanish        | t          |       74.4
 Macedonia                       | Macedonian     | t          |       66.5
 Andorra                         | Spanish        | f          |       44.6
 Andorra                         | Catalan        | t          |       32.3
 Macedonia                       | Albaniana      | f          |       22.9
 Spain                           | Catalan        | f          |       16.9
 Yugoslavia                      | Albaniana      | f          |       16.5
:

-- Clue #4: We're booking the first flight out – maybe we've actually got a chance to catch her this time.
 -- There are only two cities she could be flying to in the country. One is named the same as the country – that
 -- would be too obvious. We're following our gut on this one; find out what other city in that country she might
 --  be flying to.
 
SELECT 
    cities.name AS city,
    countries.name AS country, 
    countries.capital,
    language, 
    isofficial, 
    percentage 
FROM countries 
LEFT JOIN countrylanguages ON (countries.code=countrylanguages.countrycode) 
LEFT JOIN cities ON (cities.countrycode=countries.code) 
WHERE countries.name = 'San Marino' 
ORDER BY percentage DESC;

RESULTS:
    city    |  country   | language | isofficial | percentage 
------------+------------+----------+------------+------------
 Serravalle | San Marino | Italian  | t          |        100
 San Marino | San Marino | Italian  | t          |        100

ANSWER:
San Marino

-- Clue #5: Oh no, she pulled a switch – there are two cities with very similar names, but in totally different
-- parts of the globe! She's headed to South America as we speak; go find a city whose name is like the one we were
-- headed to, but doesn't end the same. Find out the city, and do another search for what country it's in. Hurry!
SELECT DISTINCT
    cities.name AS city,
    countries.name AS country,
    region 
FROM countries 
LEFT JOIN countrylanguages ON (countries.code=countrylanguages.countrycode) 
LEFT JOIN cities ON (cities.countrycode=countries.code) 
WHERE cities.name LIKE 'Serr%'
    AND  countries.region = 'South America';

RESULTS:
 city  | country |    region     
-------+---------+---------------
 Serra | Brazil  | South America

 ANSWER: Serra, Brazil

-- Clue #6: We're close! Our South American agent says she just got a taxi at the airport, and is headed towards
 -- the capital! Look up the country's capital, and get there pronto! Send us the name of where you're headed and we'll
 -- follow right behind you!
SELECT
    cities.name AS city,
    countries.name AS country,
    capital 
FROM countries 
LEFT JOIN cities ON (cities.id = countries.capital) 
WHERE countries.name = 'Brazil';

RESULTS: 
   city   | country | capital 
----------+---------+---------
 Bras�lia | Brazil  |     211

-- Clue #7: She knows we're on to her – her taxi dropped her off at the international airport, and she beat us to
 -- the boarding gates. We have one chance to catch her, we just have to know where she's heading and beat her to the
 -- landing dock.
-- Lucky for us, she's getting cocky. She left us a note, and I'm sure she thinks she's very clever, but
-- if we can crack it, we can finally put her where she belongs – behind bars.

-- Our play date of late has been unusually fun –
-- As an agent, I'll say, you've been a joy to outrun.
-- And while the food here is great, and the people – so nice!
-- I need a little more sunshine with my slice of life.
-- So I'm off to add one to the population I find
-- In a city of ninety-one thousand and now, eighty five.


-- We're counting on you, gumshoe. Find out where she's headed, send us the info, and we'll be sure to meet her at the gates with bells on.



-- She's in ____________________________!
SELECT 
    cities.name AS city,
    countries.name AS country,
    region,
    cities.population
FROM countries 
LEFT JOIN cities ON (cities.countrycode = countries.code) 
WHERE cities.population > 91080 AND cities.population < 91090
ORDER BY population ASC;

RESULTS:
      city     |    country    |    region     | population 
--------------+---------------+---------------+------------
 Idlib        | Syria         | Middle East   |      91081
 Santa Monica | United States | North America |      91084

 ANSWER: Santa Monica