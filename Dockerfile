FROM ubuntu

WORKDIR /tmp

RUN "hello world" > /tmp/testfile

ENV myname Saurav Thakur

COPY testfile1 /tmp

ADD test.tar.gz /tmp
