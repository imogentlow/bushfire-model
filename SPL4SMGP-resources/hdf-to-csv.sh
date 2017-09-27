#!/bin/bash

# create loop over each h5 file
#  make dir named datetime
#   create loop over dataset
#    parse each and write to csv

while read h5
do

    DATETIME=`echo $h5 | cut -d "_" -f5`
    mkdir "../csv/${DATETIME}"
    
    while read dataset
    do
        h5dump -d "Geophysical_Data/${dataset}[0,0;1,1;1624,3856;1,1;]" -o ../csv/${DATETIME}/${dataset}.csv -w 3857 ../h5/${h5}
    done < <(cat dataset.txt)

    while read metadata
    do
        h5dump -d "${metadata}[0,0;1,1;1624,3856;1,1;]" -o ../csv/${DATETIME}/meta/${metadata}.csv -w 3857 ../h5/${h5}
    done < <(cat metadata.txt)


done < <(ls ../h5/ | grep .h5 | head -n 2) 


