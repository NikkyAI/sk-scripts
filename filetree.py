#!/bin/python3
# -*- coding: utf-8 -*-

import argparse

import subprocess
from bs4 import *
import re
from urllib.parse import unquote
import os
from subprocess import check_output

parser = argparse.ArgumentParser(description="Download mods from curseforge and other sources")
parser.add_argument("--dir", help="dir")
parser.add_argument("--out", help="output file")
parser.add_argument("--pack", help="pack name")
args, unknown = parser.parse_known_args()

print(check_output(['pwd']))

html = check_output(['tree', 'modpacks/{args.pack}/src'.format(**locals()),
                     '-T', 'Directory Listing', # '-P', 'mods|mods/*.*|mods/*', '--matchdirs',
                     '-I', 'ambience_music|config|loaders|*.url.txt|*.info.json',
                     '--sort=name',
                     '--noreport', '--dirsfirst',
                     '-H', 'https://nikky.moe/mc/modpacks/{args.pack}/src'.format(**locals())
                      ])

print(html)

pattern = r'https://nikky.moe/mc/modpacks/{args.pack}/src/(?P<mod>.+)'.format(**locals())

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
            path = unquote('modpacks/{}/src/{}.url.txt'.format(args.pack, mod))
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

