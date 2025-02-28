#!/usr/bin/env bash

test_doil_check_sudo() {
  source ./src/lib/include/checks.sh
  doil_check_sudo
  local CHECK=$?
  assert_string_contains "255" "${CHECK}"
}

test_doil_check_host() {
  source ./src/lib/include/checks.sh

  doil_check_host
  local CHECK=$?

  assert_string_contains "0" "${CHECK}"
}

test_doil_check_docker_version() {
  source ./src/lib/include/checks.sh

  doil_check_docker_version
  local CHECK=$?

  assert_string_contains "0" "${CHECK}"
}