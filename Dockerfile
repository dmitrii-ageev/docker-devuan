# Migrate from Debian Bullseye to Chimaera
FROM debian:bullseye

# Update the package lists from the Bullseye repositories.
RUN apt-get update

# Install CA certificates
RUN apt-get install -y ca-certificates

# Change the sources.list to point to the Chimaera repositories.
COPY config/etc/apt/sources.list /etc/apt/sources.list

# Update the package lists from the Chimaera repositories.
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
RUN apt-get autoremove --purge -y
RUN apt-get autoclean
RUN /bin/rm -fr /etc/systemd /lib/systemd