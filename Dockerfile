FROM golang:1.23-alpine AS builder
WORKDIR /src
COPY . .
COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -ldflags="-s -w" -o /out/qr-service .

FROM gcr.io/distroless/static-debian12:nonroot

WORKDIR /

COPY --from=builder /out/qr-service /qr-service

EXPOSE 8000

ENV PORT=8000

ENTRYPOINT ["/qr-service"]
