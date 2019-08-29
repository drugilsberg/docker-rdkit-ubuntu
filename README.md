# docker-rdkit-ubuntu

A docker image containing a "lightweight" RDKit installation.

The image is designed to provide a starting container for testing python packages using RDKit on Ubuntu.
Pulling the image in a CI pipeline making use of Docker allows to spare time when building/testing the software.

The `Dockerfile` is heavily inspired by [https://github.com/InformaticsMatters/docker-rdkit](https://github.com/InformaticsMatters/docker-rdkit) and [https://github.com/mcs07/docker-rdkit](https://github.com/mcs07/docker-rdkit).

## build

Build the image by typing:

```sh
docker-compose -f docker/docker-compose.yml build
```

## run

### `docker`

Run the container by typing:

```sh
docker run -it drugilsberg/rdkit-ubuntu
```

### `docker-compose`

Run the container by typing:

```sh
docker-compose -f docker/docker-compose.yml run
```

