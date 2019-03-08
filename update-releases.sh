#!/bin/bash
#
# It should go without saying, this script is for development/deployment purposes
# only. If a new tag is added into `netdata/netdata`, this creates the corresponding
# directory (symlink) structure. Most likely, it should be deleted because the build
# steps for netdata have and will change over time. What is symlinked today, will
# not be accurate in the future, as the Dockerfiles are currently maintained only
# for the master branch. Results may vary.
#
# And of course, there's the small issue to add individual tags manually to Docker Hub.
#
rm update-releases.json
if [ ! -f "update-releases.json" ]; then
	curl -s https://api.github.com/repos/netdata/netdata/tags > update-releases.json
fi
TAGS=$(cat update-releases.json | jq -r ".[].name" | grep -v 'rc')
for TAG in $TAGS; do
	if [ -d "releases/$TAG" ]; then
		# tags are sorted, don't create older than the latest created tag
		echo "Done, latest tags are up to date"
		exit
	fi

	TAG=${TAG/v/}
	if [ -d ".git/refs/tags/$TAG" ]; then
		# tags are sorted, don't create older than the latest created tag
		echo "Done, latest tags are up to date"
		exit
	fi


	echo "Creating tag: $TAG"
	git tag $TAG
done
