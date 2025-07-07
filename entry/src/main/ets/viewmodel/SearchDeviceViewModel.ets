import { DeviceEnum } from "../common/enums/DeviceEnum";
import { DeviceBase } from "../model/device/DeviceBase";


// viewmodel/SearchDeviceViewModel.ets
export class SearchDeviceViewModel {
  unboundDevices: DeviceBase[] = [];
  refreshing: boolean = false;

  refreshUnboundDevices() {
    console.info("ViewModel刷新中...");
    setTimeout(() => {
      this.unboundDevices = [
        new DeviceBase("dev200", DeviceEnum.AIR_CONDITIONER, "新的设备", ""),
      ];
      this.refreshing = false;
    }, 1500);
  }

  loadUnboundDevices() {
    this.unboundDevices = [
      new DeviceBase("dev100", DeviceEnum.AIR_CONDITIONER, "客厅空调", ""),
      new DeviceBase("dev101", DeviceEnum.HUMIDIFIER, "卧室加湿器", ""),
    ];
  }

  bindDevice(device: DeviceBase) {
    device.setBindCode("BIND_" + device.getId());
    this.unboundDevices = this.unboundDevices.filter(d => d.getId() !== device.getId());
  }
}
