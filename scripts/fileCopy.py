import sys
import os
import shutil

# NOTE: this script is only used to copy files under android, ios and src folders.

REPO_DIR = os.path.dirname(os.path.dirname(__file__))
MODULE_DIR = os.path.join(REPO_DIR, 'example', 'node_modules', 'react-native-pdftron')

COPY_FOLDER_LIST = ['android', 'ios', 'src']

toRepo = sys.argv[1] == 'toRepo'

# The source and destination for copying process
srcRoot = MODULE_DIR if toRepo else REPO_DIR
dstRoot = REPO_DIR if toRepo else MODULE_DIR

print(srcRoot)
print(dstRoot)

# delete original folders if exist and copy over
for folder in COPY_FOLDER_LIST:
    src = os.path.join(srcRoot, folder)
    dst = os.path.join(dstRoot, folder)
    if (os.path.exists(dst)):
        shutil.rmtree(dst)
    shutil.copytree(src, dst)