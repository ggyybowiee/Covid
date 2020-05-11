// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import App from './App'
import router from './router'
import lang from './assets/i18n/language'
import common from './common'
import './rem.js'
import './assets/icon/iconfont.css'
import './styles/common.css'

Vue.config.productionTip = false
Vue.prototype.$http = axios
Vue.prototype.moment = moment
Vue.prototype.common = common
Vue.prototype._ = _
Vue.prototype.echarts = echarts

// 多语言
Vue.use(VueI18n)
const i18n = new VueI18n({
  locale: 'pt',
  messages: lang
})

/* eslint-disable no-new */
new Vue({
  el: '#app',
  i18n,
  router,
  components: {
    App
  },
  template: '<App/>'
})
