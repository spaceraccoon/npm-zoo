# stream-combine@2.0.2

* Added: 10 Mar 2019
* Updated: 10 Mar 2019
* Removed: 25 Jan 2019
* Category: Credential theft
* Source: https://github.com/viriciti/stream-combine/issues/1
* Reference: https://www.npmjs.com/advisories/774

## Summary

The file `src/StreamCombine.coffee` includes code to steal and exfiltrate credentials and credit card information. The code searches all form elements for passwords, credit card numbers and CVC codes. It then uploads the information to a remote server using HTML links embedded in the page or form actions. Found by Yeiniel Suárez Sosa.