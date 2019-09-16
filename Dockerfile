FROM beevelop/android:v25.2.5

# Install external dependencies: Google Chrome and dumb-init
# TODO: only run this if the file doesnt exist
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -                                            \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'  \
    && apt-get update && apt-get install -y google-chrome-stable                                                                  \
    && wget https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64.deb                                  \
    && dpkg -i dumb-init_*.deb

ENV NODEJS_VERSION=11.10.0   \
    CORDOVA_VERSION=8.0.0    \
    IONIC_VERSION=5.2.3      \
    PATH=$PATH:/opt/node/bin

# Install Node
RUN apt-get update                                                                                                                \
    && apt-get install -y curl git ca-certificates --no-install-recommends                                                        \
    && mkdir /opt/node                                                                                                            \
    && cd /opt/node                                                                                                               \
    && curl -sL https://nodejs.org/dist/v${NODEJS_VERSION}/node-v${NODEJS_VERSION}-linux-x64.tar.gz | tar xz --strip-components=1

# Install Cordova
RUN npm i -g --unsafe-perm cordova@${CORDOVA_VERSION}

# Install Ionic
RUN apt-get update                                                                                                                \
    && apt-get install -y git bzip2 openssh-client                                                                                \
    && npm i -g --unsafe-perm ionic@${IONIC_VERSION}                                                                              \
    && ionic --no-interactive config set -g daemon.updates false


# ID utilisateur le plus courant
ARG NODE_UID=1000

# NOGROUP par défaut
ARG NODE_GID=65534

# Create node user and install native-run
RUN mkdir -p /var/www/html                                                                                                        \
    && adduser node --no-create-home --uid ${NODE_UID} --gid ${NODE_GID} --home /var/www/html --disabled-password --gecos none    \
    && chown -R node /var/www/html
# && npm install -g native-run

# Cleanup apt:
RUN  rm -rf /var/lib/apt/lists/* && apt-get clean

WORKDIR /var/www/html

