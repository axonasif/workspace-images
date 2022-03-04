#!/bin/bash
{
    set -eEuT -o pipefail;
    trap 'err_exit_job' ERR SIGINT;
    function err_exit_job() {
        if test -n "$_dazzle_yaml_orig"; then {
            printf '%s\n' "$_dazzle_yaml_orig" > "$_dazzle_yaml_path" \
            || { log::error "Failed to restore the original ${_dazzle_yaml_path##*/}" || exit; }
        } else {
            log::error "No dazzle.yaml backup was found" || exit;
        } fi
    }

    function log::error() {
        printf 'error: %s\n' "$1";
        return "${2:-1}";
    }

    _source_dir="$(readlink -f "$0")" && _source_dir="${_source_dir%/*}";
    _dazzle_yaml_path="$_source_dir/dazzle.yaml";
    _dazzle_yaml_orig="$(< "$_source_dir/${_dazzle_yaml_path##*/}")";

    # Parse args
    while test $# -gt 0; do {
        _arg="$1";
        case "${_arg}" in
            --ignore=*)
                _value="${_arg##--ignore=}";
                _ignore_list=(${_value//,/ });
                shift;
            ;;
            --ignore|-i)
                test $# -lt 2 && { log::error "No value provided for $_arg" 1 || exit;}
				_ignore_list=(${2//,/ });
				shift; shift;
            ;;
            *)
                if [[ ! "$_arg" =~ ^- ]]; then {
                    _combine_list+=("$_arg");
                } fi
                shift
            ;;
        esac
    } done


    REPO=localhost:5000/dazzle;

    # Ignore chunks if specified
    if test -v _ignore_list; then {
        if test -v _combine_list && test "${_ignore_list[*]}" == all; then {
            _ignore_list=(); # Recreate the ignore list

            while read -r _dazzle_yaml_name; do {
                _var="${_dazzle_yaml_name#*- }" && _var="${_var//\"/}";
                _chunk_names+=("$_var") && unset _var;
            } done < <(grep -Pzo '(?s)chunks:.*?name:' "$_dazzle_yaml_path" | grep -Eav '\- name:|envvars:|chunks:')

            for _chunk_name in "${_chunk_names[@]}"; do {
                _chunk_name="${_chunk_name%:*}"
                _sub_chunk="$_source_dir/chunks/$_chunk_name/chunk.yaml";
                if test -e "${_sub_chunk}"; then {
                    while read -r _dazzle_yaml_name; do {
                        _var="${_dazzle_yaml_name#*: }" && _var="${_var//\"/}";
                        _chunk_names+=("${_chunk_name}:${_var}") && unset _var;
                    } done < <(grep -o '\- name: .*' "$_sub_chunk")
                } fi
            } done

            for _chunk_name in "${_chunk_names[@]}"; do {
                # if [[ ! "${_combine_list[@]}" =~ (^| )${_chunk_name}($| ) ]]; then {
                if [[ ! "${_combine_list[*]}" =~ ${_chunk_name%:*} ]]; then { # It appears we can't be explicit about ignoring the specific chunk tag/version (e.g `lang-go:1.17.5`)
                                                                                # Dazzle will not ignore them if we do, probably a bug.
                    _ignore_list+=("$_chunk_name");
                } fi
            } done
        } fi
        mapfile -t _ignore_list < <(printf '%s\n' "${_ignore_list[@]}" | sed 's|:.*||g' | awk '!seen[$0]++'); # sed is unnecessary here, will keep the tag when dazzle can ignore them properly
        for _chunk in "${_ignore_list[@]}"; do {
            dazzle project ignore "${_chunk}";
        } done
    } fi

    for _arr in _ignore_list _combine_list; do {
        if test -v $_arr; then {
            _array_data="$(declare -p $_arr)";
            printf 'Options: %s\n' "${_array_data#*_}";
        } fi
    } done

    # First, build chunks without hashes
    dazzle build $REPO -v --chunked-without-hash;
    # Second, build again, but with hashes
    dazzle build $REPO -v;
    # Third, create combinations of chunks
    if test -v _combine_list; then {
        for _chunk in "${_combine_list[@]}"; do {
            _name="${_chunk%:*}" && _name="${_name#*-}";

            if test -v $_name; then {
                eval "${_name}=\$$_name,$_chunk";
            } else {
                eval "${_name}=$_chunk";
            } fi

            _names+=("$_name") && unset _name;
            unset _chunk;
        } done

        for _name in "${_names[@]}"; do {
            declare -n _ref="$_name";
            dazzle combine $REPO --chunks "${_name}=${_ref}" -v;
            unset _ref;
        } done
    } else {
        dazzle combine $REPO --all -v;
    } fi

    err_exit_job;
}
