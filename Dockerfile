FROM golang:1.26-alpine@sha256:91eda9776261207ea25fd06b5b7fed8d397dd2c0a283e77f2ab6e91bfa71079d AS builder
WORKDIR /src
COPY . .
RUN go mod tidy

RUN go build -trimpath -ldflags="-s -w" -o /out/qr-service .

FROM gcr.io/distroless/static-debian12:nonroot@sha256:a9329520abc449e3b14d5bc3a6ffae065bdde0f02667fa10880c49b35c109fd1

WORKDIR /

COPY --from=builder /out/qr-service /qr-service

EXPOSE 8000

ENV PORT=8000

ENTRYPOINT ["/qr-service"]
