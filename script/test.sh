#!/bin/bash 

count=5
threads_num=2000
time=10
result_filename="a.txt"
echo "Number of planned processes: ""$count"

# running 2000*5 threads
for((i=0;i<count;i++))
do
{
    ./wrk -t$threads_num -c$threads_num -d"$time"s http://127.0.0.1:8123 > "$i"".txt" 
    # ./wrk -t$threads_num -c$threads_num -d"$time"s https://m.pythontab.com/article/1324 > "$i"".txt" 

} &
done

procs_count=$(pgrep wrk | wc -l)

echo "Actual number of processes: ""$procs_count"

# check number of running processes
if [ $procs_count = $count ]
then
    echo "Correct number of processes\n"
else
    echo "Incorrect number of processes\n"
    wait 
    exit 1
fi


pgrep_result=$(pgrep wrk)
# echo $pgrep_result

# split string by line break
OLD_IFS="$IFS"
IFS=" "
pids=($pgrep_result)
IFS="$OLD_IFS"
# echo $pids

# # check number of running threads
for pid in ${pids[@]}
do
    pid_thread_num=$(($(ps -M $pid | wc -l)-2))

    if [ $pid_thread_num = $threads_num ]
    then
        echo "pid "$pid": Correct number of threads ""$pid_thread_num"
    else
        echo "pid "$pid": Incorrect number of threads ""$pid_thread_num"
    fi
done

echo "" # line break

wait

for((i=0;i<count;i++))
do
{
    cat "$i"".txt" >> "$result_filename"
    echo "" >> "$result_filename"
}
done

exit 0