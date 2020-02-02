#!/usr/bin/env bash

set -euf -o pipefail
set -o xtrace

cd "$(dirname "$0")"

name="sealed-secrets"

kubeseal --controller-namespace=sealed-secrets \
  --controller-name="${name}" \
  --fetch-cert \
  > sealed-secrets.pub

grep -lR --include \*.yaml SealedSecret . | while read -r secret
do
    kubeseal \
      --controller-namespace "${name}" \
      --controller-name "${name}" \
      --format yaml \
      --re-encrypt \
      < "${secret}" \
      > "${secret}.tmp"
    mv -v "${secret}.tmp" "${secret}"
done
