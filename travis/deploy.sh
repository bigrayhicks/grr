#!/bin/bash

# $Id: $

set -e

find ${HOME}/INSTALL -type f -exec md5sum {} + > ${HOME}/md5s.deploy

