# commander-js@2.19.84

* Added: 20 Jan 2019
* Updated: 20 Jan 2019
* Removed: 9 Jan 2019
* Category: Install scripts
* Source: https://github.com/malicious-packages/cemetery
* Reference: https://www.npmjs.com/advisories/763

## Summary

This package is trying to mimic the real commander.js. It has a backdoor in postinstall script which downloads and evaluates the content of http://23.94.46.191/update.json (which currently doesn't contain anything malicious). `update.json` (downloaded 10 Jan) is attached to this repo.
