 #!/bin/sh

echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin
docker tag drugilsberg/rdkit-ubuntu:latest drugilsberg/rdkit-ubuntu:${TRAVIS_COMMIT}
docker push drugilsberg/rdkit-ubuntu:${TRAVIS_COMMIT}
docker push drugilsberg/rdkit-ubuntu:latest
