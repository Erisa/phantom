# Build container
ARG GOVERSION=1.16.0
FROM --platform=${BUILDPLATFORM} \
    golang:$GOVERSION-alpine AS build

ARG TARGETOS
ARG TARGETARCH

ENV GO111MODULE=on \
    CGO_ENABLED=0

COPY . /src
WORKDIR /src
RUN cd cmd && GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build phantom.go

# Runtime container
FROM scratch
WORKDIR /

COPY --from=build /src/cmd/phantom .
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

ENV TUNNEL_ORIGIN_CERT=/etc/cloudflared/cert.pem
ENTRYPOINT ["/phantom"]
CMD ["--help"]
