import { DeviceEnum } from "../common/enums/DeviceEnum";
import { DeviceBase } from "../model/device/DeviceBase";
import { DeviceDataSource } from "../model/DeviceDataSource";

export class SearchDeviceViewModel {
  unboundDevicesDS: DeviceDataSource;
  refreshing: boolean = false;
  private searchTimer?: number;
  private timeoutTimer?: number;
  private isTimeOut: boolean = false;

  constructor() {
    this.unboundDevicesDS = new DeviceDataSource([]);
  }

  // 模拟刷新逻辑
  refreshUnboundDevices() {
    console.info("正在刷新设备列表...");
    setTimeout(() => {
      // 这里为了演示，直接清空并加入一个新设备
      this.unboundDevicesDS.addDevice(new DeviceBase("dev103", DeviceEnum.AIR_CONDITIONER, "卧室空调", ""))
      this.unboundDevicesDS.notifyDataReload();
      this.refreshing = false;
    }, 1500);

  }

  loadUnboundDevices() {
    const initialDevices = [
      new DeviceBase("dev100", DeviceEnum.AIR_CONDITIONER, "客厅空调", ""),
      new DeviceBase("dev101", DeviceEnum.HUMIDIFIER, "卧室加湿器", ""),
    ];
    this.unboundDevicesDS = new DeviceDataSource(initialDevices);
  }

  startSearchDevices() {
    console.info("开始搜索设备...");

    const simulatedDevices = [
      new DeviceBase("dev100", DeviceEnum.AIR_CONDITIONER, "客厅空调", ""),
      new DeviceBase("dev101", DeviceEnum.HUMIDIFIER, "卧室加湿器", ""),
      new DeviceBase("dev102", DeviceEnum.GAS_DETECTOR, "厨房燃气报警器", "")
    ];

    this.searchTimer = setInterval(() => {
      if (this.isTimeOut) {
        clearInterval(this.searchTimer);
        console.info("搜索超时，停止搜索。");
        this.refreshing = false;
        return;
      }
      this.unboundDevicesDS.addDevice(simulatedDevices[Math.floor(Math.random() * 3)]);
    }, 1000); // 每隔 1 秒发现一个设备

    // 超时时间设置，例如5秒
    this.timeoutTimer = setTimeout(() => {
      this.isTimeOut = true;
    }, 5000);
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
  }




  bindDevice(device: DeviceBase) {
    device.setBindCode("BIND_" + device.getId());
    console.info("已绑定设备：" + device.getName());
    //this.unboundDevices = this.unboundDevices.filter(d => d.getId() !== device.getId());
  }

}
