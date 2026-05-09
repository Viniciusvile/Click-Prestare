const http = require('http');

const data = JSON.stringify({
  login: 'morador@teste.com',
  password: '123456'
});

const options = {
  hostname: '192.168.3.74',
  port: 3003,
  path: '/moradores/login',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': data.length
  }
};

const req = http.request(options, (res) => {
  console.log(`Status Code: ${res.statusCode}`);

  res.on('data', (d) => {
    process.stdout.write(d);
  });
});

req.on('error', (error) => {
  console.error(error);
});

req.write(data);
req.end();
