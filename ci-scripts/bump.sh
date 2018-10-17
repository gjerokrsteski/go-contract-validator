#!/usr/bin/env bash

usage_info="It accepts following mutually exclusive arguments:\n
major - version bump equal to +1.0.0\n
minor - version bump equal to +0.1.0\n
patch - version bump equal to +0.0.1\n"

if [[ -z "$1" ]]; then
    echo "BUMP is a semantic versioning bump script."
    echo -e "Please refer to http://semver.org/ for a definition of semantic versioning.\n"
    echo -e "${usage_info}"
    echo -e "Please provide which part to bump as the first argument \n"
    echo "Like: ./bump.sh minor"
    exit 2
fi

# declare what can be bumped
declare -A version_types
version_types=( ["major"]=0 ["minor"]=1 ["patch"]=2)

# validate the given argument if is not expected
if [[ -z  "${version_types[$1]+x}" ]]; then
  echo -e "Argument '$1' is invalid! \n"
  echo -e "${usage_info}"
  exit 2
fi

# create VERSION file if it does not exist
touch VERSION

# explode version from VERSION file into array
old_version=$(cat VERSION)
IFS='.' read -r -a parts <<< "${old_version}"

# increment relevant version part
bumped=$((parts[version_types[$1]]+1))
parts[version_types[$1]]=${bumped}

# reset relevant version parts
if [[ "$1" == "major" ]]; then
  parts[1]="0"
  parts[2]="0"
elif [[ "$1" == "minor" ]]; then
  parts[2]="0"
fi

# write new version to VERSION file
new_version=$((parts[0])).$((parts[1])).$((parts[2]))
echo ${new_version} > VERSION
echo "bumped $old_version to $new_version"
