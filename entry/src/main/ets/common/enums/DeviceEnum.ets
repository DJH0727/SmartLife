export enum DeviceEnum {
  AIR_CONDITIONER = 'air_conditioner',
  HUMIDIFIER = 'humidifier',
  GAS_DETECTOR = 'gas_detector',
  SPEAKER = 'speaker',
  UNKNOWN = 'unknown'
  // 你可以根据需求继续添加更多设备类型
}

export function getDeviceType(type:string):DeviceEnum{
  switch (type) {
    case 'air_conditioner': return DeviceEnum.AIR_CONDITIONER;
    case 'humidifier': return DeviceEnum.HUMIDIFIER;
    case 'gas_detector': return DeviceEnum.GAS_DETECTOR;
    case 'speaker': return DeviceEnum.SPEAKER;
    default : return DeviceEnum.UNKNOWN;
  }
}