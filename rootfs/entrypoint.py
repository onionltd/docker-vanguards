#!/usr/bin/env python3

import ipaddress
import socket

from os import environ
from os import execvp
from sys import argv

config = {
  "GLOBAL": {},
  "VANGUARDS": {},
  "BANDGUARDS": {},
  "RENDGUARDS": {},
}

def match_config_section(varname):
  sections = config.keys()
  for section in sections:
    if varname.startswith(section + "_"):
      return section
  return None

def to_config_string(config):
  result = ""
  for section in config:
    result += "[{}]\n\n".format(section.capitalize())
    for var in config[section]:
      result += "{} = {}\n".format(var, config[section][var])
  return result

def resolve_hostname(hostname):
  try:
    _ = ipaddress.ip_address(hostname)
  except ValueError:
    try:
      addr = socket.getaddrinfo(hostname, None, socket.AF_INET, socket.SOCK_STREAM, socket.IPPROTO_TCP)
      return addr[0][4][0]
    except socket.gaierror:
      return None
  return hostname

def main():
  if "CONFIG_FILE" not in environ:
    raise Exception("CONFIG_FILE not defined")

  if "GLOBAL_CONTROL_IP" in environ:
    address = resolve_hostname(environ["GLOBAL_CONTROL_IP"])
    if address is None:
      raise Exception("GLOBAL_CONTROL_IP failed to resolve hostname")
    environ["GLOBAL_CONTROL_IP"] = address

  for var in environ:
    section = match_config_section(var)

    if section == None:
      continue

    config[section][var.replace(section + "_", "").lower()] = environ[var]

  with open(environ["CONFIG_FILE"], 'w') as fd:
    fd.write(to_config_string(config))

  if len(argv) > 1:
    execvp(argv[1], argv[1:])

if __name__ == "__main__":
  main()
