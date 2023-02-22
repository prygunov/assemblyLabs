import os
import shutil
import subprocess

LAB_SETUPS = {'1': (('idr',), 'idr'),
              '2': (('lab21','input', 'lab23', 'lab24'), 'lab24'),
              '3': (('lab3v','lab3i'), 'lab3i'),
              '3+': (('lab3p', 'avic', 'bvic'), 'lab3p'),
              '3+d': (('lab3p',), 'lab3p'),
              'rofl': (('rofl',), 'rofl')}

DOSBOX_DIR = 'C:\\Program Files (x86)\\DOSBox-0.74-3\\DOSBox.exe'
HIEW_DIR = os.path.abspath("hiew") + '\\hiew32.exe'
CONFIGS_FILE_DIR = os.getenv('LOCALAPPDATA') + '\\DOSBox'
CONFIGS_FILE = os.getenv('LOCALAPPDATA') + '\\DOSBox\\dosbox-0.74-3.conf'
CONFIGS_FILE_BACKUP = os.getenv('LOCALAPPDATA') + '\\DOSBox\\dosbox-0.74-3_backup.conf'
INIT_CONFIGS = None
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
    custom_commands: tuple[str]
    configs: list[str]

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

    
    def get_init_configs():
        if CONFIGS_FILE_BACKUP in os.listdir():
            with open(CONFIGS_FILE_BACKUP) as configs_prev:
                INIT_CONFIGS = configs_prev.readlines()
        else:
            with open(CONFIGS_FILE) as configs_prev:
                INIT_CONFIGS = configs_prev.readlines()

    
    def backup_configs():
        with open(CONFIGS_FILE_BACKUP, 'w') as configs_backup:
            configs_backup.writelines(INIT_CONFIGS)

    
    def prepare_config_file():
        os.chdir(CONFIGS_FILE_DIR)
        with open(CONFIGS_FILE, mode='w') as configs_file:
            configs_file.writelines(INIT_CONFIGS)

    
    def restore_config_file():
        os.chdir(CONFIGS_FILE_DIR)
        with open(CONFIGS_FILE) as configs_file:
            config_file.writelines(INIT_CONFIGS)
        os.remove(CONFIGS_FILE_BACKUP)
            

    def clear_tasm_dir():
        os.chdir(TASM_DIR)
        for file in os.listdir():
            if file not in TASM_FILES:
                os.remove(file)


    def copy(self):
        
        def copy_file(file):
            shutil.copy(os.path.join(SOURCE_DIR, file), os.path.join(TASM_DIR, file))

        os.chdir(PROJECT_DIR)
        if type(self.files_to_copy) is str:
            copy_file(self.files_to_copy)
        else:
            for file_to_copy in self.files_to_copy:
                copy_file(file_to_copy)

    
    def detect_build_format(file):
        os.chdir(TASM_DIR)
        with open(file) as code:
            if 'org' in code.read().lower():
                return 'com'
            else:
                return 'exe'


    def mount(self):
        self.configs.append('mount D "' + TASM_DIR + '"')
        self.configs.append('D:')


    def build(self):

        def build_file(file: str):
            self.configs.append('tasm ' + file)
            build_format = LabSetup.detect_build_format(file)
            if build_format == 'com':
                self.configs.append('tlink /t ' + file.replace('.asm', 'obj'))
            elif build_format == 'exe':
                self.configs.append('tlink ' + file.replace('.asm', 'obj'))

        if type(self.files_to_build) is str:
            build_file(self.files_to_build)
        else:
            for file_to_build in self.files_to_build:
                build_file(file_to_build)


    def run(self):
        if self.run_file is not None:
            self.configs.append(self.run_file)


    def debug(self):
        if self.run_file is not None:
            self.configs.append('td ' + self.run_file)


def change_setup():
    setup = input('Enter lab setup >> ')


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

