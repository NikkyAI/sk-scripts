import os
from datetime import datetime
from pathlib import Path

import ruamel.yaml as yaml

import appdirs
import simplejson as json

from .target import Target
from .launcher import Launcher
from .util import VoodooUtil


class MetaCls(type):
    def __getitem__(cls, index):
        if not isinstance(index, str):
            index = str(index)
        modpack = cls._MODPACKS.get(index)
        if not modpack:
            modpack = Modpack(name=index)
        return modpack


class Modpack(metaclass=MetaCls):
    _MODPACKS = {}
    __CACHE_DIR = appdirs.AppDirs(appname='voodoo-scripts', appauthor='nikky').user_cache_dir

    @classmethod
    def init(cls, config_path):
        cls.config_path = config_path
        with open(config_path) as config_file:
            config = yaml.safe_load(config_file)
        modpacks = {}
        modpack_default = config.get('modpack_default', {})
        config = config.get('modpacks', {})
        for packname, settings in config.items():
            print(settings)
            modpacks[packname] = Modpack(name=packname, **settings)
        cls._MODPACKS = modpacks
        cls.__DEFAULT_CONFIG = modpack_default

    @classmethod
    def list(cls):
        return list(cls._MODPACKS.keys())

    @classmethod
    def items(cls):
        return list(cls._MODPACKS.items())

    # def __getitem__(self, index):
    #     if not isinstance(index, str):
    #         indices = str(index)
    #     modpack = clz.__MODPACKS.get(index)
    #     if not modpack:
    #         modpack = Modpack(name=index, **clz.__DEFAULT_CONFIG)

    def __init__(self, name,
                 base_folder='modpacks',
                 folder=None,
                 target='~/.cache/voodoo-pack/{name}/',
                 server=None,
                 run_dir='~/minecraft/server/{name}/',
                 www_root=None,
                 url_base=None,
                 **kwargs):
        if not folder:
            folder = name

        if run_dir:
            run_dir = run_dir.format(**locals(), **kwargs)
        
        target = target.format(**locals(), **kwargs)

        base_folder = Path(os.path.expanduser(base_folder)).resolve()

        self.name = name
        self.base_folder = base_folder
        self.folder = folder
        self.server = server
        self.run_dir = run_dir
        self.target = target
        self.www_root = www_root
        self.url_base = url_base

    def __str__(self):
        return yaml.dump(self)

    def __repr__(self):
        return str(self)
    
    @classmethod
    def packages(cls, packs=None):
        cache_path = Path(cls.__CACHE_DIR, 'modpacks').resolve()

        if not packs:
            packs = cls.list()

        minimum_version = 1
        packages = []
        for pack in packs:
            location = f'{pack}.json'
            package_path = Path(cache_path, location)

            if not package_path.exists():
                continue

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

        packages_path = Path(cache_path, 'packages.json')
        with open(packages_path, 'w') as packages_file:
            json.dump(packages_data, packages_file, indent=4 * ' ')


    def compile(self, target):
        if target == Target.Modpack:
            return self.compile_modpack()
        if target == Target.Server:
            return self.compile_server()

    def compile_modpack(self):
        # TODO: check if pack-builder is available
        launcher = Launcher(self.config_path)
        builder_path = launcher.get_builder()

        # TODO: make 'modpacks' a config option
        input_path = Path(Path('modpacks', self.folder).resolve())
        if not input_path.exists():
            print(f'cannot find {input_path}')
            print(f'not building {self.name}')
            return True
        dt = datetime.now()
        version=f'{self.name}-{dt:%Y.%m.%d.%H%M%S}' #TODO: move into config

        cache_path = Path(self.__CACHE_DIR, 'modpacks').resolve()
        manifest_dest = Path(cache_path, f'{self.name}.json')
        VoodooUtil.run(command=f'java -jar {builder_path} \
        --version {version} \
        --input {input_path} \
        --output {cache_path} \
        --manifest-dest {manifest_dest}'
        )

        self.packages()

        print()

    def compile_server(self):
        # TODO: check if pack-builder is available
        launcher = Launcher(self.config_path)
        builder_path = launcher.get_builder()

        # TODO: call java packcompileer
        src = Path('modpacks', self.folder, 'src')
        if not src.exists():
            print(f'cannot find {src}')
            print(f'not building {self.name}')
            return True

        cache_path = Path(self.__CACHE_DIR, 'server', self.name)
        VoodooUtil.run(command=f'java -cp {builder_path} com.skcraft.launcher.builder.ServerCopyExport \
            --source {src} \
            --dest {cache_path}'
        )
        print()

    def upload(self, target: Target):
        if target == Target.Modpack:
            self.upload_modpack()
        if target == Target.Server:
            self.upload_server()

    def upload_modpack(self):
        cache_path = Path(self.__CACHE_DIR, 'modpacks').resolve()
        if not Path(cache_path, f'{self.name}.json').exists():
            self.compile_modpack()

        target = Path(self.www_root, self.target)

        VoodooUtil.upload(local=f'{cache_path}/', 
                          server=self.server,
                          target=f'{target}/')

    def upload_server(self):
        # TODO: check if server is built

        # upload pack into cache target
        # upload script into run_dir

        VoodooUtil.upload(local='.server', server='nikky@nikky.moe',
                          target=f'~/.cache/voodoo-pack/{self.name}/', delete=True)
