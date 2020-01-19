#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

for secret in $(grep -lR --include \*.yaml SealedSecret .)
do
    kubeseal \
      --controller-namespace sealed-secrets \
      --controller-name sealed-secrets \
      --format yaml \
      --re-encrypt \
      < "${secret}" \
      > "${secret}.tmp"
    mv -v "${secret}.tmp" "${secret}"
done
