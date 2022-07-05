# SPDX-FileCopyrightText: 2020 SAP SE or an SAP affiliate company and Gardener contributors
# SPDX-License-Identifier: Apache-2.0

FROM gcr.io/etcd-development/etcd:v3.4.18 as source-amd64
FROM gcr.io/etcd-development/etcd:v3.4.18-arm64 as source-arm64
FROM source-$TARGETARCH as source

RUN apt update
RUN apt install -y bash curl wget

WORKDIR /
COPY etcd_bootstrap_script.sh /var/etcd/bin/bootstrap.sh
ENTRYPOINT ["/usr/local/bin/etcd"]
