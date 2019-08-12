FROM fabiosammy/rails:5.2.3
MAINTAINER fabiosammy <fabiosammy@gmail.com>

USER devel

# Set the bundle to external volume
ENV BUNDLE_APP_CONFIG=${APP}/.bundle \
  BUNDLE_BIN=${APP}/.bundle/bin \
  BUNDLE_GEMFILE=${APP}/Gemfile \
  BUNDLE_PATH=${APP}/.bundle \
  BUNDLE_SYSTEM_BINDIR=${APP}/.bundle/bin \
  GEM_HOME=${APP}/.bundle \
  GEM_PATH=${APP}/.bundle:/usr/local/bundle \
  PATH=${APP}/.bundle/bin:$PATH

# Export environments to each ssh connection
#RUN sudo touch /etc/profile.d/container_environment.sh

RUN sudo bundle config --global jobs $(nproc) && \
  echo "BUNDLE_APP_CONFIG=${BUNDLE_APP_CONFIG}" | sudo tee -a /etc/environment && \
  echo "BUNDLE_BIN=${BUNDLE_BIN}" | sudo tee -a /etc/environment && \
  echo "BUNDLE_GEMFILE=${BUNDLE_GEMFILE}" | sudo tee -a /etc/environment && \
  echo "BUNDLE_PATH=${BUNDLE_PATH}" | sudo tee -a /etc/environment && \
  echo "BUNDLE_SYSTEM_BINDIR=${BUNDLE_SYSTEM_BINDIR}" | sudo tee -a /etc/environment && \
  echo "GEM_HOME=${GEM_HOME}" | sudo tee -a /etc/environment && \
  echo "GEM_PATH=${GEM_PATH}" | sudo tee -a /etc/environment && \
  echo "PATH=${PATH}" | sudo tee -a /etc/environment && \
  echo "GEM_HOME=${GEM_HOME}" | sudo tee -a /etc/profile && \
  echo "GEM_PATH=${GEM_PATH}" | sudo tee -a /etc/profile && \
  echo "PATH=${PATH}" | sudo tee -a /etc/profile

# Copy the main application.
#COPY --chown=devel:devel . ./

# Copy the Gemfile as well as the Gemfile.lock and install
# the RubyGems. This is a separate step so the dependencies
# will be cached unless changes to one of those two files
# are made.
COPY --chown=devel:devel .bundle/ ./
COPY --chown=devel:devel Gemfile ./
COPY --chown=devel:devel Gemfile.lock ./
#COPY vendor/cache ./vendor/cache
RUN bundle install --path ${APP}/.bundle && \
  gem install --install-dir ${APP}/.bundle ruby-debug-ide --pre && \
  gem install --install-dir ${APP}/.bundle debase --pre

# The main command to run when the container starts. Also
# tell the Rails dev server to bind to all interfaces by
# default.
CMD ["/usr/bin/sudo", "/usr/sbin/sshd", "-D"]

