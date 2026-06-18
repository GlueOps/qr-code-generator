FROM golang:1.26-alpine@sha256:f1ddd9fe14fffc091dd98cb4bfa999f32c5fc77d2f2305ea9f0e2595c5437c14 AS builder
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
