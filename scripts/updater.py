#!/bin/python3
# -*- coding: utf-8 -*-

import subprocess
from time import sleep

ls_output=subprocess.Popen(["ls", "-a"], shell=True)
print('done')

sleep(3)

print(ls_output)