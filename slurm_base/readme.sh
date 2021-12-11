# We build the docker image
docker build -t slurm_base .

# Create a container
DOCKER_ID=$(docker run -d -v /mnt/:/mnt -m 28g --cpus 10 -h controlmachine -i slurm_base)

# And test that Java, Slurm and Conda ar up and running
docker exec -i $DOCKER_ID sinfo
docker exec -i $DOCKER_ID java -version
docker exec -i $DOCKER_ID conda env list

# We can stop the running container
docker container ls
docker stop $DOCKER_ID
