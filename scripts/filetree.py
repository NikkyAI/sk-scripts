#!/bin/python3
# -*- coding: utf-8 -*-

import argparse

import subprocess
from bs4 import *
import re
from urllib.parse import unquote
import os
from subprocess import check_output

parser = argparse.ArgumentParser(description="patch output of tree to use the correct urls")
parser.add_argument("--out", help="output file")
parser.add_argument("--root", help="root folder")
parser.add_argument("--pack", help="pack name")
parser.add_argument("--url", help="base url")
args, unknown = parser.parse_known_args()

print(check_output(['pwd']))

arguments = ['tree', f'{args.root}/{args.pack}/src',
                     '-T', 'Directory Listing', # '-P', 'mods|mods/*.*|mods/*', '--matchdirs',
                     '-I', 'ambience_music|default_config|config|loaders|*.url.txt|*.info.json',
                     '--sort=name',
                     '--noreport', '--dirsfirst',
                     '-H', f'{args.url}modpacks/{args.pack}/src'
                      ]
print(" ".join(arguments))

html = check_output(['tree', f'{args.root}/{args.pack}/src',
                     '-T', 'Directory Listing', # '-P', 'mods|mods/*.*|mods/*', '--matchdirs',
                     '-I', 'ambience_music|default_config|config|loaders|*.url.txt|*.info.json',
                     '--sort=name',
                     '--noreport', '--dirsfirst',
                     '-H', f'{args.url}modpacks/{args.pack}/src'
                      ])

print(html)

pattern = rf'{args.url}modpacks/{args.pack}/src/(?P<mod>.+)'

soup = BeautifulSoup(html)
for anchor in soup.find_all('a', href=True):
    print(anchor)
    url = anchor['href']
    text = anchor.contents[0]
    if url.endswith('_CLIENT/'):
        anchor.replaceWith('CLIENT')
    elif url.endswith('_SERVER/'):
        anchor.replaceWith('SERVER')
    elif url.endswith('/'):
        anchor.replaceWith(text)
    else:
        match = re.match(pattern, url)
        if match:
            mod = match.group('mod')
            path = unquote(f'modpacks/{args.pack}/src/{mod}.url.txt')
            if os.path.isfile(path):
                url_txt = open(path, 'r').read()
                anchor['href'] = url_txt
            else:
                anchor.replaceWith(text)
        else:
            anchor.replaceWith(text)

for div in soup.find_all("p", {'class':'VERSION'}):
    div.decompose()

html = str(soup)
print(html)
with open(args.out, "w") as file:
    file.write(html)

