FROM centos:centos6
MAINTAINER naecl <docker@naecl.com>
RUN yum update -y && yum install httpd -y
EXPOSE 80
CMD ["/usr/sbin/httpd","-X"]
