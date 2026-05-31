# === Default Variables ===
LABEL_COLOR="555"
STYLE="flat"
FORMAT="svg"
BASE_URL="https://img.shields.io"

set -eu

# === Functions ===
url_encode() {
  _str="$1"
  _encoded=""
  _i=0
  _len=${#_str}
  while [ "$_i" -lt "$_len" ]; do
    _c=$(printf '%s' "$_str" | cut -c$((_i + 1)))
    case "$_c" in
      [a-zA-Z0-9.~_-]) _encoded="${_encoded}${_c}" ;;
      *) _encoded="${_encoded}$(printf '%%%02X' "'${_c}")" ;;
    esac
    _i=$((_i + 1))
  done
  printf '%s' "$_encoded"
}

# === Parse Arguments ===
while [ "$#" -gt 0 ]; do
  case "$1" in
    --label) LABEL="$2"; shift 2 ;;
    --message) MESSAGE="$2"; shift 2 ;;
    --color) COLOR="$2"; shift 2 ;;
    --label-color) LABEL_COLOR="${2:-$LABEL_COLOR}"; shift 2 ;;
    --logo) LOGO="$2"; shift 2 ;;
    --logo-color) LOGO_COLOR="$2"; shift 2 ;;
    --style) STYLE="${2:-$STYLE}"; shift 2 ;;
    --format) FORMAT="${2:-$FORMAT}"; shift 2 ;;
    --base-url) BASE_URL="${2:-$BASE_URL}"; shift 2 ;;
    *) echo "::error::Invalid option $1"; exit 1 ;;
  esac
done

# === Validate Arguments ===
if [ -z "${LABEL:-}" ] || [ -z "${MESSAGE:-}" ] || [ -z "${COLOR:-}" ]; then
  echo "::error::Usage: $0 --label <label> --message <message> --color <color> [--label-color <label_color>] [--logo <logo>] [--logo-color <logo_color>] [--style <style>] [--format <format>] [--base-url <base_url>]"
  exit 1
fi

# === Main ===
LABEL_ENCODED=$(url_encode "${LABEL}")
MESSAGE_ENCODED=$(url_encode "${MESSAGE}")

PARAMS="label=${LABEL_ENCODED}&message=${MESSAGE_ENCODED}&color=${COLOR}"
PARAMS="${PARAMS}&labelColor=${LABEL_COLOR}"
PARAMS="${PARAMS}&style=${STYLE}"

if [ -n "${LOGO:-}" ]; then
  LOGO_ENCODED=$(url_encode "${LOGO}")
  PARAMS="${PARAMS}&logo=${LOGO_ENCODED}"
fi

if [ -n "${LOGO_COLOR:-}" ]; then
  PARAMS="${PARAMS}&logoColor=${LOGO_COLOR}"
fi

BADGE_URL="${BASE_URL}/static/v1?${PARAMS}"
echo "Badge URL: ${BADGE_URL}"

EXPECTED_CT=""
case "${FORMAT}" in
  svg) 
    BADGE_URL="${BADGE_URL}&format=svg"
    EXPECTED_CT="image/svg+xml"
  ;;
  png) 
    BADGE_URL="${BADGE_URL}&format=png"
    EXPECTED_CT="image/png"
  ;;
  jpg|jpeg) 
    BADGE_URL="${BADGE_URL}&format=jpg"
    EXPECTED_CT="image/jpeg"
  ;;
  *) echo "::error::Unsupported format: ${FORMAT}"; exit 1 ;;
esac

TEMP_DIR=$(mktemp -d)
BADGE_FILE="${TEMP_DIR}/badge.${FORMAT}"
echo "Downloading badge from Shields.io..."
HTTP_CODE=$(curl -sS -w "%{http_code}" -o "${BADGE_FILE}" \
  -H "Accept: ${EXPECTED_CT}" \
  "${BADGE_URL}")

if [ "${HTTP_CODE}" -ne 200 ]; then
  echo "::error::Failed to download badge. HTTP status: ${HTTP_CODE}"
  cat "${BADGE_FILE}" 2>/dev/null || true
  exit 1
fi

if [ ! -s "${BADGE_FILE}" ]; then
  echo "::error::Downloaded badge file is empty"
  exit 1
fi

FILESIZE=$(wc -c < "${BADGE_FILE}" | tr -d ' ')
echo "Badge created successfully (${FILESIZE} bytes)"
echo "badge-file=${BADGE_FILE}" >> "$GITHUB_OUTPUT"
