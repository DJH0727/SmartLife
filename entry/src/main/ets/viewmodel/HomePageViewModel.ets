// viewmodel/HomePageViewModel.ets
import { DeviceDataSource } from "../model/DeviceDataSource";
import { AirConditionerDevice } from "../model/device/AirConditionerDevice";

export class HomePageViewModel {
  devicesDS: DeviceDataSource;

  constructor() {
    const devices = [
      new AirConditionerDevice('dev001', '客厅空调', 'BIND001', true),
      new AirConditionerDevice('dev002', '卧室加湿器', 'BIND002', false),
      new AirConditionerDevice('dev003', '厨房燃气报警器', 'BIND003', true)
    ];
    this.devicesDS = new DeviceDataSource(devices);
  }

  swapDevices(index1: number, index2: number) {
    if (index1 === index2) return;
    this.devicesDS.swapItem(index1, index2);
    this.devicesDS.notifyDataMove(index1, index2);
    this.devicesDS.notifyDataReload();
  }
}
