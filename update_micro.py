#!/usr/bin/python
# -*- coding: UTF-8 -*-

#公共类：all_filename(UpdateRootDir)遍历待更新文件，stitching_directory(filename)拼接项目目录


import os
import datetime
import sys
import time
import re
import codecs
from shutil import copyfile
from io import open



NowTime=datetime.datetime.now().strftime('%Y%m%d%H%M%S')

def all_filename(UpdateRootDir):#遍历待更新文件
    result = []
    for file_name_list in os.listdir(UpdateRootDir):
        result.append(file_name_list)
    return result

def stitching_directory(filename):  #拼接项目目录
        Dir_list=filename.split("-",4)
        if len(Dir_list)==4:
            Dir=""+MicroRootDir+"/"+Dir_list[0]+"-"+Dir_list[1]+"/"+Dir_list[2]+"-"+Dir_list[3]+""
        else:
            Dir=""+MicroRootDir+"/"+Dir_list[0]+"-"+Dir_list[1]+"/"+Dir_list[2]+""   #拼接项目目录
        return Dir

def bak_file(MicroRootDir,list_filename): #备份原项目目录文件（保留最近三个版本文件）
    print("------进行备份操作中------")
    for filename in list_filename:
        Dir=stitching_directory(filename)
        try:
            #os.chdir(MicroRootDir+'/'+filename)  #切换工作目录
            os.chdir(Dir)
            try:
                os.rename(filename+'_bak2',filename+'_bak3')
            except Exception as e:
                #print(e)
                a=0
            try:
                os.remove(filename+'_bak3')
            except Exception as e:
                #print(e)
                a=0
            try:
                os.rename(filename+'_bak1',filename+'_bak2')
            except Exception as e:
                #print(e)
                a=0
            try:
                os.rename(filename,filename+'_bak1')
            except Exception as e:
                #print(e)
                a=0
        except Exception as e:
            print(e)
            print(''+filename+' dir fail\r\n')
            print("\033[7;31m------"+filename+"备份操作失败,请检查------\033[1;31;40m")
            print('\033[0m')
            sys.exit(0)
        else:
            print(''+filename+' dir success')
    print("------备份操作完成------\r\n\r\n")
    
def copy_file(UpdateRootDir,MicroRootDir,list_filename):  #复制待更新文件到更新目录
    print("------进行待更新文件复制------")
    for filename in list_filename:
        try:
            Dir=stitching_directory(filename)
            source = (UpdateRootDir+'/'+filename)
            target = (Dir+'/'+filename)    #目的目录加文件名
            copyfile(source,target)
        except Exception as e:
            print(e)
            print(''+filename+' dir fail\r\n')
            print("\033[7;31m------更新文件操作失败,请检查------\033[1;31;40m")
            print('\033[0m')
            sys.exit(0) 
        else:
            print(''+filename+' dir success')
    print("------待更新文件复制完成------\r\n\r\n")

def update_config(MicroRootDir,list_filename): #更新配置文件
    print("------进行更新配置文件------")
    for filename in list_filename:
        version_new=''
        version_old=''
        try:
            Dir=stitching_directory(filename)
            os.chdir(Dir)  #切换工作目录
            with open('Makefile', "r", encoding="utf-8") as f1,open("Makefile.bak", "w", encoding="utf-8") as f2:
                for line in f1:
                    #print(line)
                    version = re.search(r'DOCKER_VERSION=v(.*)', line, re.M|re.I)
                    if version:
                        version_old=version.group(1)
                        pattern = re.compile(r'\d+')
                        version_child = pattern.findall(version.group(1))
                        if int(version_child[2])<99:
                            version_child[2]=int(version_child[2])+1
                        else:
                            if int(version_child[1])<99:
                                version_child[2]=0
                                version_child[1]=int(version_child[1])+1
                            else:
                                version_child[1]=version_child[2]=0
                                version_child[0]=int(version_child[0])+1
                        version_new=''+str(version_child[0])+'.'+str(version_child[1])+'.'+str(version_child[2])+''
                    f2.write(re.sub(version_old,version_new,line))
            #关闭文件
            f1.close()
            f2.close()
            os.remove("Makefile")
            os.rename("Makefile.bak","Makefile")

        except Exception as e:
            print(e)
            print(''+filename+' dir fail\r\n')
            print("\033[7;31m------更新文件操作失败,请检查------\033[1;31;40m")
            print('\033[0m')
            sys.exit(0) 
        else:
            print(''+filename+' dir success Version=v'+version_new+'')

                    
            #re.search('DOCKER_VERSION=', string, flags=0)
    print("------更新配置文件完成------\r\n\r\n")

    
