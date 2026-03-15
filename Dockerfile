# syntax=docker/dockerfile:1

FROM node:24-bookworm AS builder

ARG LLAMA_SWAP_REF=main
ARG GO_VERSION=1.26.1
ARG TARGETARCH

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      git \
      make \
      xz-utils && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-${TARGETARCH}.tar.gz" -o /tmp/go.tgz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf /tmp/go.tgz && \
    rm /tmp/go.tgz

ENV PATH="/usr/local/go/bin:${PATH}"

WORKDIR /src

RUN git clone --depth 1 --branch ${LLAMA_SWAP_REF} https://github.com/mostlygeek/llama-swap.git .

RUN make clean linux

FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl gnupg && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    printf "Types: deb\nURIs: https://download.docker.com/linux/debian\nSuites: bookworm\nComponents: stable\nSigned-By: /etc/apt/keyrings/docker.asc\n" > /etc/apt/sources.list.d/docker.sources && \
    apt-get update && \
    apt-get install -y --no-install-recommends docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

ARG TARGETARCH

WORKDIR /app

COPY --from=builder /src/build/llama-swap-linux-${TARGETARCH} /usr/local/bin/llama-swap

EXPOSE 8080

ENTRYPOINT ["llama-swap"]
CMD ["-config", "/app/config.yaml", "-listen", "0.0.0.0:8080", "-watch-config"]
