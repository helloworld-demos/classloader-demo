#!/bin/bash
set -e

cleanUpDocker(){
  docker rm -f demo-glassfish-w-webappclassloader || true
  docker rmi -f hw-demos/glassfish-w-webappclassloader || true

  docker rm -f demo-glassfish-wo-webappclassloader || true
  docker rmi -f hw-demos/glassfish-wo-webappclassloader || true

  docker rm -f demo-tomcat-classloader || true
  docker rmi -f hw-demos/tomcat-classloader || true
}

cleanUpDocker

# glassfish-w-webAppClassLoader
(cd .. && gradle -Penv=glassfish-w-webAppClassLoader clean war -x test && cp ./build/libs/classloader-demo-*.war demo/glassfish/classloader-demo.war)

docker build -t hw-demos/glassfish-w-webappclassloader glassfish/.

# glassfish-wo-webAppClassLoader:
(cd .. && gradle -Penv=glassfish-wo-webAppClassLoader clean war -x test && cp ./build/libs/classloader-demo-*.war demo/glassfish/classloader-demo.war)

docker build -t hw-demos/glassfish-wo-webappclassloader glassfish/.

# tomcat
(cd .. && gradle -Penv=tomcat clean war -x test && cp ./build/libs/classloader-demo-*.war demo/tomcat/classloader-demo.war)

docker build -t hw-demos/tomcat-classloader tomcat/.

# cleanup
rm */*.war

# run
docker-compose create
docker-compose start

sleep 45s

echo  > result.log
echo "===============================================" >> result.log
echo "curl -X GET localhost:9001/classloader-demo/demo" >> result.log
echo "===============================================" >> result.log
curl -X GET localhost:9001/classloader-demo/demo >> result.log
echo >> result.log

echo "===============================================" >> result.log
echo "curl -X GET localhost:9002/classloader-demo/demo" >> result.log
echo "===============================================" >> result.log
curl -X GET localhost:9002/classloader-demo/demo >> result.log
echo >> result.log

echo "===============================================" >> result.log
echo "curl -X GET localhost:9003/classloader-demo/demo" >> result.log
echo "===============================================" >> result.log
curl -X GET localhost:9003/classloader-demo/demo >> result.log
echo >> result.log

# stop
docker-compose stop

cleanUpDocker
