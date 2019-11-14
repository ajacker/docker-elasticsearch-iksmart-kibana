FROM openjdk:12

LABEL maintainer "ajacker <ajacker@foxmail.com>"

ARG ek_version=7.4.2

RUN yum install -q -y wget which xz \ 
&& adduser elasticsearch

USER elasticsearch

WORKDIR /home/elasticsearch

RUN wget -q -O - https://npm.taobao.org/mirrors/node/v10.15.2/node-v10.15.2-linux-x64.tar.xz \
 |  tar -xJ \ 
&& mv node-v10.15.2-linux-x64 node

ENV PATH /home/elasticsearch/node/bin:$PATH

ENV ES_TMPDIR=/home/elasticsearch/elasticsearch.tmp \
    ES_DATADIR=/home/elasticsearch/elasticsearch/data \
    JAVA_HOME=/usr/java/openjdk-12
    
RUN wget -q -O - https://mirrors.huaweicloud.com/elasticsearch/${ek_version}/elasticsearch-${ek_version}-linux-x86_64.tar.gz \
 |  tar -zx \
 && mv elasticsearch-${ek_version} elasticsearch \
 && mkdir -p ${ES_TMPDIR} ${ES_DATADIR} \
 && wget -q -O - https://mirrors.huaweicloud.com/kibana/${ek_version}/kibana-${ek_version}-linux-x86_64.tar.gz \
 |  tar -zx \
 && mv kibana-${ek_version}-linux-x86_64 kibana \
 && echo "i18n.locale: zh-CN" >> kibana/config/kibana.yml \ 
 && rm -f kibana/node/bin/node \
 && ln -s $(which node) kibana/node/bin/node


# https://github.com/medcl/elasticsearch-analysis-ik/releases
RUN echo -e "y" | elasticsearch/bin/elasticsearch-plugin install -s https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v${ek_version}/elasticsearch-analysis-ik-${ek_version}.zip

CMD sh elasticsearch/bin/elasticsearch -E http.host=0.0.0.0 --quiet & kibana/bin/kibana --host 0.0.0.0 -Q

EXPOSE 9200 5601