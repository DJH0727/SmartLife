
import { DeviceDataSource } from "../model/DeviceDataSource";
import { AirConditionerDevice } from "../model/device/AirConditionerDevice";
import { DeviceBase } from "../model/device/DeviceBase";
import preferences from '@ohos.data.preferences';
import { DeviceEnum, getDeviceType } from "../common/enums/DeviceEnum";


export class HomePageViewModel {
  devicesDS: DeviceDataSource;
  deviceCount: number;
  private preferenceDevices: preferences.Preferences | undefined;

  constructor() {
    this.devicesDS = new DeviceDataSource([]);
    this.deviceCount = this.devicesDS.totalCount();
  }

  public async initPreferences(context: Context) {
    this.preferenceDevices = await preferences.getPreferences(context, 'bound_devices_pref');
    console.info('BoundDevices Preferences 初始化完成');
  }

  swapDevices(index1: number, index2: number) {
    if (index1 === index2) return;
    this.devicesDS.swapItem(index1, index2);
    this.devicesDS.notifyDataMove(index1, index2);
    this.devicesDS.notifyDataReload();
    this.saveDevices();
  }

  addDeviceTest(){
    const device = new AirConditionerDevice('dev004', '测试设备', 'BIND004', true);
    this.devicesDS.addDevice(device);
    this.deviceCount = this.devicesDS.totalCount();
    this.saveDevices();
  }


  async saveDevices() {
     if (this.preferenceDevices) {
       await this.preferenceDevices.put('devices_json', JSON.stringify(this.devicesDS.getAllData()));
       await this.preferenceDevices.flush();
       console.info('BoundDevices 保存成功');
     } else {
       console.error('Preferences 未初始化，无法保存');
     }
  }


  async loadDevices() {
    if (this.preferenceDevices) {
      try {
        let stored:string ='';
        stored = await this.preferenceDevices.get('devices_json', '') as string;
        console.info('从 Preferences 读取设备数据:' + stored);
        if (stored.length > 0) {
          const devices: DeviceBase[] = this.getDevicesFromStorage(stored);
          this.devicesDS.addDevices(devices)
          this.deviceCount = this.devicesDS.totalCount();
          console.info('设备加载并初始化完成，共 '+ this.deviceCount +' 个设备');
        } else {
          console.info('Preferences 中没有保存的设备数据，保持空设备列表');
        }
      } catch (e) {
        console.error('从 Preferences 加载设备失败:', JSON.stringify(e));
      }
    } else {
      console.error('Preferences 未初始化，无法加载设备');
    }
  }


  private getDevicesFromStorage(stored: string):  DeviceBase[]  {
    const parsed: DeviceBase[] = JSON.parse(stored);
    const devices: DeviceBase[] = [];
    for (let i = 0; i < parsed.length; i++) {
      const type = getDeviceType(parsed[i].type)
      switch (type) {
        case DeviceEnum.AIR_CONDITIONER:
          const raw = parsed[i] as AirConditionerDevice;
          devices.push(new AirConditionerDevice(
            raw.id,
            raw.name,
            raw.bindCode,
            raw.isPowerOn,
            raw.currentTemperature,
            raw.targetTemperature,
            raw.fanSpeed,
            raw.mode,
            raw.online,
            raw.lastUpdate
          ));
          break;

      }
    }
    return devices;

  }





}
