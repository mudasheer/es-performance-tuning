#!/bin/sh
echo "Stopping existing cluster"
ps -ef | grep 'elasticsearch' | grep -v grep | awk '{print $2}' | xargs kill

echo "Clearing existing data"
rm -rf data_*

masters=$1
for (( i=1; i<=$masters; i++ )); 
do 
    echo "Starting Dedicated Master#$i" 
    eval "./elasticsearch-7.0.0/bin/elasticsearch -d -Ecluster.name=my_cluster -Enode.data=false -Enode.ingest=false -Ecluster.remote.connect=false -Epath.data=../data_master_$i -Enode.name=master_$i" ; 
done


data=$2
for (( i=1; i<=$data; i++ )); 
do 
    echo "Starting Data Node#$i" 
    eval "./elasticsearch-7.0.0/bin/elasticsearch -d -Ecluster.name=my_cluster -Enode.master=false -Enode.ingest=false -Ecluster.remote.connect=false -Epath.data=../data_$i -Enode.name=data_$i" ; 
done

ingest=$3
for (( i=1; i<=$ingest; i++ )); 
do 
    echo "Starting Ingest Node#$i" 
    eval "./elasticsearch-7.0.0/bin/elasticsearch -d -Ecluster.name=my_cluster -Enode.master=false -Enode.data=false -Ecluster.remote.connect=false -Epath.data=../data_ingest_$i -Enode.name=ingest_$i" ; 
done

coordinating=$4
for (( i=1; i<=$coordinating; i++ )); 
do 
    echo "Starting Coordinating Node#$i" 
    eval "./elasticsearch-7.0.0/bin/elasticsearch -d -Ecluster.name=my_cluster -Enode.master=false -Enode.data=false -Enode.ingest=false -Ecluster.remote.connect=false -Epath.data=../data_coordinating_$i -Enode.name=coordinating_$i" ; 
done

#./elasticsearch-7.0.0/bin/elasticsearch -d -Ecluster.name=my_cluster -Enode.data=false -Enode.ingest=false -Ecluster.remote.connect=false -Epath.data=../master_1_data_1 -Enode.name=master_1 