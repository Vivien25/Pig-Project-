names = LOAD 'hdfs:/user/maria_dev/pigtest/Master.csv' using PigStorage(',');
filter1 = FILTER names BY $5 != '';
birth_data = FOREACH filter1 GENERATE $0 AS id, $5 AS b_state, $6 AS b_city;
filter2 = FILTER birth_data BY STARTSWITH(b_city, 'A') or STARTSWITH(b_city, 'E') or STARTSWITH(b_city, 'I') 
or STARTSWITH(b_city, 'O') or STARTSWITH(b_city, 'U');
batters = LOAD 'hdfs:/user/maria_dev/pigtest/Batting.csv' using PigStorage(',');
real = FILTER batters BY $1>0;
hits = FOREACH real GENERATE $0 AS id, $8 AS B2, $9 AS B3;
hits_sum = FOREACH hits GENERATE id,SUM(TOBAG(B2,B3));
joined_f = JOIN filter2 BY $0, hits_sum BY id;
nicer = FOREACH joined_f GENERATE $1 AS state, $2 AS city, $4 AS hits;
grouped_by_state_city = GROUP nicer BY (state,city);
state_city_hits = FOREACH grouped_by_state_city GENERATE group,SUM(nicer.hits) AS hits_sum;
ranked = rank state_city_hits BY hits_sum DESC DENSE;
TOP5 = FILTER ranked BY $0<6;
out_of_tuple = FOREACH TOP5 GENERATE $0, FLATTEN($1);
get_city_state = FOREACH out_of_tuple GENERATE CONCAT($2, '/',$1);
DUMP get_city_state;
