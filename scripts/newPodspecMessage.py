class bcolors:
    OKCYAN = '\033[96m'
    WARNING = '\033[93m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
    
print(bcolors.WARNING + bcolors.BOLD + "\n[January 2022]\nThere is a new podspec for the PDFTron iOS React Native wrapper:")
print(bcolors.OKCYAN + bcolors.UNDERLINE + "https://pdftron.com/downloads/ios/react-native/latest.podspec" + bcolors.ENDC)
print(bcolors.WARNING + "Please update your app's Podfile accordingly.\n" + bcolors.ENDC)