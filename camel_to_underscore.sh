#!/bin/bash
#get current path
curpath=`pwd`
# 定义一个方法
foreachd(){
# 遍历参数1 
        for file in $1/*
            do
# 如果是目录就打印处理，然后继续遍历，递归调用
		echo "Handle the file  --- "$file
                if [ -d $file ]
                then
                    echo $file"是目录" 
                    foreachd $file
                elif [ -f $file ]
                then
                    #echo $file
		    path=`echo ${file%/*}`
	        #get file name
		    fileName=`echo ${file##*/}`
		    #echo $path
		    #echo $fileName
		   #genarate the new file name
		    tname=`echo ${fileName,}`
                    dname=`echo $tname | sed 's/[A-Z]/_\l&/g'`
                    filetype=`echo ${dname##*\.}`
		    if [ "$filetype" = "go" ]
		    then
		    	echo -e "\033[34m Rename $filetype file \033[0m"
		   	#rename all files
			
		    	printinfo=`echo $curpath"/"${file} $curpath"/"${path}"/"$dname`
		    	echo -e "\033[47;34m $printinfo  \033[0m"
		    	mv $curpath"/"${file} $curpath"/"${path}"/"$dname
			
		    else
			echo "ignore the file : "$filetype
		    fi 
                fi
            done
}
# 执行，如果有参数就遍历指定的目录，否则遍历当前目录

if [[ "x$1" == 'x' ]]
then
    echo "	Useage:"
    echo "	  ./cn.sh gitpath"
    echo "	eg:"
    echo "	  ./cn.sh https://github.com/SaturnsVoid/GoBot2.git"
else
    git clone $1
     tpath=${1##*/}
	$echo $tpath
	gitpath=`echo ${tpath%\.*}` 
	$echo $gitpath
    foreachd "$gitpath"
fi 
