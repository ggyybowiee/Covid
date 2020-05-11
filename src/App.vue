<template>
  <div id="app">
    <router-view />
  </div>
</template>

<script>
  export default {
    name: "App",
    data() {
      return {};
    },
    mounted: function () {
      let urlParams = this.common.getUrlParams(window.location.href);

      // 缓存入参
      for (let i in urlParams) {
        sessionStorage.setItem(i, urlParams[i]);
      }

      let langArr = ["zh", "en", "es", "pt"];

      if (langArr.indexOf(sessionStorage.getItem("lang")) > -1) {
        this.$i18n.locale = sessionStorage.getItem("lang");
      } else {
        this.$i18n.locale = "pt";
      }
    }
  };

</script>

<style lang="less" scope>
</style>
