# Migrate from Debian Buster to Beowulf
FROM debian:buster

# The first step is to change the sources.list to point to the Beowulf repositories.
COPY config/etc/apt/sources.list /etc/apt/sources.list

# Update the package lists from the Beowulf repositories.
RUN apt-get update --allow-insecure-repositories

# The Devuan keyring should now be installed so that packages can be authenticated.
RUN apt-get install -y devuan-keyring --allow-unauthenticated

# Update the package lists again so that packages are authenticated from here on in.
RUN apt-get update

# Upgrade your packages so that you have the latest versions. Note that this does not complete the migration.
RUN apt-get upgrade -y

# Once this is done eudev needs to be installed.
RUN apt-get install -y eudev || true

# The last command is known to cause package breaks but we will fix this as part of the migration process.
RUN apt-get -f install

# Now you can perform the migration proper.
RUN apt-get dist-upgrade -y

# We have migrated to Devuan so systemd related packages are not needed now.
RUN apt-get purge systemd libnss-systemd || true

# Install packages required for Molecule
RUN apt-get install -y sudo python3

# Now remove any packages orphaned by the migration process, and any unusable archives left over from your Debian install.
RUN apt-get autoremove --purge
RUN apt-get autoclean
RUN /bin/rm -fr /etc/systemd /lib/systemd