# docker-llama-swap

Multi-architecture Docker image for [llama-swap](https://github.com/mostlygeek/llama-swap) with Docker CLI support, built automatically from upstream.

## Overview

This project packages llama-swap into a Docker container that includes the Docker CLI, allowing llama-swap to manage containers on the host. Images are built for both `amd64` and `arm64` architectures and published to GitHub Container Registry.

## How It Works

- A scheduled GitHub Actions workflow builds the Docker image weekly and on every push to `main` that modifies the `Dockerfile` or workflow.
- Each architecture is built natively on its corresponding runner (`ubuntu-24.04` for amd64, `ubuntu-24.04-arm` for arm64) and combined into a multi-arch manifest.
- The image clones and compiles llama-swap from source using the specified `LLAMA_SWAP_REF` (defaults to `main`) and bundles the Docker CLI for container orchestration.

## Example Run Command

```bash
docker run -d --rm \
  --pull=always \
  --name llama-swap \
  -p 8080:8080 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$PWD/config.yaml:/app/config.yaml" \
  ghcr.io/unitvectory-labs/docker-llama-swap:current \
  -config /app/config.yaml \
  -listen 0.0.0.0:8080 \
  -watch-config
```
