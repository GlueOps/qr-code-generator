# Signed QR Service (Go)

A tiny Go HTTP service that **mints signed, expiring QR codes** for approved target URLs.

It exposes two endpoints:

- `GET /v1/sign` — **protected** “mint” endpoint that creates a signed, expiring QR request URL
- `GET /v1/qr` — **public** endpoint that validates the signature + expiration and returns a **PNG QR code**

## Why

QR codes are easy to copy and reuse. This service lets you generate QR codes that:

- expire after a configurable TTL
- can only be minted by callers with a bearer token
- only encode valid `http/https` URLs (and rejects `localhost`)

## How it works

Signature format:

```
sig = base64url( HMAC-SHA256(secret, u + "\n" + exp) )
```


The QR endpoint requires:

- `u`   = target URL to encode
- `exp` = unix timestamp (seconds) when the request expires
- `sig` = HMAC signature over `u` and `exp`

If the signature is valid and `exp` is in the future, the service returns a 256×256 PNG QR code encoding the **target URL**.

## Requirements

- Go 1.20+ (likely works on earlier 1.x versions too)
- Environment variables:
    - `QR_SIGNING_SECRET` — secret key used for HMAC signing
    - `QR_MINT_TOKEN` — bearer token required to call `/v1/sign`

Dependencies used:
- `github.com/joho/godotenv` (optional `.env` loading)
- `github.com/skip2/go-qrcode` (PNG QR code generation)

## Setup

### 1) Clone & install

```bash
go mod init github.com/glueops/qr-code-generator
go get github.com/joho/godotenv
go get github.com/skip2/go-qrcode
go run .
```

### 2) Configure environment
Create a .env file (or export env vars):
```bash
echo "QR_SIGNING_SECRET=$(openssl rand -hex 32)" > .env
echo "QR_MINT_TOKEN=$(openssl rand -hex 16)" >> .env
```

Then start the server:
```bash
go run .
```

The service listens on:

- 0.0.0.0:8000

## API
### GET /v1/sign (protected)

Mint a signed QR request path.

#### Auth

- Authorization: Bearer <QR_MINT_TOKEN>

#### Query params

- u (string, required): target URL to encode (must be http or https, not localhost)
- ttl (int, required): time-to-live in seconds (1..86400)

#### Response

- 200 text/plain: a relative path like:
```text
/v1/qr?u=<escaped>&exp=<unix>&sig=<base64url>
```

#### Example

```bash
curl -s \
    - H "Authorization: Bearer $QR_MINT_TOKEN" \
    "http://localhost:8000/v1/sign?u=https://example.com&ttl=300"
```

### GET /v1/qr (public)
Return a PNG QR code after validating signature + expiration.

#### Query params
- u (string, required): target URL to encode
- exp (int, required): unix timestamp when the request expires
- sig (string, required): base64url HMAC signature

#### Response
- 200 image/png: PNG QR code encoding the target URL (256×256)
- 401: expired or bad signature
- 400: missing/invalid params or invalid target URL

#### Example
First mint a signed path:
```bash
SIGNED_PATH=$(
  curl -s \
    -H "Authorization: Bearer $QR_MINT_TOKEN" \
    "http://localhost:8000/v1/sign?u=https://example.com&ttl=300"
)
echo "$SIGNED_PATH"
```
Then fetch the QR image:
```bash
curl -s "http://localhost:8000$SIGNED_PATH" -o qr.png
open qr.png  # macOS; use your OS viewer
```

### Validation rules for u

The target URL must:
- parse successfully
- use scheme http or https
- include a host
- not have hostname localhost

(Other private/internal hostnames are not blocked by default—see “Hardening” below.)

### Security notes
- /v1/sign is protected via a constant-time compare of the Authorization header.
- /v1/qr uses constant-time comparison on decoded HMAC bytes.
- Responses for QR images include Cache-Control: no-store.

### Project layout

Currently everything lives in main.go.

