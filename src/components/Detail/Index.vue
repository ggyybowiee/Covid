<template>
  <div class="index-page" id="index-page">
    <div class="header">
      <img src="../../assets/images/top-head.jpg" alt="">
      <button class="to-home" @click="toHome">{{$t('主页')}}</button>
    </div>

    <div class="data-statement">
      <div class="title" @click="toHome"><span>{{provinceName}} | {{$t('疫情状况')}}</span></div>
      <div class="update-time">{{$t('截止')}}: {{updateTime}}</div>
    </div>

    <div class="summary">
      <div class="confirm">
        <div class="number">{{_.get(total, 'current_total')}}</div>
        <div class="tag"><span>{{$t('现存确诊')}}</span></div>
      </div>
      <div class="suspect">
        <div class="number">{{_.get(total, 'case_total')}}</div>
        <div class="tag"><span>{{$t('累计确诊')}}</span></div>
      </div>
      <div class="dead">
        <div class="number">{{_.get(total, 'death_total')}}</div>
        <div class="tag"><span>{{$t('累计死亡')}}</span></div>
      </div>
      <div class="heal">
        <div class="number">{{_.get(total, 'cure_total')}}</div>
        <div class="tag"><span>{{$t('累计治愈')}}</span></div>
      </div>
    </div>

    <figure>
      <e-charts ref="line" :options="currentList" :init-options="initOptions" autoresize></e-charts>
    </figure>
    <figure>
      <e-charts ref="line" :options="caseList" :init-options="initOptions" autoresize></e-charts>
    </figure>
    <figure>
      <e-charts ref="line" :options="deathList" :init-options="initOptions" autoresize></e-charts>
    </figure>

  </div>
</template>

<script>
  import api from "../../api/api";
  import common from "../../common.js";
  import ECharts from "../Echarts.vue";

  export default {
    components: {
      ECharts
    },
    data() {
      return {
        updateTime: '',
        total: {},
        map: {},
        table: [],
        provinceName: '',
        initOptions: {
          renderer: 'canvas'
        },
        caseList: [],
        cureList: [],
        deathList: [],
        currentList: [],
        activeName: "first",
        interval: null
      };
    },
    created() {
      window.scrollTo(0, 0);
      this.provinceName = this.$route.query.provinceName;
      this.getBrazilInfo();
      let _self = this;

      //setInterval 每隔1小时执行一次
      this.interval = setInterval(function () {
        _self.getBrazilInfo();
      }, 3600000);
    },
    beforeDestroy() {
      clearInterval(this.interval);
    },
    mounted() {
      document.title = this.provinceName + ' | ' + this.$t("疫情状况");
    },
    methods: {
      toHome() {
        this.$router.push({
          path: '/home'
        });
      },
      getBrazilInfo() {
        let _self = this;
        let uid = this.$route.query.uid;

        this.$http
          .get(api.getBrazilInfo(), {
            params: {
              uid
            }
          })
          .then(res => {
            if (res.status == 200) {
              const {
                data,
                case_total,
                cure_total,
                current_total,
                death_total,
                l_case_total,
                l_cure_total,
                l_current_total,
                l_death_total,
                update_time,
                x_date_time,
                y_case,
                y_current,
                y_death
              } = res.data;
              _self.table = data;
              _self.updateTime = update_time;
              _self.total = {
                case_total: case_total,
                cure_total: cure_total,
                current_total: current_total,
                death_total: death_total
              };

              this.currentList = this.common.currentLineConfig(_self, x_date_time, y_current);
              this.caseList = this.common.caseLineConfig(_self, x_date_time, y_case);
              this.deathList = this.common.deathLineConfig(_self, x_date_time, y_death);

            } else {
              _self.message(_self.$t("系统异常，请稍后重试！"));
            }
          })
          .catch(() => {});
      },
      // 消息提示
      message(parame) {
        this.$message({
          duration: 4000,
          showClose: true,
          message: `${parame}`,
          type: "",
          iconClass: ""
        });
      }
    }
  };

</script>

<style lang="less" scoped>
  .index-page {
    padding: 0;
    font-size: 1.25rem;
    position: relative;
    min-height: 100vh;
    background: #fff;
    color: #2c3e50;
    height: 100vh;
    margin: 0 auto;
    display: flex;
    flex-direction: column;

    .header {
      position: relative;

      img {
        width: 100%;
      }

      .to-home {
        text-align: center;
        position: absolute;
        bottom: 1.25rem;
        left: 0;
        z-index: 100;
        height: 1.5625rem;
        line-height: 1.5625rem;
        background: linear-gradient(90deg, hsl(215, 99%, 45%) 0, hsl(195, 100%, 52%));
        width: 6.875rem;
        color: #fff;
        font-size: 0.875rem;
        border: none;
        border-radius: 0 0.9375rem 0.9375rem 0;
      }

      .to-home:active,
      .to-home:focus,
      .to-home:visited {
        background: linear-gradient(90deg, hsl(215, 99%, 45%) 0, hsl(195, 100%, 52%));
        border: none;
        outline: none;
      }
    }

    .data-statement {
      padding: 1rem;
      text-align: left;

      .title {
        font-size: 1.25rem;
        font-weight: 700;
        border-left: 4px solid #4F7AF3;
        padding-left: 5px;
        color: #4F7AF3;
      }

      .update-time {
        font-size: 12px;
        margin-top: .3rem;
        color: #b6b6b6;
        vertical-align: middle;
      }
    }

    .summary {
      display: flex;
      display: -webkit-flex;
      display: -webkit-box;
      display: -moz-box;
      display: -ms-flexbox;

      justify-content: space-between;
      -webkit-box-pack: justify;
      -webkit-justify-content: space-between;
      -ms-flex-pack: justify;

      padding: 0 1rem;
      text-align: center;

      >div {
        width: 25%;
        flex: 1;
        -webkit-flex: 1;
        -ms-flex: 1;
        -webkit-box-flex: 1;
        -moz-box-flex: 1;

        margin-right: .5rem;
        padding-top: .5rem;
      }

      >div:last-child {
        margin-right: 0;
      }

      .small-number {
        font-size: 0.75rem;
        display: block;
        margin-top: .2rem;
      }

      .number {
        font-size: 1.25rem;
        font-weight: bold;
        margin: 0.5rem 0;
      }

      .tag {
        padding: 0.625rem 0;
        font-size: 0.75rem;
        font-weight: bold;
        height: 1.6rem;
        line-height: 1rem;
        display: flex;
        align-items: center;
        justify-content: center;
      }

      .tip {
        font-size: 0.75rem;
        color: #8B8989;
      }

      .confirm {
        background-color: #FDF1F1;

        .tag {
          background-color: #FFE0E0;
        }

        .number,
        .small-number {
          color: #D81D1B;
        }
      }

      .suspect {
        background-color: #FFF7ED;

        .tag {
          background-color: #FFEED9;
        }

        .number,
        .small-number {
          color: #F7AB1A;
        }
      }

      .heal {
        background-color: #F1F8F4;

        .tag {
          background-color: #DFEEE6;
        }

        .number,
        .small-number {
          color: #178B50;
        }
      }

      .dead {
        background-color: #F8F8F8;

        .tag {
          background-color: #EEEEEE;
        }

        .number,
        .small-number {
          color: #66666C;
        }
      }
    }

    figure {
      padding: 1.25rem 0.625rem 0 0.625rem;
    }
  }

</style>
