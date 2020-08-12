names = LOAD 'hdfs:/user/maria_dev/pigtest/Master.csv' using PigStorage(',');
real = FILTER names BY $17>0;
height_data = FOREACH real GENERATE $0 AS id, $17 AS height, $13 AS first_name, $14 AS last_name;
group_by_height = GROUP height_data BY height;
count_data = FOREACH group_by_height GENERATE group, COUNT(height_data.height) AS times;
unique = FILTER count_data BY times ==1;
get_name = JOIN unique BY $0, height_data BY height;
first_last_name = FOREACH get_name GENERATE $4,$5;
DUMP first_last_name;