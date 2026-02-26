#!/usr/bin/env bash
set -e
echo "* Starting Falco in modern_ebpf mode (s390x)"

exec /usr/bin/falco -o engine.kind=modern_ebpf "$@"