def list_version(MicroRootDir,list_filename):  #输出文件名和版本号到文件并打印
    print("------升级完成的微服务和版本号------")
    print("升级时间 | 升级项目 | 线上版本号")
    for filename in list_filename:
        version_show='0'
        PROJECT_NAME_show = '0'
        try:
            Dir=stitching_directory(filename)
            os.chdir(Dir)  #切换工作目录
            with open('Makefile', "r", encoding="utf-8") as f1:
                for line in f1:
                    #print(line)
                    PROJECT_NAME = re.search(r'PROJECT_NAME=(.*)', line, re.M|re.I)
                    version = re.search(r'DOCKER_VERSION=v(.*)', line, re.M|re.I)
                    if PROJECT_NAME:
                        PROJECT_NAME_show=PROJECT_NAME.group(1)
                    if version:
                        version_show=version.group(1)
            #关闭文件
            f1.close()
        except Exception as e:
            print(e)
            print(''+filename+' dir fail\r\n')
            print("\033[7;31m------打印操作失败,请检查------\033[1;31;40m")
            print('\033[0m')
            sys.exit(0)                     
        else:
            print(''+NowTime+' | '+PROJECT_NAME_show+' | Version=v'+version_show+'')
    print("------微服务和版本号打印完成------\r\n\r\n")

    

def update_cloud(MicroRootDir,list_filename):  #更新到云服务器
    print("------更新到云服务器进行中------")
    for filename in list_filename:
        version_update='0'
        PROJECT_NAME_update = '0'
        try:
            Dir=stitching_directory(filename)
            os.chdir(Dir)  #切换工作目录
            with open('Makefile', "r", encoding="utf-8") as f1:
                for line in f1:
                    PROJECT_NAME = re.search(r'PROJECT_NAME=(.*)', line, re.M|re.I)
                    version = re.search(r'DOCKER_VERSION=v(.*)', line, re.M|re.I)
                    if PROJECT_NAME:
                        PROJECT_NAME_update=PROJECT_NAME.group(1)
                    if version:
                        version_update=version.group(1)
            command1='chmod +x '+PROJECT_NAME_update+''
            command2='make docker'
            command3='docker push registry.cn-shenzhen.aliyuncs.com/xxx/'+PROJECT_NAME_update+':v'+version_update+'' #xxx 代表项目路径
            os.system(""+command1+" && "+command2+" && "+command3+"")

            #关闭文件
            f1.close()
        except Exception as e:
            print(e)
            print(''+filename+' dir fail\r\n')
            print("\033[7;31m------更新到云服务器操作失败,请检查------\033[1;31;40m")
            print('\033[0m')
            sys.exit(0)                     
        else:
            print(''+filename+' dir success')
    print("------更新到云服务器完成------\r\n\r\n")

def delete_UpdateRootDir(UpdateRootDir):
    button = ''
    os.chdir(UpdateRootDir)
    print(""+UpdateRootDir+"目录中文件内容：")
    print("==================================")
    os.system("ls")
    print("==================================")
    print("是否需要删除待更新"+UpdateRootDir+"目录中的文件：键入Y/y删除,任意键保留退出")
    button = raw_input()
    button = str(button)
    try:
        os.chdir(UpdateRootDir)
        command = "rm -rf "+UpdateRootDir+"/*"
        if button=='Y'or button == 'y':
            print("删除目录"+UpdateRootDir+"进行中....")
            os.system(""+command+"")
            print("删除目录"+UpdateRootDir+"完成！")
        else:
            print("目录中文件保留，程序已结束！")
    except Exception as e:
        print(e)


    


    
if __name__ == '__main__':
    
    #UpdateRootDir = "E:/test"   #待更新文件存放路径
    #MicroRootDir = "E:/test1"   #微服务根目录

    UpdateRootDir = "/data/UpdateRootDir"   #待更新文件存放路径
    MicroRootDir = "/data/awt-k8s"   #微服务根目录
    
    list_filename=all_filename(UpdateRootDir)#获取文件名称列表
    bak_file(MicroRootDir,list_filename)#备份文件
    copy_file(UpdateRootDir,MicroRootDir,list_filename)#更新文件
    update_config(MicroRootDir,list_filename) #更新配置文件
    update_cloud(MicroRootDir,list_filename)  #更新到云服务器
    list_version(MicroRootDir,list_filename)  #输出文件名和版本号到文件并打印
    delete_UpdateRootDir(UpdateRootDir)  #更新完成后删除待更新目录的文件
