#!/bin/sh

curl -H 'Content-Type: application/json' -XDELETE 'localhost:9200/*' 

for n in $(ls sample/mappings/ | awk '{print $1}' | cut -f 1 -d '.')
do
    echo Creating Mapping for $'\e[1;34m'$n $'\e[0m'
    eval "curl -H 'Content-Type: application/json' -XPUT 'localhost:9200/${n}?pretty' --data-binary @sample/mappings/${n}.json"
done

# Bulk
# for n in $(ls sample/data/ | awk '{print $1}' | cut -f 1 -d '.')
# do
#     echo Indexing $'\e[1;34m'$n $'\e[0m'
#     start=`date +%s`
#     eval "curl -H 'Content-Type: application/x-ndjson' -XPOST 'localhost:9200/${n}/_doc/_bulk?pretty' --data-binary @sample/data/${n}.json"
#     end=`date +%s`
#     echo Indexed $'\e[1;34m'$n $'\e[0m' in $((end-start)) seconds
# done

# Individual Indexing 
# for n in $(ls sample/data/ | awk '{print $1}' | cut -f 1 -d '.')
# do
#     echo Indexing $'\e[1;34m'$n $'\e[0m'
#     start=`date +%s`
#     input="sample/data/${n}.json"
#     while IFS= read -r var
#     do
#     #echo Line "$var"
#     eval "curl -H 'Content-Type: application/json' -XPOST 'localhost:9200/${n}/_doc?pretty' -d'$var'"
#     done < "$input"
#     #eval "curl -H 'Content-Type: application/x-ndjson' -XPOST 'localhost:9200/${n}/_doc/_bulk?pretty' --data-binary @sample/data/${n}.json"
#     end=`date +%s`
#     echo Indexed $'\e[1;34m'$n $'\e[0m' in $((end-start)) seconds
# done

# Individual Indexing with Id
for n in $(ls sample/data/ | awk '{print $1}' | cut -f 1 -d '.')
do
    echo Indexing $'\e[1;34m'$n $'\e[0m'
    start=`date +%s`
    input="sample/data/${n}.json"
    id=0
    while IFS= read -r var
    do
    id=$((id+1))
    
    #echo Line "$var"
    eval "curl -H 'Content-Type: application/json' -XPUT 'localhost:9200/${n}/_doc/$id?pretty' -d'$var'"
    done < "$input"
    #eval "curl -H 'Content-Type: application/x-ndjson' -XPOST 'localhost:9200/${n}/_doc/_bulk?pretty' --data-binary @sample/data/${n}.json"
    end=`date +%s`
    echo Indexed $'\e[1;34m'$n $'\e[0m' in $((end-start)) seconds
done