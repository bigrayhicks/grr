#!/bin/bash

# $Id: $

set -e
set -x

source ${HOME}/INSTALL/bin/activate
pip install --upgrade pip wheel setuptools
pip install -e .
pip install -e grr/config/grr-response-test/
if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then
  pip install -e grr/config/grr-response-server/
fi
pip install -e grr/config/grr-response-client/

python makefile.py
cd grr/artifacts && python makefile.py && cd -



