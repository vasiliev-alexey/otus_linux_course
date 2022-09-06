#!/bin/bash
export LC_ALL=en_US.UTF-8 # уровняем локаль

MAIL_ADDR=admins_team@local
ACC_LOG=./logs/access.log
ERR_LOG=./logs/error.log

# даты для парсинга с разницей в 1 час - полагам что запус будт в 00 по минутам
DATE_HOUR_AGO="$(date --date="1 hour ago" +"%d/%b/%Y:%H")"
DATE_HOUR_AGO_ERR="$(date --date="1 hour ago" +"%Y/%m/%d %H")"
DATE=$(date +"%d/%b/%Y:%H")

TOP_N=10
NO_DATA_MESSAGE='No Data'
LOCKFILE=/var/run/monitor/monitor_lock.pid

ARTICLE_BREAK=$(printf '~%.0s' {1..80})



if [ -e $LOCKFILE ]; then
    echo "$DATE_LOG --> Script is running"
    exit 1
else

    echo "$$" >$LOCKFILE
    trap 'rm $LOCKFILE' EXIT
    sendMail() {
        local mailBody
        mailBody=$(</dev/stdin)
        echo "*** fake post server ***"
        echo "$mailBody"
    }

    genBody() {
        (
            cat - <<BODY
Subject: Hourly report ws-server
From: monitoring@local
To: $MAIL_ADDR      
Web server report:  
Logs scanned from $DATE_HOUR_AGO:00 to $DATE:00. 
$ARTICLE_BREAK      
Requests top $TOP_N from IP addresses:      
${IPS[@]}      
$ARTICLE_BREAK      

Requests top $TOP_N URL:      
${REQS[@]}      
$ARTICLE_BREAK   

Requests top $TOP_N Statuses:  
${STAT_CODES[@]}  
$ARTICLE_BREAK  

---- Top $TOP_N Errors: ----
${ERRORS[@]}
$ARTICLE_BREAK

BODY
        )
    }

    IPS=$(grep -s "$DATE_HOUR_AGO" $ACC_LOG | awk '{print $1}' | sort | uniq -c | sort -rn | head -n $TOP_N)
    REQS=$(grep -s "$DATE_HOUR_AGO" $ACC_LOG | awk '{print $7}' | sort | uniq -c | sort -rn | head -n $TOP_N)
    STAT_CODES=$(grep -s "$DATE_HOUR_AGO" $ACC_LOG | awk '{print $9}' | grep -Eo '[0-9]{3}' | sort | uniq -c | sort -rn | head -n $TOP_N)
    ERRORS=$(grep -s "$DATE_HOUR_AGO_ERR" $ERR_LOG | head -n $TOP_N | cut -c 1-80)

    if [ -n "$ERRORS" ]; then
        ERRORS+=$NO_DATA_MESSAGE
    fi

    if [ -n "$REQS" ]; then
        REQS+=$NO_DATA_MESSAGE
    fi

    if [ -n "$STAT_CODES" ]; then
        STAT_CODES+=$NO_DATA_MESSAGE
    fi

    genBody | sendMail

fi
