import subprocess
import os

SOURCE_FILE = 'hello'  # TODO specify filename here

DOSBOX_PATH = 'C:\\Program Files (x86)\\DOSBox-0.74-3\\DOSBox.exe'
CONFIGS_FILE_PATH = os.getenv('LOCALAPPDATA') + '\\DOSBox\\dosbox-0.74-3.conf'
PROJECT_DIR = os.path.abspath(".")
TASM_PATH = os.path.abspath("tasm")


def prepare_build():
    os.chdir(PROJECT_DIR)
    os.system('copy source\\' + SOURCE_FILE + '.asm' + ' tasm\\code.asm')
    os.chdir(TASM_PATH)


def clean_build():
    # removes .map .obj .exe .com
    formats = ['.asm', '.map', 'code.exe', '.obj', '.com']
    files = os.listdir(TASM_PATH)

    for item in files:
        if any(s in item.lower() for s in formats):
            os.remove(os.path.join(TASM_PATH, item))


try:
    configs_file_init = open(CONFIGS_FILE_PATH + '_copy.conf', mode='r')
except Exception as e:
    configs_file_init = open(CONFIGS_FILE_PATH + '_copy.conf', mode='w')
    with open(CONFIGS_FILE_PATH, mode='r') as configs_file:
        configs_file_init.writelines(configs_file.readlines())
    configs_file_init.close()
    configs_file_init = open(CONFIGS_FILE_PATH + '_copy.conf', mode='r')
configs_init = configs_file_init.readlines()
configs_file_init.close()

intro = ['mount D ' + TASM_PATH,
         'D:']
commands = {'c': ['tasm code.asm',
                  'tlink /t code.obj'],
            'x': ['tasm code.asm',
                  'tlink code.obj'],
            'rc': ['code.com'],
            'rx': ['code.exe'],
            'dc': ['td code.com'],
            'dx': ['td code.exe']}
depended_commands = ['r', 'd']
outro = []
boot_conf = str(input(
    'Welcome, are you too lazy?\n' +
    'You have chosen the right way!\n' +
    'c - build to .com\n' +
    'x - build to .exe\n' +
    'r - run\n' +
    'd - debug\n' +
    'q - exit\n' +
    'type your run configuration:\n'))

compiler_mode = ''
while boot_conf != 'q':
    clean_build()
    prepare_build()
    if boot_conf.strip() == '':
        boot_conf = input()
        pass

    configs = configs_init.copy()
    for intro_com in intro:
        configs.append(intro_com + '\n')
    for boot_coms_abbr in boot_conf:
        if boot_coms_abbr in ['c', 'x']:
            compiler_mode = boot_coms_abbr
        elif boot_coms_abbr in depended_commands:
            if compiler_mode in ['c', 'x']:
                boot_coms_abbr += compiler_mode
            else:
                print('Please, rebuild your project firstly\n')
                break
        try:
            for boot_com in commands[boot_coms_abbr]:
                configs.append(boot_com + '\n')
        except:
            print('Unexpected abbr\n')
            break
    for outro_com in outro:
        configs.append(outro_com + '\n')
    with open(CONFIGS_FILE_PATH, mode='w') as config_file:
        config_file.writelines(configs)
    subprocess.run(DOSBOX_PATH)
    clean_build()
    boot_conf = input()
with open(CONFIGS_FILE_PATH, mode='w') as config_file:
    config_file.writelines(configs_init)

os.remove(CONFIGS_FILE_PATH + '_copy.conf')
