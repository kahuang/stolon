# base build image
FROM golang:1.14-buster AS build_base

WORKDIR /stolon

# only copy go.mod and go.sum
COPY go.mod .
COPY go.sum .

RUN go mod download

#######
####### Build the stolon binaries
#######
FROM build_base AS builder

# copy all the sources
COPY . .

RUN make

#######
####### Build the final image
#######
FROM postgres:12.3

RUN apt-get update; apt-get install ca-certificates -y

RUN useradd -ms /bin/bash stolon

EXPOSE 5432

# copy the agola-web dist
COPY --from=builder /stolon/bin/ /usr/local/bin
COPY --from=builder /stolon/wal-g /usr/local/bin

RUN chmod +x /usr/local/bin/stolon-keeper /usr/local/bin/stolon-sentinel /usr/local/bin/stolon-proxy /usr/local/bin/stolonctl /usr/local/bin/wal-g
