import { DeviceBase } from './DeviceBase';
import { DeviceEnum } from '../../common/enums/DeviceEnum';


export enum FanSpeed {
  LOW = 'low',
  MEDIUM = 'medium',
  HIGH = 'high',
}

export enum Mode {
  COOL = 'cool',
  HEAT = 'heat',
  DRY = 'dry',
}
export class AirConditionerDevice extends DeviceBase {
  private currentTemperature: number; // 当前温度
  private targetTemperature: number;  // 目标温度
  private isPowerOn: boolean;          // 开关状态
  private fanSpeed: FanSpeed;         // 风速
  private mode: Mode;               // 模式

  constructor(
    id: string,
    name: string,
    bindCode: string,
    currentTemperature = 25,
    targetTemperature = 26,
    isPowerOn = false,
    fanSpeed = FanSpeed.MEDIUM,
    mode = Mode.COOL,
    online = false,
    lastUpdate = 0
  ) {
    super(id, DeviceEnum.AIR_CONDITIONER, name, bindCode, online, lastUpdate);
    this.currentTemperature = currentTemperature;
    this.targetTemperature = targetTemperature;
    this.isPowerOn = isPowerOn;
    this.fanSpeed = fanSpeed;
    this.mode = mode;
  }

  getCurrentTemperature(): number {
    return this.currentTemperature;
  }

  setCurrentTemperature(temp: number): void {
    this.currentTemperature = temp;
    this.lastUpdate = Date.now();
  }

  getTargetTemperature(): number {
    return this.targetTemperature;
  }

  setTargetTemperature(temp: number): void {
    this.targetTemperature = temp;
    this.lastUpdate = Date.now();
  }

  getPowerStatus(): boolean {
    return this.isPowerOn;
  }

  setPowerStatus(on: boolean): void {
    this.isPowerOn = on;
    this.lastUpdate = Date.now();
  }
  getMode(): string {
    return this.mode;
  }
  setMode(mode: Mode): void {
    this.mode = mode;
  }
  getFanSpeed(): string {
    return this.fanSpeed;
  }
  setFanSpeed(speed: FanSpeed): void {
    this.fanSpeed = speed;
  }


}
