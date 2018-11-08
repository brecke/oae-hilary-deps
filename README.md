# Hilary dependencies base image

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/b9d58c124c97467994f21a6ef48fd1e3)](https://app.codacy.com/app/oaeproject/oae-hilary-deps-docker?utm_source=github.com&utm_medium=referral&utm_content=oaeproject/oae-hilary-deps-docker&utm_campaign=Badge_Grade_Settings)

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
