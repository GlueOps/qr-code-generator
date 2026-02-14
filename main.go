package main

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"fmt"
	"log"
	"net/http"
	"net/url"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/joho/godotenv"
	qrcode "github.com/skip2/go-qrcode"
)

func main() {
	_ = godotenv.Load()
	signingSecret := os.Getenv("QR_SIGNING_SECRET")
	if signingSecret == "" {
		log.Fatal("missing env var QR_SIGNING_SECRET")
	}

	mintToken := os.Getenv("QR_MINT_TOKEN")
	if mintToken == "" {
		log.Fatal("missing env var QR_MINT_TOKEN")
	}

	mux := http.NewServeMux()
	mux.HandleFunc("/v1/qr", qrHandler([]byte(signingSecret)))

	// Mint endpoint is protected by Authorization: Bearer <QR_MINT_TOKEN>
	mux.HandleFunc("/v1/sign", requireBearer(mintToken, signHandler([]byte(signingSecret))))

	addr := "0.0.0.0:8000"
	log.Printf("listening on %s", addr)
	log.Fatal(http.ListenAndServe(addr, mux))
}

// Middleware: require Authorization: Bearer <token>
func requireBearer(token string, next http.HandlerFunc) http.HandlerFunc {
	want := "Bearer " + token

	return func(w http.ResponseWriter, r *http.Request) {
		got := r.Header.Get("Authorization")
		if got == "" {
			http.Error(w, "missing Authorization header", http.StatusUnauthorized)
			return
		}
		// constant-time compare
		if !hmac.Equal([]byte(got), []byte(want)) {
			http.Error(w, "unauthorized", http.StatusUnauthorized)
			return
		}
		next(w, r)
	}
}

// /v1/qr?u=<target>&exp=<unix>&sig=<base64url>
func qrHandler(secret []byte) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		q := r.URL.Query()

		target := q.Get("u")
		expStr := q.Get("exp")
		sig := q.Get("sig")

		if target == "" || expStr == "" || sig == "" {
			http.Error(w, "missing u, exp, or sig", http.StatusBadRequest)
			return
		}

		expUnix, err := strconv.ParseInt(expStr, 10, 64)
		if err != nil || expUnix <= 0 {
			http.Error(w, "invalid exp", http.StatusBadRequest)
			return
		}
		if time.Now().Unix() > expUnix {
			http.Error(w, "expired", http.StatusUnauthorized)
			return
		}

		if err := validateTargetURL(target); err != nil {
			http.Error(w, "invalid target url: "+err.Error(), http.StatusBadRequest)
			return
		}

		expected := sign(secret, target, expStr)
		if !secureEqual(sig, expected) {
			http.Error(w, "bad signature", http.StatusUnauthorized)
			return
		}

		png, err := qrcode.Encode(target, qrcode.Highest, 256)
		if err != nil {
			http.Error(w, "failed to generate qr", http.StatusInternalServerError)
			return
		}

		w.Header().Set("Content-Type", "image/png")
		w.Header().Set("Cache-Control", "no-store")
		_, _ = w.Write(png)
	}
}

// Protected: /v1/sign?u=<target>&ttl=<seconds>
func signHandler(secret []byte) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		q := r.URL.Query()
		target := q.Get("u")
		ttlStr := q.Get("ttl")

		if target == "" || ttlStr == "" {
			http.Error(w, "missing u or ttl", http.StatusBadRequest)
			return
		}
		ttl, err := strconv.ParseInt(ttlStr, 10, 64)
		if err != nil || ttl <= 0 || ttl > 24*3600 {
			http.Error(w, "invalid ttl (1..86400)", http.StatusBadRequest)
			return
		}

		if err := validateTargetURL(target); err != nil {
			http.Error(w, "invalid target url: "+err.Error(), http.StatusBadRequest)
			return
		}

		exp := time.Now().Add(time.Duration(ttl) * time.Second).Unix()
		expStr := strconv.FormatInt(exp, 10)
		sig := sign(secret, target, expStr)

		signedPath := fmt.Sprintf("/v1/qr?u=%s&exp=%s&sig=%s",
			url.QueryEscape(target),
			expStr,
			url.QueryEscape(sig),
		)

		w.Header().Set("Content-Type", "text/plain; charset=utf-8")
		_, _ = w.Write([]byte(signedPath))
	}
}

// base64url(HMAC_SHA256(secret, u+"\n"+exp))
func sign(secret []byte, target, exp string) string {
	mac := hmac.New(sha256.New, secret)
	mac.Write([]byte(target))
	mac.Write([]byte("\n"))
	mac.Write([]byte(exp))
	return base64.RawURLEncoding.EncodeToString(mac.Sum(nil))
}

func secureEqual(a, b string) bool {
	ab, err1 := base64.RawURLEncoding.DecodeString(a)
	bb, err2 := base64.RawURLEncoding.DecodeString(b)
	if err1 != nil || err2 != nil {
		return false
	}
	return hmac.Equal(ab, bb)
}

func validateTargetURL(raw string) error {
	u, err := url.Parse(raw)
	if err != nil {
		return err
	}
	if u.Scheme != "http" && u.Scheme != "https" {
		return fmt.Errorf("scheme must be http or https")
	}
	if u.Host == "" {
		return fmt.Errorf("missing host")
	}

	host := strings.ToLower(u.Hostname())
	if host == "localhost" {
		return fmt.Errorf("localhost not allowed")
	}
	return nil
}
