import promptAction from '@ohos.promptAction';
import { DeviceBase } from '../model/device/DeviceBase';
import { ColorConstants } from '../common/enums/ColorEnum';

@Preview
@Component
export struct UnboundDeviceCard {
  @Prop device: DeviceBase;

  build() {
    Row() {
      // 左侧图片
      Image($r('app.media.img_device_test'))
        .height(96)
        .borderRadius(96)
        .objectFit(ImageFit.Contain);

      // 中间两行文字
      Column() {
        Text(this.device.getName())
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(ColorConstants.BLACK)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .align(Alignment.Start);

        Text(this.device.getId())
          .fontSize(14)
          .fontWeight(FontWeight.Normal)
          .fontColor(ColorConstants.GRAY)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .align(Alignment.Start);
      }
      .width('60%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center);

      // 右侧绑定按钮
      Button() {
        Text('绑定')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(ColorConstants.WHITE);
      }
      .width(80)
      .height(36)
      .backgroundColor(ColorConstants.DEVICE_BOUND_BUTTON_COLOR)
      .borderRadius(18)
      .onClick(() => {
        console.info('绑定设备：' + this.device.getName());
      });
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
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center);
  }
}
