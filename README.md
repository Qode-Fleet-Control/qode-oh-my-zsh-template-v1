# Oh My Zsh template

Provisioned from [`Qode-Fleet-Control/fleet-template-v1`](https://github.com/Qode-Fleet-Control/fleet-template-v1) — the fleet
lifecycle contract (`bin/`, `fleet.conf`, `compose.yaml`, deploy workflows) with a
Oh My Zsh starter laid on top. **A job, not a service**: the image's default command runs the
check and exits 0 on success; nothing listens on `$PORT`.

## What it is

A versioned zsh setup (`VERSION`, currently 1.0.0) on [Oh My Zsh](https://ohmyz.sh):

| path | what |
|---|---|
| `zsh/.zshrc` | the rc file — theme, plugins, pinned (no self-update) |
| `zsh/custom/plugins/qode/qode.plugin.zsh` | the setup's own plugin (`qode_hello`, `mkcd`, `ll`) |
| `zsh/custom/themes/qode.zsh-theme` | the setup's own theme: `qode <cwd> (<branch>*) %` |
| `scripts/install.sh` | installs Oh My Zsh at a pinned commit (official installer) |
| `scripts/check.sh` | **the job**: interactive zsh, checks the setup loaded |

`zsh/` is the ZDOTDIR: `.zshrc` points `ZSH_CUSTOM` at its own `custom/` directory, so
the repo is the single source of the setup. Add plugins to `plugins=(...)`, edit the
theme, bump `VERSION`.

## Run it

**With docker** (what the fleet does):

    docker compose build
    docker compose run --rm app        # the check; exit 0 = setup loaded
    docker compose run --rm app zsh    # try the shell itself

**Without docker** (needs zsh, git, curl; your `~/.zshrc` is left alone):

    ZSH="$PWD/.oh-my-zsh" sh scripts/install.sh   # = fleet.conf INSTALL_CMD
    ZSH="$PWD/.oh-my-zsh" sh scripts/check.sh
    ZDOTDIR="$PWD/zsh" ZSH="$PWD/.oh-my-zsh" zsh  # use it

## Origin

Oh My Zsh's official installer, pinned to commit `d745fbf3bd49a5038e089d7d343ca89db0cbaaff`
(scripts/install.sh):

    sh install.sh --unattended --keep-zshrc   # install.sh from raw.githubusercontent.com/ohmyzsh/ohmyzsh/<commit>/tools/install.sh

The zsh setup itself (`zsh/`) is hand-written to the layout Oh My Zsh documents for
customisation (`$ZSH_CUSTOM/plugins/<name>/<name>.plugin.zsh`,
`$ZSH_CUSTOM/themes/<name>.zsh-theme`).

## Deviations from stock output, and why

- **No stock `~/.zshrc`.** `--keep-zshrc` with `ZDOTDIR=zsh/` makes the installer keep
  this repo's `.zshrc` instead of writing its template into `$HOME` — the setup is
  versioned here, and a local install never touches your own dotfiles.
- **Pinned commit.** The installer clones `master`; `scripts/install.sh` then checks out
  the pinned commit, and `.zshrc` disables auto-update, so the image is reproducible.
- `ZSH_CUSTOM` lives in the repo (`zsh/custom`), not inside `$ZSH`.
## Verified

2026-10-05, Docker 29.8.2: `docker compose build` then `docker compose run --rm app` —
oh-my-zsh loaded, git + qode plugins, qode theme, prompt renders (`qode /app %`),
nothing on stderr, `PASS`, exit 0. Locally (zsh 5.9, throwaway `$HOME`):
`FLEET_RUNTIME=process bin/run` installed Oh My Zsh into `./.oh-my-zsh` (then stopped at
the empty start step, as intended) and `ZSH=$PWD/.oh-my-zsh sh scripts/check.sh` passed;
`$HOME` was left empty.


## Fleet lifecycle

`fleet.conf` drives every script in `bin/` (see `docs/fleet-lifecycle.md`). On the fleet
the docker runtime runs `DOCKER_BUILD_CMD` (`docker compose build`) and, because this is
a job and not a service, stops there: `DOCKER_START_CMD` is empty, the same as
`START_CMD`. Run the job itself with `docker compose run --rm app`.

    ./bin/run                    # docker runtime: builds the image, then stops (no server)
    docker compose run --rm app  # runs the job; exit code 0 = pass
    FLEET_RUNTIME=process ./bin/run   # no docker: runs INSTALL_CMD, then stops at start

`bin/run` ends with the template's own "no START_CMD" message — that is intentional.

## Serving over HTTP

Fleet apps are served at the root of their own hostname
(`https://<hash>.<FLEET_APP_DOMAIN>/`). **This repo has no HTTP surface**: `PORT`,
`HEALTH_PATH` and `START_CMD` are empty and `compose.yaml` publishes nothing. If you add
an HTTP endpoint, listen on `0.0.0.0:$PORT` (read at runtime), serve at `/`, set `PORT`,
`HEALTH_PATH`, `START_CMD` and `DOCKER_START_CMD='docker compose up --remove-orphans'`
in `fleet.conf`, and publish `"${PORT:-N}:${PORT:-N}"` in `compose.yaml`.

`compose.yaml` passes the fleet's variables (`DATABASE_URL`, `REDIS_URL`, `S3_*`,
`SMTP_*` …) through to the container without values; this template reads none of them.
