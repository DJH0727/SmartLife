import { DeviceEnum } from "../../common/enums/DeviceEnum";

export class DeviceBase {
  id: string;
  type: DeviceEnum;
  name: string;
  bindCode: string;
  online: boolean;
  lastUpdate: number;

  constructor(id: string, type: DeviceEnum, name: string, bindCode: string, online = false, lastUpdate = 0) {
    this.id = id;
    this.type = type;
    this.name = name;
    this.bindCode = bindCode;
    this.online = online;
    this.lastUpdate = lastUpdate;
  }

  isBound(): boolean {
    return this.bindCode !== '';
  }
}
