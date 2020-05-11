#!/bin/bash

#判断命令的参数是否为3个
if [ $# -ne "3" ];then
    echo "-[s|n] \"-s: After install, startup server.    -n: After install, not startup server.\""
	echo "-f \"   param.properties filepath.\""
	echo "demo: sh setup.sh -s -f `pwd`/param.properties"
    exit 1
fi

FIRST_PARAM=$1
if [ "${FIRST_PARAM}d" == "d" ]; then
    echo "parameter must be FIRST_PARAM value -n or -s!"
    echo "-n Second parameter is not start after install.\""
    echo "-s Second parameter is to start after install.\""
    echo "-help First parameter is to show the parameters.\""
    exit 1;
fi;

SECOND_PARAM=$2
if [ "${SECOND_PARAM}d" == "d" ]; then
	SECOND_PARAM="-f"
	echo "There is no SECOND_PARAM,so git it $SECOND_PARAM"
fi

#params文件绝对路径
PARAMSPATH=$3
if [ ! -f ${PARAMSPATH}  ]; then
    echo "param.properties is not exists!   ${PARAMSPATH}"
    exit 1
fi

#输入参数说明和判断
if [ "$FIRST_PARAM" != "-n" ] && [ "$FIRST_PARAM" != "-s" ] && [ "$FIRST_PARAM" != "-help" ]; then
    echo "First parameter must be -n or -s or -help"
    exit 1
fi

if [ "$SECOND_PARAM" != "-f" ]; then
    echo "Second parameter must be -f"
    exit 1
fi



#安装方法
setup_install()
{		
    #SETUP_URL，如果为根目录和空则停止执行后续的函数
    SETUP_URL=`cat $PARAMSPATH | grep "SETUP_URL" | awk -F '=' '{print $2}'|awk -F ' ' '{print $1}'`
    if [ "${SETUP_URL}" == "/" ] || [ -z ${SETUP_URL} ]; then
       	echo "SETUP_URL is / "
        exit 1
    fi

    echo "#判断垃圾目录是否存在，存在则删除再新建，不存在新建垃圾目录"

    if [ -d ${SETUP_URL}/garbage ]; then
        echo "GARBAGE_URL is exists!"
        rm -rf ${SETUP_URL}/garbage
        mkdir -vp ${SETUP_URL}/garbage
    else
        echo "GARBAGE_URL is not exists!"
        mkdir -vp ${SETUP_URL}/garbage
    fi

    echo "${SETUP_URL}"

    echo "#判断安装目录是否存在"
    if [ -d $SETUP_URL ]; then
        echo "SETUP_URL is exists!"

        #备份
        echo "#判断安装目录下的data备份目录是否存在"
        if [ -d $SETUP_URL/data ]; then
	    echo "SETUP_URL/data is exists!"
            mv $SETUP_URL/data/* $SETUP_URL/garbage	
        else
            echo "SETUP_URL/data is not exists!"
	    mkdir -vp $SETUP_URL/data
        fi

        echo "#备份数据"
        cp $SETUP_URL/param.properties $SETUP_URL/data
        \cp -r $SETUP_URL/script $SETUP_URL/data
        \cp -r $SETUP_URL/software $SETUP_URL/data
        cp $SETUP_URL/setup.sh $SETUP_URL/data
        cp $SETUP_URL/rollback.sh $SETUP_URL/data
        cp $SETUP_URL/version $SETUP_URL/data
        #nginx只能cp不能mv
        \cp -r $SETUP_URL/nginx $SETUP_URL/data
	
        #删除$SETUP_URL目录下出了data的所有文件和文件夹
	mv $SETUP_URL/* $SETUP_URL

    else
	echo "SETUP_URL is not exists!"
	mkdir -vp $SETUP_URL
    fi

    echo "#拷贝文件到安装目录"
    cp param.properties $SETUP_URL
    cp -r script $SETUP_URL
    cp -r software $SETUP_URL
    cp setup.sh $SETUP_URL
    cp rollback.sh $SETUP_URL
    cp version $SETUP_URL
	
    echo "#进入安装目录"
    cd $SETUP_URL
    chmod 777 -R *

    echo "#读取配置文件信息"
    COVID_WEB_PORT=`cat $PARAMSPATH | grep "COVID_WEB_PORT" | awk -F '=' '{print $2}'|awk -F ' ' '{print $1}'`
    COVID_SERVER_IP=`cat $PARAMSPATH | grep "COVID_SERVER_IP" | awk -F '=' '{print $2}'|awk -F ' ' '{print $1}'`
    COVID_SERVER_PORT=`cat $PARAMSPATH | grep "COVID_SERVER_PORT" | awk -F '=' '{print $2}'|awk -F ' ' '{print $1}'`
    WEB_URL=`cat $PARAMSPATH | grep "WEB_URL" | awk -F '=' '{print $2}'|awk -F ' ' '{print $1}'`
    WEB_URL=${WEB_URL////\\/}
    echo "$COVID_WEB_PORT"
    echo "$COVID_SERVER_IP"
    echo "$COVID_SERVER_PORT"
    echo "$WEB_URL"

    LOCATION="location ^~/api/covid/ {\\n                 proxy_redirect        off;\\n                 proxy_set_header       Host \$host;\\n                 proxy_set_header       X-real-ip \$remote_addr;\\n                 proxy_set_header       X-Forwarded-For \$proxy_add_x_forwarded_for;\\n                 proxy_pass             http://$COVID_SERVER_IP:$COVID_SERVER_PORT;\\n        \}\\n"

    echo "#判断是否已经存在nginx，存在删除再解压，不存直接解压"
    if [ ! -d nginx ]; then
        echo "To decompression nginx"
        tar -zxf software/nginx.tar.gz -C $SETUP_URL
    else
        echo 'To delete and decompression nginx'
        mv nginx* ${SETUP_URL}/garbage
        tar -zxf software/nginx.tar.gz -C $SETUP_URL
    fi

    echo "#进入解压后的nginx/html"
    cd nginx/html
	
    echo "#拷贝程序到nginx/html" 
    cp -r $SETUP_URL/software/dist .
    cp -r $SETUP_URL/version .
    chmod 777 -R *
    echo "#退出nginx/html到安装目录"
    cd ../../

    echo "#配置nginx.conf文件"
    sed -i "s/80/$COVID_WEB_PORT/g" $SETUP_URL/nginx/conf/nginx.conf
    sed -i "s/web/$WEB_URL/g" $SETUP_URL/nginx/conf/nginx.conf
    #sed -i "s/locationempty/$f/g" $SETUP_URL/nginx/conf/nginx.conf
    sed -i "s!locationempty!$LOCATION!g" $SETUP_URL/nginx/conf/nginx.conf
}

#第一个参数-s表示安装后启动程序
if [ "$FIRST_PARAM" == '-s' ]; then
    echo "The first param is：$FIRST_PARAM , to start"
    echo "#拷贝执行脚本到/bin"
    #cp script/* /bin

    yes|cp script/restart_covid_web.sh /bin/restart_covid_web
    chmod 755 /bin/restart_covid_web

    yes|cp script/start_covid_web.sh /bin/start_covid_web
    chmod 755 /bin/start_covid_web

    yes|cp script/status_covid_web.sh /bin/status_covid_web
    chmod 755 /bin/status_covid_web

    yes|cp script/stop_covid_web.sh /bin/stop_covid_web
    chmod 755 /bin/stop_covid_web
	
    echo "#安装前先杀掉程序"
    stop_covid_web

    echo "#进行安装"
    setup_install;

    echo "#启动项目"
    start_covid_web

#第一个参数-n表示安装后不启动程序
elif [ "$FIRST_PARAM" == "-n" ]; then
    echo "The first param is：$FIRST_PARAM , no start"
    echo "#拷贝执行脚本到/bin"
    #cp script/* /bin

    yes|cp script/restart_covid_web.sh /bin/restart_covid_web
    chmod 755 /bin/restart_covid_web

    yes|cp script/start_covid_web.sh /bin/start_covid_web
    chmod 755 /bin/start_covid_web

    yes|cp script/status_covid_web.sh /bin/status_covid_web
    chmod 755 /bin/status_covid_web

    yes|cp script/stop_covid_web.sh /bin/stop_covid_web
    chmod 755 /bin/stop_covid_web

    echo "#安装前先杀掉程序"
    stop_covid_web

    echo "#进行安装"
    setup_install;
	
#第一个参数-help表示参数帮助
elif [ "$FIRST_PARAM" == "-help" ];then
    echo "-n Second parameter is not start after install.\""
    echo "-s Second parameter is to start after install.\""
    echo "-help First parameter is to show the parameters.\""
fi

exit 0;