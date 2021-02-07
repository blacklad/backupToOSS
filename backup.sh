#!/bin/bash

## 备份配置信息 ##

# 备份名称，用于标记
BACKUP_NAME="oss"
# 需要备份的目录，可为空，多个请空格分隔
BACKUP_SRC=""
# Mysql 主机地址
MYSQL_SERVER="127.0.0.1"
# Mysql 主机端口
MYSQL_PORT="3306"
# Mysql 用户名
MYSQL_USER="root"
# Mysql 密码
MYSQL_PASS="root"
# Mysql 备份数据库，多个请空格分隔
MYSQL_DBS="datebase_name"
# 备份文件临时存放目录，一般不需要更改
BACKUP_DIR="/tmp/backup-to-oss"

## 备份配置信息 End ##

## 阿里云 OSS 配置信息 ##

# 存放空间
OSS_BUCKET=""
# ACCESS_KEY
OSS_ACCESS_KEY=""
# SECRET_KEY
OSS_SECRET_KEY=""
# Endpoint 示例：https://oss-cn-shenzhen.aliyuncs.com
OSS_ENDPOINT=""
# OSS存放目录
OSS_DIR="mysql"

## 阿里云 OSS 配置信息 End ##



## Start ##
NOW=$(date +"%Y%m%d%H%M%S")  # 精确到秒，同一秒内上传的文件会被覆盖

mkdir -p $BACKUP_DIR

# 备份Mysql
echo "start dump mysql"
for db_name in $MYSQL_DBS
do
    mysqldump -u $MYSQL_USER -h $MYSQL_SERVER -P $MYSQL_PORT -p$MYSQL_PASS $db_name > "$BACKUP_DIR/$BACKUP_NAME-$db_name.sql"
done
echo "dump ok"

# 打包
echo "start tar"
BACKUP_FILENAME="$BACKUP_NAME-backup-$NOW.zip"
zip -q -r $BACKUP_DIR/$BACKUP_FILENAME $BACKUP_DIR/*.sql $BACKUP_SRC
echo "tar ok"

# 上传
echo "start upload"
python3.6 $(dirname $0)/upload.py -a $OSS_ACCESS_KEY -s $OSS_SECRET_KEY -b $OSS_BUCKET -e $OSS_ENDPOINT -f $BACKUP_DIR/$BACKUP_FILENAME -p $OSS_DIR
echo "upload ok"

# 清理备份文件
rm -rf $BACKUP_DIR
echo "backup clean done"
