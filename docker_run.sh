
mkdir -p $(pwd)/output
mkdir -p /run/secrets
echo $GITHUB_PAT /run/secrets/GITHUB_PAT
(docker build -f Dockerfile -t ambhtmx-artyom-image . || true) \
		&& docker run --env-file=.Renviron -p 7860:7860 --name ambhtmx-artyom-container \
		-v $(pwd)/output:/workspace/output/:rw \
		--rm ambhtmx-artyom-image