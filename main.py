# программа для сборки и запуска TASM программ в эмуляторе DOS Box

import os
import subprocess

LAB_SETUPS = {'11': (('lab11',), 'lab11'), # 2-я работа
              '1': (('lab1',), 'lab1'), # 1-я работа
              '2': (('lab21', 'input', 'lab23', 'lab24'), 'lab24'), # 3-я работа
              '3': (('lab3', 'victim-a', 'victim-b', 'victim-c'), 'lab3'), # 4-я работа
              '4': (('lab4', 'victim-a-exe', 'victim-b-exe'), 'lab4'), # 5-я работа
              '5': (('lab5', 'victim-a'), 'lab5'), # 6-я работа
              '6': (('lab6', 'lab3b', 'victim-a', 'victim-b'), None)} # 7-я работа

lab_num = input('Enter lab number >> ')
BUILD_FILES, RUN_FILE = LAB_SETUPS[lab_num]

DOSBOX_PATH = 'C:\\Program Files (x86)\\DOSBox-0.74-3\\DOSBox.exe'
HIEW_PATH = os.path.abspath("hiew") + '\\hiew32.exe'
CONFIGS_FILE_PATH = str(os.getenv('LOCALAPPDATA')) + '\\DOSBox\\dosbox-0.74-3.conf'
PROJECT_DIR = os.path.abspath(".")
TASM_PATH = os.path.abspath("tasm")
TASM_FILES = ('TASM.EXE', 'TD.EXE', 'TLINK.EXE', 'DPMILOAD.EXE')


def prepare_build():
    os.chdir(PROJECT_DIR)
    for file in BUILD_FILES:
        subprocess.call('copy source\\' + file + '.asm' + ' tasm\\' + file + '.asm', shell=True,
                        stdout=subprocess.DEVNULL)
    if RUN_FILE is not None:
        subprocess.call('copy tasm\\' + RUN_FILE + '.asm' + ' tasm\\code.asm', shell=True, stdout=subprocess.DEVNULL)
    os.chdir(TASM_PATH)


def get_build_commands():
    build_commands = []
    for file in os.listdir("."):
        if file.endswith(".asm"):
            with open(file) as text:
                program = text.read().upper()
                filename = text.name
                # create obj
                build_commands.append('tasm /m ' + filename)
                filename = filename.replace('.asm', '')
                # link obj to executable file
                if 'ORG' in program:
                    build_commands.append('tlink /t ' + filename + '.obj')
                else:
                    build_commands.append('tlink ' + filename + '.obj')
    return build_commands


def clean_formats(formats):
    files = os.listdir(TASM_PATH)

    for item in files:
        if item not in TASM_FILES:
            if any(s.lower() in item.lower() for s in formats):
                os.remove(os.path.join(TASM_PATH, item))


def clean_all():
    # removes .map .obj .exe .com
    clean_formats(['.asm', '.map', '.exe', '.obj', '.com'])


def clean_non_executable():
    # removes .map .obj
    clean_formats(['.map', '.obj'])


# read initial config
try:
    config_file_init = open(CONFIGS_FILE_PATH + '_copy.conf', mode='r')
except Exception as e:
    config_file_init = open(CONFIGS_FILE_PATH + '_copy.conf', mode='w')
    with open(CONFIGS_FILE_PATH, mode='r') as configs_file:
        config_file_init.writelines(configs_file.readlines())
    config_file_init.close()
    config_file_init = open(CONFIGS_FILE_PATH + '_copy.conf', mode='r')
config_init = config_file_init.readlines()
config_file_init.close()

# define commands for DOSBOX
start_commands = ['mount D "' + TASM_PATH + '"',
                  'D:']
commands = {'r': ['code'],
            'd': ['td code']}
end_commands = []

run_args = ['r', 'd', 'h']

args = str(input(
    'DOSBOX TASM starter v. 0.1\n' +
    'Chosen file for running: ' + (RUN_FILE if RUN_FILE is not None else 'None') + ', build files: ' + ', '.join(
        BUILD_FILES) + '\n' +
    'r - run\n' +
    'd - debug\n' +
    'h - hiew for running program (may not work)\n' +
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
            if args == 'h':
                subprocess.Popen([HIEW_PATH, TASM_PATH + "\\" + RUN_FILE])
            else:
                print('Unexpected abbr\n')
                break

    for command in end_commands:
        config.append(command + '\n')

    with open(CONFIGS_FILE_PATH, mode='w') as config_file:
        config_file.writelines(config)

    clean_non_executable()
    process = subprocess.Popen(DOSBOX_PATH)

    args = input()
    while args.strip() == '':
        args = input()
    process.kill()

with open(CONFIGS_FILE_PATH, mode='w') as config_file:
    config_file.writelines(config_init)

clean_all()
os.remove(CONFIGS_FILE_PATH + '_copy.conf')
