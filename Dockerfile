FROM debian:latest

# Add dradis user
RUN useradd -ms /bin/bash dradis

# Install necessary packages
RUN apt-get -y update \
    && apt-get -y upgrade \
    && apt-get -y install build-essential libssl-dev libreadline-dev zlib1g-dev libsqlite3-dev libmariadb-dev git-core curl bzip2

# Install rbenv and ruby
USER dradis
WORKDIR /home/dradis/
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv \
    && git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build \
    && echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile \
    && ~/.rbenv/bin/rbenv init - \
    && echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
ENV PATH="/home/dradis/.rbenv/shims:/home/dradis/.rbenv/bin:${PATH}"
RUN RUBY_CONFIGURE_OPTS=--disable-install-doc rbenv install 2.4.1

# Pull dradis code and setup application environment
COPY --chown=dradis . /home/dradis/dradis/dradis-ce
WORKDIR /home/dradis/dradis/dradis-ce/
RUN ./bin/setup

# Start server
EXPOSE 3000
CMD ['bin/rails', 'server']
