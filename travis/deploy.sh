#!/bin/bash

# $Id: $

set -e

find ${HOME}/INSTALL -type f -exec md5sum {} + > ${HOME}/md5s.deploy
cd ${HOME}
diff md5s.install md5s.deploy

