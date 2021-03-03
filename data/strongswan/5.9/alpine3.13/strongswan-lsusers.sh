#!/bin/bash
  grep -v '^#' /etc/ipsec.secrets | cut -d '"' -f1 | cut -d '.' -f3
  