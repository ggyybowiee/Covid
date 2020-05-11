#!/bin/bash
NGINX_PID=`ps aux | grep /opt/wisecloud/covid/covid_web/nginx/conf/nginx.conf | grep -v "grep" |  awk '{print $2}'`
#echo "$NGINX_PID"
kill -9 -$NGINX_PID
ps aux | grep /opt/wisecloud/covid/covid_web/nginx/sbin/nginx
exit 0
