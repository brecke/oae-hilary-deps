# Hilary dependencies base image

Container image based on alpine linux for Hilary to run on with all system dependencies

## Usage

### Run from dockerhub

```console
docker run -it --name=hilary-deps --net=host oaeproject/oae-hilary-deps-docker
```

### Build the image locally

```console
# Step 1: Build the image
docker build -f Dockerfile -t oae-hilary-deps-docker:latest .
# Step 2: Run image
docker run -it --name=hilary-deps --net=host oae-hilary-deps-docker:latest
```
