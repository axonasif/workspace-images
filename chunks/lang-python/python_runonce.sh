#!/usr/bin/env bash

# shellcheck disable=SC2120

if test -e "${GITPOD_REPO_ROOT:-}"; then {
	# Set $HOME/.pyenv/shims/python as the default Interpreter for ms-python.python VSCode extension
	input="$(
		printf '{ "python.defaultInterpreterPath": "%s", "python.terminal.activateEnvironment": false }\n' "${RUNTIME_VIRTUAL_ENV}/bin/python"
	)"
	for vscode_machine_settings_file in \
		"/workspace/.vscode-remote/data/Machine/settings.json" \
		"$HOME/.vscode-server/data/Machine/settings.json"; do {

			# Create the vscode machine settings file if it doesnt exist
			if test ! -e "$vscode_machine_settings_file"; then {
				mkdir -p "${vscode_machine_settings_file%/*}" || continue
				touch "$vscode_machine_settings_file"
			}; fi

			# Check json syntax
			if test ! -s "$vscode_machine_settings_file" || ! jq -reM '""' "$vscode_machine_settings_file" >/dev/null 2>&1; then {
				printf '%s\n' "$input" >"$vscode_machine_settings_file"
			}; else {
				# Remove any trailing commas
				sed -i -e 's|,}| }|g' -e 's|, }| }|g' -e ':begin;$!N;s/,\n}/ \n}/g;tbegin;P;D' "$vscode_machine_settings_file"

				# Merge the input settings with machine settings.json
				tmp_file="${vscode_machine_settings_file%/*}/.tmp$$"
				cp -a "$vscode_machine_settings_file" "$tmp_file"
				jq -s '.[0] * .[1]' - "$tmp_file" <<<"$input" >"$vscode_machine_settings_file"
				rm -f "$tmp_file"
			}; fi

		}; done

	# create-overlay "$HOME/.pyenv"
	# Create virtualenv
	if python -c 'from importlib.util import find_spec; exit(1 if find_spec("venv") is None else 0)'; then {
		cmd=(python -m venv)
	}; else {
		cmd=(virtualenv)
	}; fi
	"${cmd[@]}" "${RUNTIME_VIRTUAL_ENV}"

}; fi
