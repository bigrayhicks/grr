#!/bin/bash

# Build client templates and upload them to cloud storage.
#
# This script must be run inside travis, as it relies on some travis specific
# environment variables
#
# There is already a travis gcs deployer but it isn't usable:
# https://github.com/travis-ci/dpl/issues/476
#
# I also attempted to use the experimental script deployer but there were
# differences between the virtual env in the deploy and install stages that
# caused the install to fail.
#
# and it's also hard to debug:
# https://github.com/travis-ci/dpl/issues/477
#
# We need to use the (currently experimental) deploy script provider because
# after_success doesn't exit on error:
# https://github.com/travis-ci/travis-ci/issues/758

set -e

source ${HOME}/INSTALL/bin/activate
pip freeze

# Temporary workaround until we migrate off PackageMaker.
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
  cd /Applications
  wget -q https://storage.googleapis.com/grr-osx-buildtools/packagemaker.tar.gz
  tar zxf packagemaker.tar.gz
  cd -
fi

grr_client_build build --output built_templates

# If we don't have the sdk, go get it. While we could cache the cloud sdk
# directory it may contain authentication tokens after the authorization step
# below, so we don't.
gcloud version || ( wget -q https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-116.0.0-linux-x86_64.tar.gz && tar zxf google-cloud-sdk-116.0.0-linux-x86_64.tar.gz -C ${HOME} )

# See https://docs.travis-ci.com/user/encrypting-files/
openssl aes-256-cbc -K $encrypted_03f64f0078dc_key \
  -iv $encrypted_03f64f0078dc_iv \
  -in travis/travis_uploader_service_account.json.enc \
  -out travis/travis_uploader_service_account.json -d

gcloud auth activate-service-account --key-file travis/travis_uploader_service_account.json
echo Uploading templates to gs://autobuilds.grr-response.com/${TRAVIS_JOB_NUMBER}
gsutil -m cp built_templates/* gs://autobuilds.grr-response.com/${TRAVIS_JOB_NUMBER}/
shred -u travis/travis_uploader_service_account.json
