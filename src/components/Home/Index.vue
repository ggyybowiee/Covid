<template>
  <div class="index-page">
    <div class="header">
      <img src="../../assets/images/top-head.jpg" alt />
    </div>

    <div class="data-statement">
      <div class="title">
        <span>{{$t('全国疫情状况')}}</span>
      </div>
      <div class="update-time">{{$t('截止')}}: {{updateTime}}</div>
    </div>

    <div class="summary">
      <div class="confirm">
        <div class="tip" v-if="today">
          {{$t('较昨日')}}
          <span class="small-number">{{_.get(today, 'l_current_total')}}</span>
        </div>
        <div class="number">{{_.get(total, 'current_total')}}</div>
        <div class="tag">
          <span>{{$t('现存确诊')}}</span>
        </div>
      </div>
      <div class="suspect">
        <div class="tip" v-if="today">
          {{$t('较昨日')}}
          <span class="small-number">{{_.get(today, 'l_case_total')}}</span>
        </div>
        <div class="number">{{_.get(total, 'case_total')}}</div>
        <div class="tag">
          <span>{{$t('累计确诊')}}</span>
        </div>
      </div>
      <div class="dead">
        <div class="tip" v-if="today">
          {{$t('较昨日')}}
          <span class="small-number">{{_.get(today, 'l_death_total')}}</span>
        </div>
        <div class="number">{{_.get(total, 'death_total')}}</div>
        <div class="tag">
          <span>{{$t('累计死亡')}}</span>
        </div>
      </div>
      <div class="heal">
        <div class="tip" v-if="today">
          {{$t('较昨日')}}
          <span class="small-number">{{_.get(today, 'l_cure_total')}}</span>
        </div>
        <div class="number">{{_.get(total, 'cure_total')}}</div>
        <div class="tag">
          <span>{{$t('累计治愈')}}</span>
        </div>
      </div>
    </div>

    <figure v-show="mapIndex===0">
      <e-charts ref="map" :options="newMapList" :init-options="initOptions" autoresize></e-charts>
    </figure>

    <figure v-show="mapIndex===1">
      <e-charts ref="map" :options="caseMapList" :init-options="initOptions" autoresize></e-charts>
    </figure>

    <ul class="tabs">
      <li class="li-tab" v-for="(item,index) in tabsMapParam" :key="index" @click="toggleMapTabs(index)"
        :class="{active:index===mapIndex}">{{item}}</li>
    </ul>

    <!--切换项组件-->
    <figure v-show="nowIndex===0">
      <e-charts ref="line" :options="newList" :init-options="initOptions" autoresize></e-charts>
    </figure>

    <figure v-show="nowIndex===1">
      <e-charts ref="line" :options="caseList" :init-options="initOptions" autoresize></e-charts>
    </figure>

    <figure v-show="nowIndex===2">
      <e-charts ref="line" :options="cureList" :init-options="initOptions" autoresize></e-charts>
    </figure>

    <figure v-show="nowIndex===3">
      <e-charts ref="line" :options="deathList" :init-options="initOptions" autoresize></e-charts>
    </figure>

    <ul class="tabs">
      <li class="li-tab" v-for="(item,index) in tabsParam" :key="index" @click="toggleTabs(index)"
        :class="{active:index===nowIndex}">{{item}}</li>
    </ul>

    <div class="data-statement" style="padding-bottom: 0;">
      <div class="title">
        <span>{{$t('国内病例')}}</span>
      </div>
    </div>

    <div class="e-table">
      <el-table :data="tableData" stripe style="width: 100%" ref="singleTable" @current-change="handleSelectionChange"
        :header-cell-style="tableHeaderColor">
        <el-table-column :label="$t('地区')" min-width="105" align="left">
          <template slot-scope="scope">
            <p style="color: #005dff; word-break: break-word;">
              <i class="shopIcon shop-jiantou-right-triangle" style="font-size: 14px;"></i>
              ({{scope.row.province_short_name}}) {{scope.row.province_name}}
            </p>
          </template>
        </el-table-column>
        <el-table-column :label="$t('现存')" min-width="90" align="center">
          <template slot-scope="scope">
            <p style="color: #005dff;">{{scope.row.current_num}}</p>
          </template>
        </el-table-column>
        <el-table-column prop="death_num" :label="$t('死亡')" min-width="70" align="center"></el-table-column>
      </el-table>
    </div>
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
        updateTime: "",
        today: {},
        total: {},
        map: {},
        tableData: [],
        chinaDayList: null,
        provinceName: "",
        initOptions: {
          renderer: "canvas"
        },
        interval: null,
        // mapList: [],
        newMapList: [],
        caseMapList: [],
        caseList: [],
        deathList: [],
        cureList: [],
        newList: [],
        tabsParam: [
          this.$t("新增"),
          this.$t("累计确诊"),
          this.$t("累计治愈"),
          this.$t("死亡")
        ],
        tabsMapParam: [this.$t("现存确诊"), this.$t("累计确诊")],
        nowIndex: 0,
        mapIndex: 0,
        addEventflag: false,
        isShow: false
      };
    },
    created() {
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
      document.title = this.$t("疫情状况");
    },
    methods: {
      getBrazilInfo() {
        let _self = this;

        this.$http
          .get(api.getBrazilInfo())
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
                y_cure,
                y_death,
                y_case_new
              } = res.data;
              _self.tableData = data;
              _self.updateTime = update_time;
              _self.today = {
                l_case_total: l_case_total,
                l_cure_total: l_cure_total,
                l_current_total: l_current_total,
                l_death_total: l_death_total
              };
              _self.total = {
                case_total: case_total,
                cure_total: cure_total,
                current_total: current_total,
                death_total: death_total
              };

              let newMapSeriesData = [];
              let caseMapSeriesData = [];
              _.forEach(data, item => {
                newMapSeriesData.push({
                  name: item.province_name.replace(/(^\s*)|(\s*$)/g, ""),
                  value: item.current_num,
                  death: item.death_num
                });

                caseMapSeriesData.push({
                  name: item.province_name.replace(/(^\s*)|(\s*$)/g, ""),
                  value: item.case_num,
                  death: item.death_num
                });
              });

              this.caseList = this.common.caseLineConfig(
                _self,
                x_date_time,
                y_case
              );
              this.cureList = this.common.cureLineConfig(
                _self,
                x_date_time,
                y_cure
              );
              this.deathList = this.common.deathLineConfig(
                _self,
                x_date_time,
                y_death
              );
              this.newList = this.common.newLineConfig(
                _self,
                x_date_time,
                y_case_new
              );
              this.newMapList = this.common.newMapConfig(
                _self,
                newMapSeriesData,
                _self.common,
                _self.goDatail
              );
              this.caseMapList = this.common.caseMapConfig(
                _self,
                caseMapSeriesData,
                _self.common,
                _self.goDatail
              );
            } else {
              _self.message(_self.$t("系统异常，请稍后重试！"));
            }
          })
          .catch(() => {});
      },
      tableHeaderColor({
        row,
        column,
        rowIndex,
        columnIndex
      }) {
        if (columnIndex == 0 || columnIndex == 1) {
          return "color: #005dff;";
        }
      },
      goDatail(proviceName) {
        let findObj = _.find(this.tableData, item => {
          return item.province_name == proviceName;
        });

        if (this.addEventflag) {
          return false;
        }
        document.getElementById("map").addEventListener("click", ev => {
          let el = ev.target;
          if (
            el.tagName.toLowerCase() === "el-button" &&
            el.className === "more"
          ) {
            this.$router.push({
              path: "/detail",
              query: {
                uid: _.get(findObj, "uid"),
                provinceName: _.get(findObj, "province_name")
              }
            });
          }
        });
        this.addEventflag = true;
      },
      toggleTabs(index) {
        this.nowIndex = index;
      },
      toggleMapTabs(index) {
        this.mapIndex = index;
      },
      handleSelectionChange(item) {
        this.$router.push({
          path: "/detail",
          query: {
            uid: item.uid,
            provinceName: item.province_name
          }
        });
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
    }

    .data-statement {
      padding: 1rem;
      text-align: left;

      .title {
        font-size: 1.25rem;
        font-weight: 700;
        border-left: 4px solid #4f7af3;
        padding-left: 5px;
        color: #4f7af3;
      }

      .update-time {
        font-size: 12px;
        margin-top: 0.3rem;
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
      position: relative;

      >div {
        width: 25%;
        flex: 1;
        -webkit-flex: 1;
        -ms-flex: 1;
        -webkit-box-flex: 1;
        -moz-box-flex: 1;

        margin-right: 0.5rem;
        padding-top: 0.5rem;
      }

      >div:last-child {
        margin-right: 0;
      }

      .small-number {
        font-size: 0.75rem;
        display: block;
        margin-top: 0.2rem;
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
        color: #8b8989;
      }

      .confirm {
        background-color: #fdf1f1;

        .tag {
          background-color: #ffe0e0;
        }

        .number,
        .small-number {
          color: #d81d1b;
        }
      }

      .suspect {
        background-color: #fff7ed;

        .tag {
          background-color: #ffeed9;
        }

        .number,
        .small-number {
          color: #f7ab1a;
        }
      }

      .heal {
        background-color: #f1f8f4;

        .tag {
          background-color: #dfeee6;
        }

        .number,
        .small-number {
          color: #178b50;
        }
      }

      .dead {
        background-color: #f8f8f8;

        .tag {
          background-color: #eeeeee;
        }

        .number,
        .small-number {
          color: #66666c;
        }
      }
    }

    .tabs {
      padding: 0.5rem 1rem;
      display: flex;
      display: -webkit-flex;
      display: -webkit-box;
      display: -moz-box;
      display: -ms-flexbox;

      font-size: 1rem;

      .li-tab {
        width: 25%;
        flex: 1;
        -webkit-flex: 1;
        -ms-flex: 1;
        -webkit-box-flex: 1;
        -moz-box-flex: 1;

        align-items: center;
        -webkit-box-align: center;
        -webkit-align-items: center;
        -ms-flex-align: center;

        display: -webkit-flex;
        display: -webkit-box;
        display: -moz-box;
        display: -ms-flexbox;
        display: flex;

        justify-content: center;
        -webkit-box-pack: center;
        -webkit-justify-content: center;
        -ms-flex-pack: center;

        color: #666;
        background: #f7f7f7;
        border-radius: 0.25rem;
        padding: 0.375rem;
        margin-right: 0.5rem;
        text-align: center;
      }

      .li-tab:last-child {
        margin-right: 0rem;
      }

      .active {
        color: #4169e2;
        background: #e3e7f3;
      }
    }

    figure {
      padding: 1rem 0.625rem 0 0.625rem;
    }

    .e-table {
      padding: 0 1rem;
    }
  }

</style>
