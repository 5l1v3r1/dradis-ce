FROM debian:latest

RUN useradd -ms /bin/bash dradis

RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get -y install build-essential libssl-dev libreadline-dev zlib1g-dev libsqlite3-dev libmysqlclient-dev git-core curl bzip2

USER dradis
WORKDIR /home/dradis/
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv
RUN git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

RUN echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
RUN ~/.rbenv/bin/rbenv init -
RUN echo 'eval "$(rbenv init -)"' >> ~/.bash_profile

ENV PATH="/home/dradis/.rbenv/shims:/home/dradis/.rbenv/bin:${PATH}"

COPY --chown=dradis . /home/dradis/dradis/dradis-ce
WORKDIR /home/dradis/dradis/dradis-ce/
RUN RUBY_CONFIGURE_OPTS=--disable-install-doc rbenv install 2.4.1
RUN ./bin/setup

# EXPOSE 3000
# ENTRYPOINT ['bin/rails', 'server']
