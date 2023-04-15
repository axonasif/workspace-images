#!/usr/bin/env bash
eval "$(pyenv init -)"
# shellcheck source=/dev/null
VIRTUAL_ENV_DISABLE_PROMPT=true source "${RUNTIME_VIRTUAL_ENV}/bin/activate"
