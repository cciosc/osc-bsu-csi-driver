FROM golang:1.14.1-stretch as builder

ARG DEBUG_IMAGE="disable"

RUN apt-get -y update && \
	apt-get -y --no-install-recommends install ca-certificates=20161130+nmu1+deb9u1 \
										e2fsprogs=1.43.4-2+deb9u1 \
										xfsprogs=4.9.0+nmu1 \
										util-linux=2.29.2-1+deb9u1 && \
	if [ "${DEBUG_IMAGE}" = "enable" ]; then \
	 	apt-get -y --no-install-recommends install gdb=7.12-6 jq=1.5+dfsg-1.3; \
		echo "add-auto-load-safe-path /usr/local/go/src/runtime/runtime-gdb.py" >> /root/.gdbinit; \
	fi && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

WORKDIR /go/src/github.com/kubernetes-sigs/aws-ebs-csi-driver
COPY go.mod .
COPY go.sum .
RUN go mod download -x

COPY . .
RUN make -j 4  && \
    cp /go/src/github.com/kubernetes-sigs/aws-ebs-csi-driver/bin/aws-ebs-csi-driver /bin/aws-ebs-csi-driver && \
    rm -rf /go/pkg/*

ENTRYPOINT ["/bin/aws-ebs-csi-driver"]

