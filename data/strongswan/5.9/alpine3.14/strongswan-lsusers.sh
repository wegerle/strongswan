#!/bin/bash
  grep -v '^#' /etc/ipsec.secrets | cut -d ':' -f1
  