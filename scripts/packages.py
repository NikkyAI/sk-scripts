#!/bin/python3
# -*- coding: utf-8 -*-

import argparse

from pathlib import Path
import simplejson as json
from pprint import pprint

parser = argparse.ArgumentParser(
    description="creates packages.json")
parser.add_argument('packs', nargs='*', default=[], help='packs')
parser.add_argument("--dir", help="dir")
args, unknown = parser.parse_known_args()

minimum_version = 1
packages = []
for pack in args.packs:
    location = f'{pack}.json'
    package_path = Path(args.dir, location)
    with open(package_path, 'r') as package_file:
        data = json.load(package_file)

    package_entry = dict(
        name=data.get('name'),
        title=data.get('title'),
        version=data.get('version').lstrip(f'{pack}-'),
        location=location,
        priority=0
    )
    packages.append(package_entry)

packages_data = dict(
    minimumVersion=minimum_version,
    packages=packages,
)

# pprint(packages_data)

packages_path = Path(args.dir, 'packages.json')
with open(packages_path, 'w') as packages_file:
    json.dump(packages_data, packages_file, indent=4 * ' ')
