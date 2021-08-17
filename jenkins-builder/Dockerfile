FROM java_env:1.1

MAINTAINER sam

COPY srv.jar /app/srv.jar
COPY bootstrap.yml /app/

RUN localedef -c -f UTF-8 -i zh_CN zh_CN.utf8
#RUN export LANG=zh_CN.UTF-8
#RUN echo "export LANG=zh_CN.UTF-8" >> /etc/locale.conf
#ENV LANG zh_CN.UTF-8
ENV LC_ALL zh_CN.UTF-8

EXPOSE 18013

ENTRYPOINT ["java","-jar","/app/srv.jar","--spring.config.location=/app/bootstrap.yml"]
