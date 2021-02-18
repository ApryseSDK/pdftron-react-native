# scripts folder

This folder is only for convenient file copying for pdftron react native, which does not in any way affect the implementation of this module.

To run the scripts, you could go to [package.json](./../package.json) in the root to see the list of available scripts.

For example, if script name is `copy-to-repo`, then navigate to the root of this repository, and run:

```
npm run copy-to-repo
```

## Scripts

### copy-to-repo
This script copies pdftron-react-native (node modules in example -> root level of this repository). It is mostly useful when you have finished the implementation and are one step away from committing.

### copy-to-node-modules
This script copies pdftron-react-native (root level of this repository -> node modules in example). Generally, this has been done by `npm install` or `yarn install`, but it could still be useful if you are switching branches.

