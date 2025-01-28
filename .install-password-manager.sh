#!/bin/sh

type bw >/dev/null 2>&1 && exit

case "$(uname -s)" in
Darwin)
    echo "installing bitwarden-cli"
    brew install bitwarden-cli
    ;;
*)
    echo "unsupported OS"
    exit 1
    ;;
esac
