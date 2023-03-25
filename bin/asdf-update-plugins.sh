#!/bin/bash
# Run this periodically and commit the updated ~/.tool-versions file.
for tool in $(asdf plugin list); do
  asdf install "${tool}" latest  \
    &&  asdf global "${tool}" latest  \
    &&  echo "${tool} set globally"
done
