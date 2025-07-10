import { DeviceEnum } from "../../common/enums/DeviceEnum";

export class DeviceBase {
   id: string;
   type: DeviceEnum;
   name: string;
   isBind: boolean;;
   online: boolean;
   isPowerOn: boolean;          // 开关状态
   lastUpdate: number;
   image: string = 'app.media.img_device_test';

  constructor(id: string, type: DeviceEnum, name: string, isBind:boolean=false, isPowerOn = false, online = false, lastUpdate = 0) {
    this.id = id;
    this.type = type;
    this.name = name;
    this.isBind = isBind;
    this.isPowerOn = isPowerOn;
    this.online = online;
    this.lastUpdate = lastUpdate;
  }
  getImage(): string {
    switch (this.type) {
      //TODO: 拓展
      case DeviceEnum.AIR_CONDITIONER:
        return "app.media.img_device_ac";
      case DeviceEnum.HUMIDIFIER:
        return "app.media.img_device_humi";
      case DeviceEnum.GAS_DETECTOR:
        return "app.media.img_device_test";
      case DeviceEnum.SPEAKER:
        return "app.media.img_device_speaker";
      default:
        return "app.media.img_device_test";
    }
  }

  isBound(): boolean {
   return this.isBind;
  }

  // ===== Getters =====
  getId(): string {
    return this.id;
  }

  getType(): DeviceEnum {
    return this.type;
  }

  getName(): string {
    return this.name;
  }

  setBound(isBound: boolean): void {
      this.isBind = isBound;
  }

  isOnline(): boolean {
    return this.online;
  }

  getPowerStatus(): boolean {
    return this.isPowerOn;
  }

  getLastUpdate(): number {
    return this.lastUpdate;
  }

  // ===== Setters =====
  setId(id: string): void {
    this.id = id;
  }

  setType(type: DeviceEnum): void {
    this.type = type;
  }

  setName(name: string): void {
    this.name = name;
  }


  setOnline(online: boolean): void {
    this.online = online;
  }

  setPowerStatus(isPowerOn: boolean): void {
    this.isPowerOn = isPowerOn;
  }

  setLastUpdate(lastUpdate: number): void {
    this.lastUpdate = lastUpdate;
  }
}

