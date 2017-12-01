import shlex
import subprocess
import io


class VoodooUtil:

    __RSYNC_COMMAND = 'rsync -av {UPDATE} {DELETE} \'{LOCAL}\' \'{SERVER}:{TARGET}\''

    @staticmethod
    def run(command, cwd=None):
        args = shlex.split(command)
        print(args)
        p = subprocess.Popen(args, cwd=cwd)
        p.wait()
        # with subprocess.Popen(args, stdout=subprocess.PIPE, cwd=cwd) as proc:
        #     for line in io.TextIOWrapper(proc.stdout, encoding="utf-8"):
        #         print(line, end='')

    @classmethod
    def upload(cls, local, server, target, command=__RSYNC_COMMAND, delete=False, update=False):
        # delete files that do not exist on target
        delete = '--delete' if delete else ''
        update = '--update' if update else ''  # skip files on target that are newer
        cls.run(
            command.format(
                UPDATE=update,
                DELETE=delete,
                LOCAL=local,
                SERVER=server,
                TARGET=target,
            )
        )
