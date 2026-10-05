# Built by .github/workflows/deploy.yml (context ., file Dockerfile) and pushed
# to Artifact Registry.
#
# A job image, not a server: Oh My Zsh is installed in the image (official installer,
# pinned commit — scripts/install.sh) for a non-root user, this repo's zsh setup is
# its ZDOTDIR, and the default command starts an interactive zsh and checks that the
# setup loaded (scripts/check.sh). Exits 0 when it did.

FROM debian:bookworm-slim
ARG BUILD_ID=""
RUN apt-get update \
 && apt-get install -y --no-install-recommends zsh git curl ca-certificates \
 && rm -rf /var/lib/apt/lists/*
RUN useradd -m -u 10001 -s /usr/bin/zsh app
ENV BUILD_ID=$BUILD_ID ZDOTDIR=/app/zsh ZSH=/home/app/.oh-my-zsh TERM=xterm-256color

WORKDIR /app
RUN chown app:app /app
USER app
COPY --chown=app:app . .
RUN sh scripts/install.sh
CMD ["sh", "scripts/check.sh"]
