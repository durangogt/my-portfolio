#!/usr/bin/env bash
# deploy.sh – Build the portfolio and sync assets to S3, then invalidate CloudFront.
#
# Usage:
#   ./terraform/deploy.sh [--skip-build]
#
# Environment variables (required unless --skip-build is passed):
#   PORTFOLIO_BUCKET_NAME  – target S3 bucket (e.g. portfolio.jamesickes.info)
#   CLOUDFRONT_DIST_ID     – CloudFront distribution ID for cache invalidation
#
# The script assumes AWS credentials are already configured in the environment
# (e.g. via OIDC in GitHub Actions or a local AWS profile).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

SKIP_BUILD=false
for arg in "$@"; do
  [[ "$arg" == "--skip-build" ]] && SKIP_BUILD=true
done

# ── Resolve required variables ──────────────────────────────────────────────
PORTFOLIO_BUCKET_NAME="${PORTFOLIO_BUCKET_NAME:-}"
CLOUDFRONT_DIST_ID="${CLOUDFRONT_DIST_ID:-}"

if [[ -z "$PORTFOLIO_BUCKET_NAME" || -z "$CLOUDFRONT_DIST_ID" ]]; then
  echo "ERROR: PORTFOLIO_BUCKET_NAME and CLOUDFRONT_DIST_ID must be set." >&2
  exit 1
fi

# ── Build ────────────────────────────────────────────────────────────────────
if [[ "$SKIP_BUILD" == false ]]; then
  echo "==> Installing Node dependencies…"
  cd "${REPO_ROOT}"
  npm ci

  echo "==> Running tests…"
  npm test

  echo "==> Building webpack bundle…"
  NODE_OPTIONS='--openssl-legacy-provider' npm run webpack
fi

# ── Sync to S3 ───────────────────────────────────────────────────────────────
echo "==> Syncing site assets to s3://${PORTFOLIO_BUCKET_NAME}…"
aws s3 sync "${REPO_ROOT}" "s3://${PORTFOLIO_BUCKET_NAME}" \
  --exclude "*" \
  --include "index.html" \
  --include "favicon.ico" \
  --include "styles/main.css" \
  --include "images/*" \
  --include "dist/bundle.js" \
  --delete \
  --cache-control "max-age=86400"

# index.html should not be cached aggressively so browsers pick up new deploys
aws s3 cp "${REPO_ROOT}/index.html" "s3://${PORTFOLIO_BUCKET_NAME}/index.html" \
  --cache-control "no-cache, no-store, must-revalidate" \
  --content-type "text/html"

# ── CloudFront invalidation ──────────────────────────────────────────────────
echo "==> Creating CloudFront invalidation for distribution ${CLOUDFRONT_DIST_ID}…"
INVALIDATION_ID=$(aws cloudfront create-invalidation \
  --distribution-id "${CLOUDFRONT_DIST_ID}" \
  --paths "/*" \
  --query "Invalidation.Id" \
  --output text)

echo "==> Invalidation ${INVALIDATION_ID} created."
echo "==> Deploy complete. Site available at: https://${PORTFOLIO_BUCKET_NAME}"
echo "CLOUDFRONT_URL=https://${PORTFOLIO_BUCKET_NAME}"
