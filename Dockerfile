# Use logstash 7.11.1 as the base image
FROM docker.elastic.co/logstash/logstash:7.11.1

ARG ELASTIC_CLOUD_ID_ARG
ARG ELASTIC_CRED_ARG

ENV ELASTIC_CLOUD_ID=$ELASTIC_CLOUD_ID_ARG
ENV ELASTIC_CRED=$ELASTIC_CRED_ARG

# Remove existing config file
RUN rm -f /usr/share/logstash/pipeline/logstash.conf 
ADD logstash.conf /usr/share/logstash/pipeline/