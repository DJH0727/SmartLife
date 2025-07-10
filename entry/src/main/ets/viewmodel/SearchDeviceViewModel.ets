import { DeviceEnum, getDeviceType } from "../common/enums/DeviceEnum";
import { MqttMessageDispatcher } from "../common/utils/MqttMessageDispatcher";
import MQTTUtil from "../common/utils/MQTTUtil";
import { DeviceBase } from "../model/device/DeviceBase";
import { DeviceDataSource } from "../model/DeviceDataSource";

interface UnboundDevicePayload {
  id: string;
  type: string;
  name: string;
  isBind: number;
  isPowerOn?: boolean;
  lastUpdate?: number;
}

export class SearchDeviceViewModel {
  MqttUtil:MQTTUtil=MQTTUtil.getInstance();
  unboundDevicesDS: DeviceDataSource;
  refreshing: boolean = false;
  private searchTimer?: number;
  private timeoutTimer?: number;
  private isTimeOut: boolean = false;
  private isSearching:boolean = false;
  private dispatcher:MqttMessageDispatcher = MqttMessageDispatcher.getInstance();

  constructor() {
    this.unboundDevicesDS = new DeviceDataSource([]);
  }

  refreshUnboundDevices() {
    if(!this.isSearching)
        this.startSearchDevices()
    // console.info("正在刷新设备列表...");
    // setTimeout(() => {
    //   // 这里为了演示，直接清空并加入一个新设备
    //   this.unboundDevicesDS.addDevice(new DeviceBase("dev103", DeviceEnum.AIR_CONDITIONER, "卧室空调", ""))
    //   this.unboundDevicesDS.notifyDataReload();
    //   this.refreshing = false;
    // }, 1500);

  }

  /*
   * {"id": "dev101","type": "air_conditioner","name": "Gree Air Conditioner"}
   * {"id": "dev102","type": "humidifier","name": "Gree Humidifier"}
   * {"id": "dev103","type": "gas_detector","name": "Gree Gas Detector"}
   */
  startSearchDevices() {

    console.info("开始搜索设备...");
    this.refreshing = true;
    this.isSearching = true;

    this.dispatcher.registerHandler('/devices/unbound/response', (payload) => {
      const ub = JSON.parse(payload) as UnboundDevicePayload;
      console.info("接收到设备信息：", JSON.stringify(ub));
      if(!ub.isBind){
        this.unboundDevicesDS.addDevice(
          new DeviceBase(ub.id, getDeviceType(ub.type), ub.name)
        );
      }

      // 处理设备信息，更新数据源等
    });

    setTimeout(() => {
      this.MqttUtil.subscribe("/devices/unbound/response", 0);
    }, 50); // 50ms 通常足够

    this.searchTimer = setInterval(() => {
      if (this.isTimeOut) {
        clearInterval(this.searchTimer);
        clearInterval(this.timeoutTimer)
        console.info("搜索超时，停止搜索。");
        this.MqttUtil.unsubscribe("/devices/unbound/response",0)
        this.dispatcher.unregisterHandler('/devices/unbound/response')
        this.refreshing = false;
        this.isSearching = false;
        console.info("set refresh refreshing to "+this.refreshing)
        this.isTimeOut = false;
        return;
      }
      this.getUnboundDeviceFromMqtt();
    }, 2000);

    // 超时时间设置
    this.timeoutTimer = setTimeout(() => {
      this.isTimeOut = true;
    }, 5000);

  }

  getUnboundDeviceFromMqtt(){
    this.MqttUtil.publish("/devices/unbound/request", "{}",0)
  }





  stopSearchDevices() {
    if (this.searchTimer) {
      clearInterval(this.searchTimer);
    }
    if (this.timeoutTimer) {
      clearTimeout(this.timeoutTimer);
    }
    this.refreshing = false;
    this.isTimeOut = false;
    this.MqttUtil.unsubscribe("/devices/unbound/response",0)
    this.dispatcher.unregisterHandler('/devices/unbound/response')
    this.isSearching = false;
  }


  isDevicesEmpty(): boolean {
    return this.unboundDevicesDS.totalCount() === 0&&this.isTimeOut;
  }


}
