#!/bin/python3
# -*- coding: utf-8 -*-

import cmd
import warnings

import ruamel.yaml as yaml
from ruamel.yaml.error import ReusedAnchorWarning

from .launcher import Launcher
from .modpack import Modpack
from .target import Target

warnings.simplefilter("ignore", ReusedAnchorWarning)


class Script(cmd.Cmd):
    """Simple command processor example."""
    
    launcher = Launcher('config.yaml')

    def preloop(self):
        with open('config.yaml') as config_file:
            self.config = yaml.safe_load(config_file)

        Modpack.init('config.yaml')

    def do_list(self, line):
        """list modpacks"""
        for name, pack in Modpack.items():
            print(name)
            print(pack)

    def do_compile(self, line):
        'compile TARGET PACK...'
        target = Target.get(line)
        if target == Target.Launcher:
            self.launcher.compile()
            return

        if ' ' not in line:
            targetname = line
            modpacks = Modpack.list()
        else:
            targetname, modpacks = line.split(' ', 1)
            modpacks = modpacks.split(' ')
        
        target = Target.get(targetname)
        if not target:
            print(f'unknown target {targetname}')
            return
        else:
            for packname in modpacks:
                modpack = Modpack[packname]
                modpack.compile(target)

    def complete_compile(self, text, line, begidx, endidx):
        return self.__completehelper(text, line)

    def do_upload(self, line):
        'upload TARGET PACK...'
        target = Target.get(line)
        if target == Target.Launcher:
            self.launcher.upload()
            return

        if ' ' not in line:
            targetname = line
            modpacks = Modpack.list()
        else:
            targetname, modpacks = line.split(' ', 1)
            modpacks = modpacks.split(' ')
        
        target = Target.get(targetname)
        if not target:
            print(f'unknown target {targetname}')
            return
        if target == Target.Launcher:
            self.launcher.upload()
        else:
            for packname in modpacks:
                modpack = Modpack[packname]
                modpack.upload(target)

    def complete_upload(self, text, line, begidx, endidx):
        return self.__completehelper(text, line)

    def __completehelper(self, text, line):
        line = line.split(' ', 1)[1]
        if ' ' in line:
            target, packs = line.split(' ', 1)
            if target == 'launcher':
                return []
            keys = Modpack.list()
            keys = [k for k in keys if k.startswith(text) and k not in packs]
            return keys
        else:
            actions = ['all', 'server', 'launcher', 'modpack']
            actions = [a for a in actions if a.startswith(text)]
            return actions

    def do_test(self, modpacks):
        modpacks = modpacks.split(' ')
        for packname in modpacks:
            modpack = Modpack[packname]
            print(modpack)

    def do_EOF(self, line):
        return True
    
    # def completedefault(self, text, line, begidx, endidx):
    #     keys = Modpack.list()
    #     keys = [k for k in keys if k.startswith(text)]
    #     return keys

    def emptyline(self):
        print(f'empty input')
        self.do_help('')

    def postcmd(self, stop, line):
        command = line.split(' ', 1)[0]
        print()
        print(f'{command} finished')
        return stop

    def postloop(self):
        print()



def main():
    Script().cmdloop(intro='Voodo magic starting up')
