#!/bin/sh

echo "Stopping existing cluster"
ps -ef | grep 'elasticsearch' | grep -v grep | awk '{print $2}' | xargs kill

echo "Clearing existing data"
rm -rf data_*

masters=$1
for (( i=1; i<=$masters; i++ )); 
do 
    echo Starting $'\e[1;32m'Dedicated Master$'\e[0m'  $i
    eval "./elasticsearch-7.0.0/bin/elasticsearch -d -Ecluster.name=my_cluster -Enode.data=false -Enode.ingest=false -Ecluster.remote.connect=false -Epath.data=../data_master_$i -Enode.name=master_$i" ; 
done


data=$2
for (( i=1; i<=$data; i++ )); 
do 
    echo Starting $'\e[1;32m'Data Node$'\e[0m'  $i
    eval "./elasticsearch-7.0.0/bin/elasticsearch -d -Ecluster.name=my_cluster -Enode.master=false -Enode.ingest=false -Ecluster.remote.connect=false -Epath.data=../data_$i -Enode.name=data_$i" ; 
done

ingest=$3
for (( i=1; i<=$ingest; i++ )); 
do 
    echo Starting $'\e[1;32m'Ingest Node$'\e[0m'  $i
    eval "./elasticsearch-7.0.0/bin/elasticsearch -d -Ecluster.name=my_cluster -Enode.master=false -Enode.data=false -Ecluster.remote.connect=false -Epath.data=../data_ingest_$i -Enode.name=ingest_$i" ; 
done

coordinating=$4
for (( i=1; i<=$coordinating; i++ )); 
do 
    echo Starting $'\e[1;32m'Coordinating Node$'\e[0m'  $i
    eval "./elasticsearch-7.0.0/bin/elasticsearch -d -Ecluster.name=my_cluster -Enode.master=false -Enode.data=false -Enode.ingest=false -Ecluster.remote.connect=false -Epath.data=../data_coordinating_$i -Enode.name=coordinating_$i" ; 
done

echo $'\e[1;34m'Waiting for Elastic Search to start$'\e[0m'
until $(curl --output /dev/null --silent --head --fail localhost:9200); do
    printf $'\e[1;34m'.$'\e[0m'
    sleep 5
done
printf "\n"

for n in $(ls sample/mappings/ | awk '{print $1}' | cut -f 1 -d '.')
do
    echo Uploading Mapping for $'\e[1;34m'$n $'\e[0m'
    eval "curl -H 'Content-Type: application/json' -XPUT 'localhost:9200/${n}?pretty' --data-binary @sample/mappings/${n}.json"
done

for n in $(ls sample/data/ | awk '{print $1}' | cut -f 1 -d '.')
do
    echo Uploading Data for $'\e[1;34m'$n $'\e[0m'
    eval "curl -H 'Content-Type: application/x-ndjson' -XPOST 'localhost:9200/${n}/_doc/_bulk?pretty' --data-binary @sample/data/${n}.json"
done