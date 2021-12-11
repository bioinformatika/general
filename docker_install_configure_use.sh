# Install Docker in Linux Mint
# I'll follow the instructions given at https://docs.docker.com/engine/install/ubuntu/
# Uninstall old versions
sudo apt-get remove docker docker-engine docker.io containerd runc

# Install using the repository
## Update the apt package index and install packages to allow apt to use a repository over HTTPS
sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
    
## Add Docker’s official GPG key (the gpg key is stored in /usr/share/keyrings/)
 curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
# Use the following command to set up the stable repository.
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# Install docker engine
 sudo apt-get update
 sudo apt-get install docker-ce docker-ce-cli containerd.io

# This produces an ERROR: the https://download.docker.com/linux/ubuntu repository doesn't include an "Ulyssa" version, as this names comes from Linux Mint.

# I check version of Linux Mint I'm using
cat /etc/issue   # That gives Linux Mint 20.1 Ulyssa
# The problem is that under https://download.docker.com/linux/ubuntu/dists/, there's no version for Ulyssa (a Linux Mint name), but ther is for the equivalent Linux Ubuntu version (Focal).
# So, I manually change the "lsb_release -cs" variable outpuy (ulyssa), by the appropiate folder's name (focal)
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  focal stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# Now, I re-run the instructions above
# Install docker engine
 sudo apt-get update
 sudo apt-get install docker-ce docker-ce-cli containerd.io

# Then, I check that the version is installed
sudo docker run hello-world

# Manage Docker as a non-root user (https://docs.docker.com/engine/install/linux-postinstall/)
 sudo groupadd docker
 sudo usermod -aG docker $USER
# Check if the user was added
grep docker /etc/group
# Re-log into the console and try using a docker command without sudo
# If that doesn't work (like in my case), re-log the user in the system
docker run hello-world

