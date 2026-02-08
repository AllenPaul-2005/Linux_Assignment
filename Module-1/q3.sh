#!/bin/bash
mkdir -p dir1 dir2
touch dir1/dir2/original_file
ln -s dir1/dir2/original_file dir1/softlink_file
