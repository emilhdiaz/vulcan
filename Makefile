
build: require-version build-deb build-docker

push: require-version push-deb push-docker

build-docker: require-version
	DOCKER_BUILDKIT=1 docker build -t emilhdiaz/vulcan:$(VERSION) .

build-deb: require-version
	fpm -s dir -t deb \
	--name vulcan \
	--version $(VERSION) \
	--url "https://github.com/emilhdiaz/vulcan" \
	--maintainer "Emil Diaz <emil.h.diaz@gmail.com>" \
	--license MIT \
	--prefix /usr \
	--force \
	--post-install ./libexec/vulcan/post-install.sh \
	--depends coreutils \
	--depends curl \
	--depends jq \
	--depends git \
	--depends zsh \
	.

push-docker: require-version build-docker
	docker push emilhdiaz/vulcan:$(VERSION)

push-deb: require-version build-deb
	fury push --public vulcan_$(VERSION)_amd64.deb

clean:
	rm vulcan_*.deb

require-version:
ifndef VERSION
	$(error VERSION is undefined)
endif

