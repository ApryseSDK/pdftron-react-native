import argparse
from genericpath import isdir
import pwinput
import subprocess
import os
import shutil
import json

# Constants
rn_api_root = "pdftron-api-docs/src/api/react-native"
new_docs_src = "docs"
scripts_dir = os.getcwd()

def get_version():
    package_json = open("../package.json")
    json_data = json.load(package_json)
    return json_data["version"]

def retrieve_args():
    # Set up argument parser
    parser = argparse.ArgumentParser(prog="BuildDocs", 
        description="Automatically generates React Native API documentation for the website")
    parser.add_argument("branch", help="Branch to build documentation on", nargs="?", 
        default="react-native-{0}".format(get_version()))

    # Retrieve arguments
    args = parser.parse_args()
    return args.branch

def retrieve_repo():
    # Determine if using HTTPS or SSH URL
    use_ssh = 0
    while (use_ssh != 1 and use_ssh != 2):
        try:
            use_ssh = int(input("Enter:\n1 to use HTTPS and \n2 to use SSH\n"))
            if (use_ssh != 1 and use_ssh != 2):
                print("Incorrect value entered")
        except ValueError:
            print("Incorrect type entered")

    if (use_ssh == 1):
        # Retrieve user information
        github_user_name = input("Enter GitHub user name: ")
        github_pat = pwinput.pwinput(prompt="Enter GitHub personal access token: ")
        # Set URL
        pdftron_api_repo = "https://{0}:{1}@github.com/XodoDocs/pdftron-api-docs".format(github_user_name, github_pat)
    else:
        pdftron_api_repo =  "git@github.com:XodoDocs/pdftron-api-docs.git"
    
    subprocess.check_call(args=["git", "clone", pdftron_api_repo])

# Delete old API documentation. If the folder containing the API documentation does not exist, a folder is created
def delete_old_docs():
    try:
        # Retrieves list of files and directories stored in rn_api_root
        rn_api_dir_contents = os.listdir(rn_api_root)
        print("Deleting old React Native API documentation")
        for content in rn_api_dir_contents:
            content_path = "{0}/{1}".format(rn_api_root, content)
            if (isdir(content_path)):
                shutil.rmtree(content_path)
            else:
                os.remove(content_path)
        print("Finished deleting old documentation, copying over new documentation")
    except FileNotFoundError:
        print("No React Native API documentation to delete, copying over new documentation")
        os.mkdir(rn_api_root)

# Creates latest version of API documentation and then copies it over to the repo
def copy_over_new_docs():
    print("Creating latest version of documentation")
    # Runs script to create new documentation
    subprocess.check_call(["npm", "run", "build-js-and-docs"])
    new_docs = os.listdir(new_docs_src)
    os.chdir(scripts_dir)
    
    print("Copying over new documentation to repo")
    for content in new_docs:
        content_path = "{0}/{1}".format("../{0}".format(new_docs_src), content)
        dest_path = "{0}/{1}".format(rn_api_root, content)
        if (isdir(content_path)):
            shutil.copytree(content_path, dest_path)
        else:
            shutil.copy(content_path, dest_path)
    print("Finished copying over new documentation to repo")

def commit_and_push(branch_name: str):
    os.chdir(rn_api_root[0:16])

    # Checks if branch name provided already exists before switching to branch
    branches = subprocess.check_output(["git", "branch", "-a"]).decode().splitlines()
    branch_exists = False
    for branch in branches:
        branch = branch.replace("* ", "").replace("remotes/origin/", "").strip()
        if (branch == branch_name):
            branch_exists = True
            break;

    if (branch_exists):
        subprocess.check_call(["git", "checkout", branch_name])
    else: 
        subprocess.check_call(["git", "checkout", "-b", branch_name])   

    # Commit and push update
    print("Committing changes on branch: {0}".format(branch_name))
    subprocess.check_call(["git", "add", rn_api_root[17:]])
    subprocess.check_call(["git", "commit", "-m", "Updating React Native API documentation"])
    subprocess.check_call(["git", "push", "origin", branch_name])
    os.chdir("..")

def clean_up():
    print("Deleting cloned repo")
    shutil.rmtree(rn_api_root[0:16])
    print("Finished")

def main():
    branch_name = retrieve_args()
    retrieve_repo()
    delete_old_docs()
    copy_over_new_docs()
    commit_and_push(branch_name)
    clean_up()

if __name__ == "__main__":
    main()