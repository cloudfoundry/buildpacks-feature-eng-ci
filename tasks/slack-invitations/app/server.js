const slackin = require('slackin')

const port = process.env.PORT || 8080;

slackin.default({
  token: process.env.APP_TOKEN,
  interval: 1000,
  org: 'paketobuildpacks',
  silent: false
}).listen(port)
