import { DeviceBase } from './DeviceBase';
import { DeviceEnum } from '../../common/enums/DeviceEnum';


export enum FanSpeed {
  LOW =0,
  MEDIUM = 1,
  HIGH = 2,
}

export enum Mode {
  COOL = 0,
  HEAT = 1,
  DRY = 2,
}
export class AirConditionerDevice extends DeviceBase {
   currentTemperature: number; // 当前温度
   targetTemperature: number;  // 目标温度
   fanSpeed: FanSpeed;         // 风速
   mode: Mode;               // 模式

  constructor(
    id: string,
    name: string,
    bindCode: string='',
    isPowerOn = false,
    currentTemperature = 25,
    targetTemperature = 26,
    fanSpeed = FanSpeed.MEDIUM,
    mode = Mode.COOL,
    online = false,
    lastUpdate = 0
  ) {
    super(id, DeviceEnum.AIR_CONDITIONER, name, bindCode,isPowerOn, online, lastUpdate);
    this.currentTemperature = currentTemperature;
    this.targetTemperature = targetTemperature;
    this.fanSpeed = fanSpeed;
    this.mode = mode;
  }

  getCurrentTemperature(): number {
    return this.currentTemperature;
  }

  setCurrentTemperature(temp: number): void {
    this.currentTemperature = temp;
    this.setLastUpdate(Date.now());
  }

  getTargetTemperature(): number {
    return this.targetTemperature;
  }

  setTargetTemperature(temp: number): void {
    this.targetTemperature = temp;
    this.setLastUpdate(Date.now());
  }

  getMode(): number {
    return this.mode;
  }
  setMode(mode: Mode): void {
    this.mode = mode;
  }
  getFanSpeed(): number {
    return this.fanSpeed;
  }
  setFanSpeed(speed: FanSpeed): void {
    this.fanSpeed = speed;
  }


}
