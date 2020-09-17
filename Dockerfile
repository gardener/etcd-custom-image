# SPDX-FileCopyrightText: 2020 SAP SE or an SAP affiliate company and Gardener contributors
# SPDX-License-Identifier: Apache-2.0

ARG VERSION=3.4.11
FROM gcr.io/etcd-development/etcd:v$VERSION

RUN apt update
RUN apt install -y bash curl wget

WORKDIR /
ENTRYPOINT ["/usr/local/bin/etcd"]
