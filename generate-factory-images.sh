#!/bin/bash
source device/common/clear-factory-images-variables.sh
DEVICE=$1
PRODUCT=$2
BUILD=$3
BOOTLOADERSRC=$4
BOOTLOADER=$5
SRCPREFIX=$6
VERSION=$BUILD_ID
source device/common/generate-factory-images-common.sh
