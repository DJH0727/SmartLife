import { DeviceBase } from "./device/DeviceBase";
export class DeviceDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private devices: DeviceBase[];

  constructor(devices: DeviceBase[]) {
    this.devices = devices;
  }

  totalCount(): number {
    return this.devices.length;
  }

  getData(index: number): DeviceBase {
    return this.devices[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (!this.listeners.includes(listener)) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => listener.onDataMove(from, to));
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => listener.onDataAdd(index));
  }

  // 通知LazyForEach组件在index对应索引处数据有变化，需要重建该子组件
  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
      // 写法2：listener.onDatasetChange([{type: DataOperationType.CHANGE, index: index}]);
    });
  }
  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    });
  }


  swapItem(from: number, to: number): void {
    const item = this.devices.splice(from, 1)[0];
    this.devices.splice(to, 0, item);
    this.notifyDataMove(from, to);
  }
  notifyDatasetChange(operations: DataOperation[]): void {
    this.listeners.forEach(listener => {
      listener.onDatasetChange(operations);
    });
  }

  addDevice(device: DeviceBase): void {
    const exists = this.devices.some(d => d.getId() === device.getId());
    if (exists) {
      console.info(`设备 ${device.getId()} 已存在，跳过添加`);
      return;
    }
    this.devices.push(device);
    this.notifyDataAdd(this.devices.length - 1);
  }
}
