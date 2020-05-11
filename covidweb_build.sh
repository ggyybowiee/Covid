#!/bin/sh

pwdDir=`pwd`
buildDir=/home/jenkins/workspace/
jobID="Covid_Web"
webdir="Covid_Web"
ver="3.0.4"
curday=$(date +%Y%02m%02d)
buildtime=$(date +"%Y-%02m-%02d %02H:%02M:%02S")
desdir="output"
svnVS=""


packageData()
{
	cd ${buildDir}${jobID}
	
	rm -rf .svn
	
	#产生version文件
	echo "NEName=$webdir" > version
	echo "Version=$ver" >> version
	echo "Provider=小溪流" >> version
	echo "BuildTime=$curday" >> version

	mv dist/ software

	#创建打包输出目录
	if [ ! -d $desdir ]
	then
		mkdir -v $desdir
	else
		rm -rf $desdir/*        
	fi;

	echo "***开始打包！"
	
	#进入output目录
	cd ${desdir}

	#创建包目录
    if [ ! -d ${webdir}_${ver}_${curday} ]
    then
        mkdir -v ${webdir}_${ver}_${curday}
    else
        rm -rf ${webdir}_${ver}_${curday}/*
    fi;
	
	cd ${webdir}_${ver}_${curday}

	#复制需要的所有打包文件到此目录下
	cp ${buildDir}${jobID}/param.properties .
	cp -r ${buildDir}${jobID}/script .
	cp -r ${buildDir}${jobID}/software .
	cp ${buildDir}${jobID}/setup.sh .
	cp ${buildDir}${jobID}/rollback.sh .
	cp ${buildDir}${jobID}/version .

	
	#返回output目录
	cd ../

	#打包命令
	tar -zcf $webdir"_"$ver"_"$curday.tar.gz ${webdir}_${ver}_${curday}
	rm -rf ${webdir}_${ver}_${curday}
	echo "***打包结束！"
	
}

packageData;

exit 0;

