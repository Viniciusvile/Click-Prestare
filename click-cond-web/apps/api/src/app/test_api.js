const http = require('http');

const data = JSON.stringify({
  login: 'sindico_novo@click.com',
  password: '123456'
});

const options = {
  hostname: '127.0.0.1',
  port: 3000,
  path: '/api/sindico/login',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(data)
  }
};

const req = http.request(options, (res) => {
  let body = '';
  res.on('data', (d) => body += d);
  res.on('end', () => {
    console.log('Login Status:', res.statusCode);
    console.log('Login Response:', body);
    if (res.statusCode !== 200) return;
    
    const parsed = JSON.parse(body);
    const token = parsed.token;

    const listOptions = {
      hostname: '127.0.0.1',
      port: 3000,
      path: '/api/sindico/list-condominios',
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`
      }
    };

    http.get(listOptions, (res2) => {
      let body2 = '';
      res2.on('data', (d) => body2 += d);
      res2.on('end', () => {
        console.log('List Status:', res2.statusCode);
        console.log('List Response:', body2);
      });
    }).on('error', (e) => console.error('List Error:', e));
  });
});

req.on('error', (e) => {
  console.error('Problem with request:', e);
});

req.write(data);
req.end();
