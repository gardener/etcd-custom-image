# SPDX-FileCopyrightText: 2020 SAP SE or an SAP affiliate company and Gardener contributors
# SPDX-License-Identifier: Apache-2.0

FROM gcr.io/etcd-development/etcd:v3.4.13 as source-amd64
FROM gcr.io/etcd-development/etcd:v3.4.13-arm64 as source-arm64

FROM source-$TARGETARCH as source

FROM alpine:3.18.2

WORKDIR /

RUN apk add --update bash curl wget openssl

COPY --from=source /usr/local/bin/etcd /usr/local/bin
COPY --from=source /usr/local/bin/etcdctl /usr/local/bin
COPY etcd_bootstrap_script.sh /var/etcd/bin/bootstrap.sh

ENTRYPOINT ["/usr/local/bin/etcd"]
