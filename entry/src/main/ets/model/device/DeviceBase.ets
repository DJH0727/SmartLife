import { DeviceEnum } from "../../common/enums/DeviceEnum";

export class DeviceBase {
   id: string;
   type: DeviceEnum;
   name: string;
   bindCode: string;
   online: boolean;
   isPowerOn: boolean;          // 开关状态
   lastUpdate: number;

  constructor(id: string, type: DeviceEnum, name: string, bindCode: string='', isPowerOn = false, online = false, lastUpdate = 0) {
    this.id = id;
    this.type = type;
    this.name = name;
    this.bindCode = bindCode;
    this.isPowerOn = isPowerOn;
    this.online = online;
    this.lastUpdate = lastUpdate;
  }

  isBound(): boolean {
    return this.bindCode !== '';
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

  getBindCode(): string {
    return this.bindCode;
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

  setBindCode(bindCode: string): void {
    this.bindCode = bindCode;
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

