#!/bin/bash
/opt/wisecloud/covid/covid_web/nginx/sbin/nginx -c /opt/wisecloud/covid/covid_web/nginx/conf/nginx.conf -p /opt/wisecloud/covid/covid_web/nginx/
ps aux | grep /opt/wisecloud/covid/covid_web/nginx/sbin/nginx
status_covid_web
exit 0