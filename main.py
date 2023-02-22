import os
import shutil
import subprocess

LAB_SETUPS = {'1': (('idr',), 'idr'),
              '2': (('lab21','input', 'lab23', 'lab24'), 'lab24'),
              '3': (('lab3v','lab3i'), 'lab3i'),
              '3+': (('lab3p', 'avic', 'bvic'), 'lab3p'),
              '3+d': (('lab3p',), 'lab3p'),
              'rofl': (('rofl',), 'rofl')}
lab_num = input('Enter lab number >> ')
BUILD_FILES, RUN_FILE = LAB_SETUPS[lab_num]

DOSBOX_DIR = 'C:\\Program Files (x86)\\DOSBox-0.74-3\\DOSBox.exe'
HIEW_DIR = os.path.abspath("hiew") + '\\hiew32.exe'
CONFIGS_FILE_DIR = os.getenv('LOCALAPPDATA') + '\\DOSBox'
CONFIGS_FILE = os.getenv('LOCALAPPDATA') + '\\DOSBox\\dosbox-0.74-3.conf'
CONFIGS_FILE_BACKUP = os.getenv('LOCALAPPDATA') + '\\DOSBox\\dosbox-0.74-3_backup.conf'
PROJECT_DIR = os.path.abspath(".")
SOURCE_DIR = os.path.abspath("source")
TASM_DIR = os.path.abspath("tasm")
TASM_FILES = ('debug.bat',
              'DPMI16BI.OVL',
              'DPMILOAD.EXE',
              'DPMIMEM.DLL',
              'run.bat',
              'TASM.EXE',
              'TD.EXE',
              'TLINK.EXE')


class LabSetup:
    files_to_copy: tuple[str]
    files_to_build: tuple[str]
    file_to_run: str
    configs_init: list[str]


    def __init__(self,
                 files_to_copy: tuple[str],
                 files_to_build: tuple[str],
                 file_to_run: str):
        self.files_to_copy = files_to_copy
        if files_to_build is None:
            self.files_to_build = self.files_to_copy
        else:
            self.files_to_build = files_to_build
        self.file_to_run = file_to_run

    
    def restore_config_file(self):
        os.chdir(CONFIGS_FILE_DIR)
        if CONFIGS_FILE_BACKUP in os.listdir():
            with open(CONFIGS_FILE_BACKUP) as configs_backup:
                self.configs_init = configs_backup.readlines()
        with open(CONFIGS_FILE, mode='w') as configs_file:
            config_file.writelines(self.configs_init)
            

    def clear_tasm_dir():
        os.chdir(TASM_DIR)
        for file in os.listdir():
            if file not in TASM_FILES:
                os.remove(file)


    def copy_files(self):
        os.chdir(PROJECT_DIR)
        for file in self.files_to_copy:
            shutil.copy(os.path.join(SOURCE_DIR, file))


    def build_files(self):
        os.chdir(PROJECT_DIR)
        for file in self.files_to_copy:
            shutil.copy(os.path.join(SOURCE_DIR, file))


    def build_lab_files(self):
        pass


def prepare_build():
    os.chdir(PROJECT_DIR)
    for file in BUILD_FILES:
        subprocess.call('copy source\\' + file + '.asm' + ' tasm\\' + file + '.asm', shell=True,
                        stdout=subprocess.DEVNULL)
    subprocess.call('copy tasm\\' + RUN_FILE + '.asm' + ' tasm\\code.asm', shell=True, stdout=subprocess.DEVNULL)
    os.chdir(TASM_DIR)


def get_build_commands():
    build_commands = []
    for file in os.listdir("."):
        if file.endswith(".asm"):
            with open(file) as text:
                program = text.read().upper()
                filename = text.name
                # create obj
                build_commands.append('tasm ' + filename)
                filename = filename.replace('.asm', '')
                # link obj to executable file
                if 'ORG' in program:
                    build_commands.append('tlink /t ' + filename + '.obj')
                else:
                    build_commands.append('tlink ' + filename + '.obj')
    return build_commands


def clean_formats(formats):
    files = os.listdir(TASM_DIR)

    for item in files:
        if item not in TASM_FILES:
            if any(s.lower() in item.lower() for s in formats):
                os.remove(os.path.join(TASM_DIR, item))


def clean_all():
    # removes .map .obj .exe .com
    clean_formats(['.asm', '.map', '.exe', '.obj', '.com'])


def clean_non_executable():
    # removes .map .obj
    clean_formats(['.map', '.obj'])


# read initial config
try:
    config_file_init = open(CONFIGS_FILE + '_copy.conf', mode='r')
except Exception as e:
    config_file_init = open(CONFIGS_FILE + '_copy.conf', mode='w')
    with open(CONFIGS_FILE, mode='r') as configs_file:
        config_file_init.writelines(configs_file.readlines())
    config_file_init.close()
    config_file_init = open(CONFIGS_FILE + '_copy.conf', mode='r')
config_init = config_file_init.readlines()
config_file_init.close()

# define commands for DOSBOX
start_commands = ['mount D "' + TASM_DIR + '"',
                  'D:']
commands = {'r': ['code'],
            'd': ['td code']}
end_commands = []

run_args = ['r', 'd', 'h']

args = str(input(
    'DOSBOX TASM starter v. 0.1\n' +
    'Chosen file for running: ' + RUN_FILE + ', build files: ' + ', '.join(BUILD_FILES) + '\n' +
    'r - run\n' +
    'd - debug\n' +
    'h - hiew for running program\n' +
    'q - exit with clean\n' +
    'type your run configuration:\n'))

while args != 'q':
    prepare_build()
    config = config_init.copy()

    for command in start_commands:
        config.append(command + '\n')
    for command in get_build_commands():
        config.append(command + '\n')

    for argument in args:
        try:
            for command in commands[argument]:
                config.append(command + '\n')
        except:
            print('Unexpected abbr\n')
            break

    for command in end_commands:
        config.append(command + '\n')

    with open(CONFIGS_FILE, mode='w') as config_file:
        config_file.writelines(config)

    clean_non_executable()
    process = subprocess.Popen(DOSBOX_DIR)
    #if args == 'h':
      #  subprocess.call([HIEW_DIR])

    args = input()
    while args.strip() == '':
        args = input()
    process.kill()

with open(CONFIGS_FILE, mode='w') as config_file:
    config_file.writelines(config_init)

clean_all()
os.remove(CONFIGS_FILE + '_copy.conf')
