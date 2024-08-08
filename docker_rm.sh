(docker container rm -f ambhtmx-artyom-container || true) \
		&& (docker rmi $(docker images --format '{{.Repository}}:{{.ID}}'| egrep 'ambhtmx-artyom-image' | cut -d':' -f2 | uniq) --force || true)