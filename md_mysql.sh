#! /bin/sh
HOSTNAME=$1
PORT=$2
USERNAME=$3
PASSWORD=$4
DBNAME=$5

if [[ -z "$1" ]]; then
	echo 'please input command `-help` for help'
	exit 0
fi

if [[ $1 = "-help" ]]; then
	echo 'Useage:'
	echo '	./e.sh 127.0.0.1 3306 username passwor dabase'
	echo 'Arg menue:'
	echo '	$1 is hostname'
	echo '	$2 is port'
	echo '	$3 is username'
	echo '	$4 is password'
	echo '	$5 is dbname'
	exit 0
fi

if [[ $# != 5 ]]; then
	echo 'please input 4 arg'
fi

# definition filename
fileName=${DBNAME}".md"


tableSchema="select CONCAT(table_name,',',IF(LENGTH(table_comment) = 0,'-',table_comment)) from information_schema.tables where table_schema=\"${DBNAME}\""
tableNameList=$(mysql -h${HOSTNAME} -P${PORT} -u${USERNAME} -p${PASSWORD} -e "${tableSchema}")

# mkdir file
echo -e "# "${DBNAME}"\n">${fileName}

i=0
y=0
for table in ${tableNameList}; do
	if [[ ${i} -gt 2 ]]; then
		# split array
		OLD_IFS="$IFS" 
		IFS="," 
		arr=(${table})
		IFS="$OLD_IFS"
		
		echo -e "## ${arr[0]}">>${fileName}
		if [[ ${arr[1]} != "-" ]]; then
			echo -e "${arr[1]}">>${fileName}
		fi
		if [[ ${y} -ne 0 ]]; then
			struct="SELECT 
			REPLACE(COLUMN_NAME,' ','') 字段,
			REPLACE(COLUMN_TYPE,' ','') 类型,
			IS_NULLABLE 是否为空,
			IF (LENGTH(COLUMN_DEFAULT) = 0 || COLUMN_DEFAULT IS NULL,'--',COLUMN_DEFAULT) 默认值,
			IF (LENGTH(COLUMN_COMMENT) = 0,'--',REPLACE(COLUMN_COMMENT,' ','')) 说明
			FROM INFORMATION_SCHEMA. COLUMNS
			WHERE table_schema =\"${DBNAME}\" 
			AND table_name  = \"${arr[0]}\""
			structInfo=$(mysql -h${HOSTNAME} -P${PORT} -u${USERNAME} -p${PASSWORD} -e "${struct}")
			lenght=0
			line="|"
			for val in ${structInfo}; do
				if [ $((lenght % 5)) -eq 0 -a $lenght -ne 0 ]; then
					if [[ ${lenght} -eq 10 ]]; then
						echo -e '|-------|-------|-------|-------|-------|'>>${fileName}
					fi
					echo -e "${line}">>${fileName}
					line="|${val}|"
				else
					line=${line}"${val}|"
				fi
				((++lenght))
			done
			echo -e "\n">>${fileName}
		fi
		((++y))
	fi
	((++i))
done