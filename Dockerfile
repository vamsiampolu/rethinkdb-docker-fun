FROM rethinkdb:latest
RUN apt-get -y update && apt-get install -y curl git
RUN curl -sL https://deb.nodesource.com/setup_8.x |  bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg |  apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" |  tee /etc/apt/sources.list.d/yarn.list
RUN apt-get -y update && apt-get install -y nodejs yarn python-software-properties apt-file
RUN apt-file -y update
RUN apt-get -y install software-properties-common
RUN apt-get -y install vim
RUN cp /etc/rethinkdb/default.conf.sample /etc/rethinkdb/instances.d/instance1.conf 
RUN echo "bind=all" >> /etc/rethinkdb/instances.d/instance1.conf
RUN yarn add rethinkdb
