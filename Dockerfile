# === Builder ==================================================================

FROM golang:1.20 as builder
WORKDIR ${GITHUB_WORKSPACE:-/repository}
COPY . .
RUN set -ex; \
    \
    CGO_ENABLED=0 GOOS=linux go build \
        -a -installsuffix cgo \
        -o ./build/compare-directories ./cmd/compare-directories/

# === Runtime ==================================================================

FROM alpine:3.18.2
RUN set -ex; \
    \
    apk --no-cache add \
        curl=8.1.2-r0 \
        git-lfs=3.3.0-r2 \
        git=2.40.1-r0 \
        jq=1.6-r3
COPY --from=builder ${GITHUB_WORKSPACE:-/repository}/entrypoint.sh /
COPY --from=builder ${GITHUB_WORKSPACE:-/repository}/build/compare-directories /
ENTRYPOINT ["/entrypoint.sh"]

# === Metadata =================================================================

ARG IMAGE
ARG TITLE
ARG DESCRIPTION
ARG LICENCE
ARG GIT_URL
ARG GIT_BRANCH
ARG GIT_COMMIT_HASH
ARG BUILD_DATE
ARG BUILD_VERSION
LABEL \
    org.opencontainers.image.base.name=$IMAGE \
    org.opencontainers.image.title="$TITLE" \
    org.opencontainers.image.description="$DESCRIPTION" \
    org.opencontainers.image.licenses="$LICENCE" \
    org.opencontainers.image.url=$GIT_URL \
    org.opencontainers.image.ref.name=$GIT_BRANCH \
    org.opencontainers.image.revision=$GIT_COMMIT_HASH \
    org.opencontainers.image.created=$BUILD_DATE \
    org.opencontainers.image.version=$BUILD_VERSION
