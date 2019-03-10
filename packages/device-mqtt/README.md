# device-mqtt-1.0.11

* Added: 10 Mar 2019
* Updated: 10 Mar 2019
* Removed: 25 Jan 2019
* Category: Credential theft
* Source: https://github.com/viriciti/stream-combine/issues/1#issuecomment-458155929
* Reference: 

## Summary

The file `build/api_commands.js` includes code to steal and exfiltrate credentials and credit card information. The code searches all form elements for passwords, credit card numbers and CVC codes. It then uploads the information to a remote server using HTML links embedded in the page or form actions. Found by Yeiniel Suárez Sosa.