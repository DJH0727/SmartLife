import prompt from '@ohos.prompt';
import { ColorConstants } from '../common/enums/ColorEnum';
import { AirConditionerDevice } from '../model/device/AirConditionerDevice';
import { DeviceBase } from '../model/device/DeviceBase';
import promptAction from '@ohos.promptAction';
import { DeviceEnum } from '../common/enums/DeviceEnum';

@Preview
@Component
export  struct DeviceCard {
  @Prop device: DeviceBase

  build() {
    Column({space: 8}) {

      Column(){
        Text(this.device.getName())
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(ColorConstants.BLACK)
          .align(Alignment.Start);
        Text(this.device.isOnline() ? '在线' : '离线')
          .fontSize(14)
          .fontColor(this.device.isOnline() ?ColorConstants.DEVICE_ONLINE_COLOR : ColorConstants.DEVICE_OFFLINE_COLOR)
          .align(Alignment.Start);

      }
      .width("100%")
      .alignItems(HorizontalAlign.Start)

      Row() {
        Image($r(this.device.getImage()))
          .height(72)
          .borderRadius(24)
          .objectFit(ImageFit.Contain)
          //.backgroundColor(ColorConstants.SUCCESS_GREEN)

        // 右下角快捷开关
        // 点击图片切换状态
        Button(){
          Image( $r('app.media.icon_device_switch') )
            .width(24)
            .height(24)
        }
        .width(36)
        .height(36)
        .backgroundColor(this.device.getPowerStatus() ? ColorConstants.DEVICE_POWER_ON_COLOR : ColorConstants.DEVICE_POWER_OFF_COLOR)
        .onClick(() => {
          const isPowerOn = !this.device.getPowerStatus();
          this.device.setPowerStatus(isPowerOn);
          const msg = isPowerOn? '已开启' : '已关闭';
          promptAction.showToast({ message: this.device.getName() + ' ' + msg })
        });
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Bottom)


    }
    .width('100%')
    .height(150)
    .padding(16)
    .backgroundColor(ColorConstants.DEVICE_CARD_BG_COLOR)
    .linearGradient({
      angle: 90,
      colors: [ [0xffffff, 0.8], [0xffffff, 0.6], [0xffffff, 0.4], [0xffffff, 0.6], [0xffffff, 0.8]]
    })
    .borderRadius(16)
    .shadow({ radius: 2, color: ColorConstants.GRAY, offsetX: 0, offsetY: 4 })
    .onAppear(() => {

    })

  }
}
