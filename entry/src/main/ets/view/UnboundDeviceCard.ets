import promptAction from '@ohos.promptAction';
import { DeviceBase } from '../model/device/DeviceBase';
import { ColorConstants } from '../common/enums/ColorEnum';
import { HomePageViewModel } from '../viewmodel/HomePageViewModel';
import { CustomContentDialog } from '@kit.ArkUI';

@Preview
@Component
export struct UnboundDeviceCard {
  @Prop device: DeviceBase;
  private isBoundSuccess: boolean = false;

  build() {
    Row() {
      // 左侧图片
      Image($r(this.device.getImage()))
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
        this.checkDialogController.open()
        //viewModel.addDeviceTest();
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




  checkDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      primaryTitle: '确认绑定这个设备吗',
      secondaryTitle: this.device.id,
      contentBuilder: () => {
        this.buildContent();
      },
      buttons: [
        {
          value: '取消',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
            console.info("取消绑定")
          }
        },
        {
          value: '确认',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          role: ButtonRole.ERROR,
          action: () => {
            this.boundDialogController.open()
            const  viewModel: HomePageViewModel = HomePageViewModel.getInstance()
            this.isBoundSuccess = viewModel.boundDevice(this.device)
            //this.boundDialogController.close()
            //this.resultDialogController.open()

            console.info('尝试绑定设备：' + this.device.getId());
          }
        }
      ],
    }),
  });

  @Builder
  buildContent(){
    Row(){
      Image($r(this.device.getImage()))
        .height(120)
    }
    .width("100%")
    .justifyContent(FlexAlign.Center)
    .backgroundColor(ColorConstants.TRANSPARENT)
  }


  boundDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      primaryTitle: '绑定中，请在设备确定',
      secondaryTitle: this.device.id,
      contentBuilder: () => {
        this.boundLoadingBuilder();
      },
      buttons: [{
          value: '取消',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
            console.info("取消绑定")
          }
        }]
    }),
  });

  @Builder
  boundLoadingBuilder(){
    Row(){
      Column() {
        LoadingProgress()
          .color(Color.Blue)
          .layoutWeight(1)
          .width(40)
          .height(40)

        Text('绑定中...')
          .margin({ top: 8 })
          .fontSize(16)
          .fontColor(ColorConstants.GRAY)
      }
      .height(100)
      Image($r(this.device.getImage()))
        .height(120)
    }
    .width("100%")
    .justifyContent(FlexAlign.Center)
    .backgroundColor(ColorConstants.TRANSPARENT)
  }

  resultDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      primaryTitle: this.isBoundSuccess?'绑定成功':'绑定失败',
      secondaryTitle: this.device.id,
      contentBuilder: () => {
      },
      theme:{colors:{fontPrimary:ColorConstants.ERROR_RED}},
      buttons: [{
        value: '确定',
        buttonStyle: ButtonStyleMode.TEXTUAL,
        action: () => {
        }
      }]
    }),
  });





}
