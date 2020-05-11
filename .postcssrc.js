// https://github.com/michael-ciniawsky/postcss-load-config

module.exports = {
  "plugins": {
    "postcss-import": {},
    "postcss-url": {},
    // to edit target browsers: use "browserslist" field in package.json
    "autoprefixer": {
      overrideBrowserslist: ['Android >= 4.0', 'iOS >= 7']
    },
    "postcss-pxtorem": {
      "rootValue": 16, // 这里设置转换rem的倍数，假设需要设置的宽度为60px，那么转换后就是60/16=3.75rem
      "propList": ["*"]
    }
  }
}
