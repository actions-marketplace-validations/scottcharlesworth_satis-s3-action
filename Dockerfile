FROM phpdockerio/php:8.4-cli

# Install awscli and openssh-client
RUN apt-get update \
    && apt-get install -yq --no-install-recommends awscli openssh-client \
    && apt-get clean

# Gather the public SSH host keys of GitHub and Bitbucket add to known hosts
RUN mkdir ~/.ssh \
	&& ssh-keyscan -H github.com >> /root/.ssh/known_hosts \
    && ssh-keyscan -H bitbucket.org >> /root/.ssh/known_hosts

# Create composer/satis project
RUN composer create-project composer/satis:dev-main ~/satis --no-interaction

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /root/entrypoint.sh

# Add execution permissions
RUN ["chmod", "+x", "/root/entrypoint.sh"]

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/root/entrypoint.sh"]