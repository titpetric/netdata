#!/bin/bash
if [ ! -f "update-releases.json" ]; then
	curl -s https://api.github.com/repos/firehol/netdata/tags > update-releases.json
fi
cat update-releases.json | jq -r ".[].name" | egrep 'v[1-9].+[0-9]$' | xargs -n1 -I{} echo mkdir releases/{} \; ln -s ../latest/Dockerfile releases/{}/Dockerfile \; echo {} \> releases/{}/git-tag | sh -x