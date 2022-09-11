#!/bin/bash


get_time(){
sec=$(( $( awk '{ print $14 }' /proc/$i/stat )+$( awk '{ print $15 }' /proc/$i/stat ) / 100 ))
date -u -d @${sec} +"%M:%S"
}


get_pid(){
awk '{ print $1 }' /proc/$i/stat
}

get_tty(){
if [[ $( awk '{print $7}' /proc/$i/stat ) = 0 ]]
then
    echo "?"
else
    ls -l /proc/$i/fd | grep -E 'tty|pts' | cut -d\/ -f3,4 | uniq | head -1
fi
}

get_command(){

CMD=$(tr -d '\0' </proc/$i/cmdline)
if [ -z "$CMD" ]
 then
    awk '/Name/{ print $2 }' /proc/$i/status
 else
        echo "[$( cat /proc/$i/comm )]"
 fi
}

get_stat(){
grep State /proc/$i/status | awk '{ print $2 }'
}

main(){
PID=$*
for i in $PID
do
if [[ -e /proc/$i/stat ]]
then
#echo "$(get_pid)	$(get_tty)	$(get_stat)	$(get_time)	$(get_command)"
echo "$(get_pid)    $(get_tty)  $(get_stat) $(get_time)	$(get_command)"

fi
done
}

PID=$( ls /proc | grep [[:digit:]] | sort -n | xargs )
echo "PID	TTY	STAT	TIME	COMMAND"
main $PID