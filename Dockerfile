FROM hugomods/hugo:exts-0.152.2

ARG CHROMA_VERSION=2.20.0

RUN apk add git ruby ruby-dev curl && \
  gem install asciidoctor asciidoctor-chroma && \
  ARCH=$(uname -m) && \
  case "$ARCH" in \
  x86_64)  CHROMA_ARCH="amd64" ;; \
  aarch64) CHROMA_ARCH="arm64" ;; \
  esac && \
  curl -sSL "https://github.com/alecthomas/chroma/releases/download/v${CHROMA_VERSION}/chroma-${CHROMA_VERSION}-linux-${CHROMA_ARCH}.tar.gz" | tar -xz -C /usr/local/bin
