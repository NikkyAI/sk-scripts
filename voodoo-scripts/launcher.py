import os
import shutil
import subprocess
from datetime import datetime
from pathlib import Path
from urllib.parse import urljoin

import appdirs
import ruamel.yaml as yaml
import simplejson as json

from .target import Target
from .util import VoodooUtil


class Launcher:
    class __Launcher():
        def __init__(self, src,
                    build='.launcher',
                    target='.voodoo/.launcher/',
                    server=None,
                    www_root=None,
                    url_base=None,
                    **kwargs):

            cache_dir = appdirs.AppDirs(appname='voodoo-scripts', appauthor='nikky').user_cache_dir
            cache_dir = Path(cache_dir)

            src = Path(os.path.expanduser(src)).resolve()
            build = Path(os.path.expanduser(build)).resolve()

            self.src = src
            self.build = build
            self.target = target
            self.server = server
            self.www_root = www_root
            self.url_base = url_base
            self.tool_dir = Path(cache_dir, 'tools')
            self.cache_dir = Path(cache_dir, 'launcher')

        def copy(self, project, target, file_name=None):
            folder = Path(self.build, project, 'build', 'libs')
            if not file_name:
                file_name = f'{project}.jar'
            target = Path(target)
            target.mkdir(parents=True, exist_ok=True)
            target_path = Path(target, file_name).resolve()

            binary_path = list(folder.glob('*-all.jar'))[0]
            print(binary_path.name)

            
            shutil.copy(str(binary_path), str(target_path))
            return target_path

        def pack(self, project, target, file_name, json_name):
            file_path = self.copy(project, target, f'full-{file_name}')
            version = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=self.build).strip()
            pack_file = f'{file_name}.pack'
            url = urljoin(self.url_base, f'{self.target}/')
            url = urljoin(url, pack_file)
            latest_obj = dict(
                version=version,
                url=url
            )

            with open(Path(target, json_name), 'w') as fp:
                json.dump(latest_obj, fp)

            dest = Path(self.cache_dir, 'launcher', pack_file)
            VoodooUtil.run(f'pack200 --no-gzip {dest} {file_path}')

        def compile(self):
            VoodooUtil.run(f'rsync -a --delete {self.src}/ {self.build}/')

            VoodooUtil.run('./gradlew clean build', cwd=self.build)

            name = 'launcher'
            fancy = '-fancy'

            self.copy('launcher-bootstrap', self.cache_dir, f'{name}.jar')
            self.copy('launcher-bootstrap-fancy', self.cache_dir, f'{name}{fancy}.jar')

            self.copy('creator-tools', self.tool_dir)
            self.copy('launcher-builder', self.tool_dir)

            self.pack('launcher', self.cache_dir, f'{name}.jar', f'latest.json')
            self.pack('launcher-fancy', self.cache_dir, f'{name}{fancy}.jar', f'latest{fancy}.json')

        def upload(self):
            # TODO: check if launcher was built

            files = [ f for f in self.cache_dir.iterdir()]
            if len(files) < 8:
                self.compile()

            target = Path(self.www_root, self.target)
            VoodooUtil.upload(local=f'{self.cache_dir}/',
                              server=self.server,
                              target=f'{target}/',
                              delete=True)


        def get_builder(self):
            builder_path = Path(self.tool_dir, 'launcher-builder.jar')
            if not builder_path.exists():
                self.compile()
            # assuming compile creates this files
            return builder_path

        def __str__(self):
            return yaml.dump(self)

        def __repr__(self):
            return str(self)

    instance = None
    def __init__(self, config_path):
        if not Launcher.instance:
            with open(config_path) as config_file:
                config = yaml.safe_load(config_file)
            Launcher.instance = Launcher.__Launcher(**config.get('launcher', {}))
    def __getattr__(self, name):
        return getattr(self.instance, name)
