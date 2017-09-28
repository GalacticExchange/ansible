FROM ubuntu:16.04

RUN apt-get update
#RUN apt-get install -y nodejs
#RUN ln -s /usr/bin/nodejs /usr/bin/node
RUN apt-get install -y curl
#RUN apt-get install -y sudo

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs

#RUN apt-get install -y npm
RUN npm install -g ethereumjs-testrpc

EXPOSE 8545

CMD ["testrpc","-h", "0.0.0.0"]