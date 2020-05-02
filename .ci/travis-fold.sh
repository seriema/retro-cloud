#!/bin/bash
# Convenience scripts for Travis fold. Based on these scripts:
# * https://github.com/spotify/ios-ci/blob/master/bin/travis_fold
# * https://www.koszek.com/blog/2016/07/25/dealing-with-large-jobs-on-travis/

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

tmpTravisFoldName=/tmp/.travis_fold_name

travis_fold() {
    local action=$1
    local name=$2
    echo -en "travis_fold:${action}:${name}\r"
}

FOLD_START() {
    local name=$1
    local heading=$2
    travis_fold start "$name"
    echo -en "\033[0K${heading}\n"
    echo -n "$name" > "$tmpTravisFoldName"
}

FOLD_END() {
    travis_fold end "$(cat "${tmpTravisFoldName}")"
}
