#!/usr/bin/env bash
set -e

if [[ "$BUILD_NUMBER" == "" ]]; then
  echo "Error: Missing \$BUILD_NUMBER"
  exit 1
fi

function generate_artifact {
  echo "--- :$1: Building $1/$2"

  ./scripts/build_binary.sh $1 $2 $BUILD_NUMBER
}

function generate_arm_artifact {
  echo "--- :$1: Building $1/$2"

  ./scripts/build_arm_binary.sh $1 $2 $BUILD_NUMBER
}

echo '--- :golang: Setting up $GOPATH'
export GOPATH="$GOPATH:$(pwd)/vendor"
echo $GOPATH

# Clear out the pkg directory
rm -rf pkg

generate_artifact "windows" "x86"
generate_artifact "windows" "amd64"
generate_artifact "linux" "amd64"
generate_artifact "linux" "386"
generate_artifact "darwin" "386"
generate_artifact "darwin" "amd64"
#generate_artifact "freebsd" "amd64"
#generate_artifact "freebsd" "386"

# ARM artifacts
generate_arm_artifact "linux" "ARMv5"
generate_arm_artifact "linux" "ARMv6"
generate_arm_artifact "linux" "ARMv7"
generate_arm_artifact "linux" "ARMv8"

function build() {
  echo "--- Building release for: $1"

  ./scripts/zip_artifacts.sh $1 $BUILD_NUMBER
}

# Export the function so we can use it in xargs
export -f build

# Make sure the releases directory is empty
rm -rf releases

# Loop over all the binaries and build them
ls pkg/* | xargs -I {} bash -c "build {}"
