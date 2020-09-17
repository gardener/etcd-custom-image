# etcd-custom-image

[![reuse compliant](https://reuse.software/badge/reuse-compliant.svg)](https://reuse.software/)

This repository is used to produce a Docker image that contains the [etcd](https://github.com/etcd-io/etcd/) binary along with pre-installed CLI tools such as `bash`, `curl` and `wget`.

The rationale behind it is that Gardener is not only used to operate shoot and seed clusters in public clouds, but also in private restricted environments.

Since etcd v3.4 release, the etcd image has moved away from an alpine-linux based image to a debian-based base image. The new base image lacks CLI tools like `bash` and `wget` out-of-the-box, which are required for communication and coordination between the etcd container and the [backup-restore](https://github.com/gardener/etcd-backup-restore/) container that is deployed as a sidecar to etcd.

Some restricted environments forbid access to public apt repositories, which need to be contacted in order to install these additional binaries. Hence, this repository defines a CI pipeline that regularly fetches the latest [etcd release image](https://github.com/etcd-io/etcd/releases), installs the necessary additional binaries and builds a "custom etcd" Docker image from that.
