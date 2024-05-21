FROM mysql:latest

RUN microdnf install git wget vim jq
RUN cd /opt && git clone https://github.com/hogehuga/richmentdb
RUN cd /opt/richmentdb && git clone https://github.com/cisagov/vulnrichment
RUN cp /opt/richmentdb/env/.bashrc /root
