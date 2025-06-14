# Dev container for the project.
# We're starting from Node.js since we're using Scala.js for the frontend

FROM mcr.microsoft.com/vscode/devcontainers/java:21

# Install Docker
RUN curl https://raw.githubusercontent.com/docker/docker-install/refs/heads/master/install.sh | bash -

# Install the Scala toolchain (Coursier)
RUN curl -fL "https://github.com/coursier/launchers/raw/master/cs-x86_64-pc-linux.gz" | gzip -d > cs && \
    mv cs /usr/local/bin &&\
    chmod +x /usr/local/bin/cs &&\
    cs setup --env >> /etc/profile.d/coursier.sh

# Install the just command runner and Atlas Go
RUN curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin \
    && curl -sSf https://atlasgo.sh | sh
