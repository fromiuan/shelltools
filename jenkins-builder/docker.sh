#!/bin/bash
source /etc/init.d/functions

#1.  must be used image java_env:1.0
#2.  this command will NOT push image to registry

# container variables
build_dir="/data/server/fire-callback-srv/"
# must same as docker-compose.yml  ---> image: ${docker_repository}/${stack_name}_${service_name}:0.01
docker_repository="registry.cn-shanghai.aliyuncs.com/ixindui"
stack_name="xd"
service_name="fire-callback-srv"
package_name="${service_name}.jar"
container_name=${service_name}

# initialization variables(firewall security)
# source_ip="172.19.239.0/20"
# clear variables(clear remote containers and images)
#remote_ips=("192.168.1.1")

# Information and state output
message_result() {
  if [ $? -eq 0 ];then
    action "$*" "/bin/true"
  else
    action "$*" "/bin/false"
  fi
}

# auto computer version number,images version must format 0.01
auto_version() {
  cd ${build_dir}
  app_version_old=`grep "image:" docker-compose.yml | grep "${service_name}" | gawk -F ':' '{print $NF}'`
  echo "Current version ${app_version_old} before change"
  app_version_new=$(printf "%.2f" `echo "scale=2;${app_version_old}+0.01" | bc`)
  app_version_del=$(printf "%.2f" `echo "scale=2;${app_version_old}-0.01" | bc`)
  docker_image_name="${container_name}:${app_version_new}"
  sed -i "/image:/s/${service_name}:${app_version_old}/${service_name}:${app_version_new}/g" docker-compose.yml
}

# install docker and bc
docker_install() {
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  yum install -y bc &> /dev/null
  message_result "install bc"
}

# initialization docker config
docker_initialization() {
  sed -i '/ExecStart/s# -H fd://##g' /usr/lib/systemd/system/docker.service
  grep "ExecStart" /usr/lib/systemd/system/docker.service
  [ -e /etc/docker ] || mkdir /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": ["https://xr7j8cxs.mirror.aliyuncs.com"],
  "insecure-registries": ["registry.cn-shanghai.aliyuncs.com"],
  "hosts": [
         "tcp://0.0.0.0:2375",
         "fd://"
         ]
}
EOF


  systemctl enable docker &> /dev/null
  message_result "systemctl enable docker"
  systemctl start docker &> /dev/null
  message_result "systemctl start docker"
}

# before build ,you must run auto_version
docker_build() {
  cd ${build_dir}
  docker build -t ${docker_image_name} . &> /dev/null
  message_result "build image ${docker_image_name}" || exit 1
#  if [ ${docker_repository} != "gemq" ];then
#    docker push ${docker_image_name} &> /dev/null
#    message_result "push image ${docker_image_name}" || exit 1
#  fi
  cp ${package_name} ${package_name}_${app_version_new} &> /dev/null
  message_result "rename ${package_name}"
  if [ -f ${build_dir}${package_name}_${app_version_del} ];then
    rm -f ${package_name}_${app_version_del}
    docker rmi -f ${container_name}:${app_version_del}
    message_result "delete ${package_name}_${app_version_del}"
  fi
}

# before execute this function ,you must build image first:docker_build()
docker_arrange() {
  cd ${build_dir}
  docker stop ${container_name}
  docker rm ${container_name}
  docker run --name ${container_name} -p 18015:18015 -v /data/server/static-file/:/data/server/static-file/ -v /data/server/fire-callback-srv/logs:/logs -d ${docker_image_name}
 # docker stack deploy -c docker-compose.yml ${stack_name} --with-registry-auth
  message_result "docker run ${docker_image_name}"
}

docker_auto() {
  while :;do
    if [ -f ${build_dir}${package_name} ];then
      echo "-------------- $(date '+%F %T') --------------"
      auto_version
      docker_build
      docker_arrange
    fi
    sleep 30
  done
}

docker_manual() {
  if [ -f ${build_dir}${package_name} ];then
    echo "-------------- $(date '+%F %T') --------------"
    auto_version
    docker_build
    docker_arrange
  fi
}

docker_clear() {
  # clear service
  docker service rm ${stack_name}_${service_name} &> /dev/null
  message_result "service rm ${stack_name}_${service_name}"
  sleep 10
  # clear work node
  for work_ip in "${remote_ips[@]}";do
    local docker_cmd="docker -H tcp://${work_ip}:2375"
    for c in `${docker_cmd} ps -a | grep ${stack_name}_${service_name} | gawk '{print $1}'`;do
      ${docker_cmd} rm $c
    done
    for i in `${docker_cmd} images | grep ${stack_name}_${service_name} | gawk '{print $3}'`;do
      ${docker_cmd} rmi -f $i
    done
  done
  # clear local manager node
  for c in `docker ps -a | grep ${stack_name}_${service_name} | gawk '{print $1}'`;do
    docker rm $c
  done
  for i in `docker images | grep ${stack_name}_${service_name} | gawk '{print $3}'`;do
    docker rmi -f $i
  done
}

main() {
  case $1 in
    "init" )
    docker_install
    docker_initialization
    ;;
    "auto" ) docker_auto;;
    "manual" ) docker_manual;;
    "clear" ) docker_clear;;
    "deploy" ) docker_arrange;;
    * ) printf "Usage:$0 init | auto | manual | clear \n"
    exit 1
    ;;
  esac
}

main $1

