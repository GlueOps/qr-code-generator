FROM golang:1.27-alpine@sha256:fa3d596898d9f126af7c01d14ee7597bab3f39cccf392ef36b69fe77cd681f18 AS builder
WORKDIR /src
COPY . .
RUN go mod tidy

RUN go build -trimpath -ldflags="-s -w" -o /out/qr-service .

FROM gcr.io/distroless/static-debian12:nonroot@sha256:afa5c872c891853ca7fcf1f12c3edb23f7eeef36189728842dd51042ff57f7ab

WORKDIR /

COPY --from=builder /out/qr-service /qr-service

EXPOSE 8000

ENV PORT=8000

ENTRYPOINT ["/qr-service"]
