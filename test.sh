#!/usr/bin/env bash

for test in `find BobboBot/ -name '*.t' | sort`; do
  ret="$(perl $test)";
  if [[ $? == 0 ]]; then
    echo "$test -- OK";
  else
    echo "$test -- NOT OK ($?)";
    echo "$ret";
  fi
done
