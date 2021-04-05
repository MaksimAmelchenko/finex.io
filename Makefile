build:
	docker build . -t finex.io/app/frontend

release: build
	docker tag finex.io/app/frontend:latest registry.gitlab.com/finex.io/app/frontend:latest

publish: release
	docker push registry.gitlab.com/finex.io/app/frontend:latest
