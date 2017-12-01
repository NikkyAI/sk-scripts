from enum import Enum

class Target(Enum):
    Modpack = 1
    Server = 2
    Launcher = 3

    @staticmethod
    def get(v):
        if isinstance(v, Target):
            return v
        if isinstance(v, str):
            try:
                return [t for t in Target if t.name.lower() == v.lower()][0]
            except IndexError:
                return None

    def __lt__(self, other: 'Target'):
        return self.value < other.value

    def __str__(self):
        return self.name

    def __repr__(self):
        return str(self)