import promptAction from '@ohos.promptAction';
import { DeviceBase } from '../model/device/DeviceBase';
import { ColorConstants } from '../common/enums/ColorEnum';
import { HomePageViewModel } from '../viewmodel/HomePageViewModel';
import { CustomContentDialog } from '@kit.ArkUI';

@Preview
@Component
export struct UnboundDeviceCard {
  @Prop device: DeviceBase;
  @State isBoundSuccess: boolean = false;
  private newName: string = '';

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
        Text(this.isBoundSuccess ? '已绑定' :'绑定')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(ColorConstants.WHITE);
      }
      .width(80)
      .height(36)
      .backgroundColor(this.isBoundSuccess?ColorConstants.DEVICE_BOUND_BUTTON_COLOR:ColorConstants.DEVICE_UNBOUND_BUTTON_COLOR)
      .borderRadius(18)
      .enabled(!this.isBoundSuccess)
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
          action: async () => {
            this.boundDialogController.open();

            const viewModel: HomePageViewModel = HomePageViewModel.getInstance();

            // 等待绑定操作完成
            this.isBoundSuccess = await viewModel.boundDevice(this.device.getId());
            console.info('尝试绑定设备：' + this.device.getId()+ ' ' + this.isBoundSuccess);
            // 关闭加载弹窗，显示结果
            this.boundDialogController.close();
            this.resultDialogController.open();


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
            const viewModel: HomePageViewModel = HomePageViewModel.getInstance();
            viewModel.cancelBind(this.device.getId());
          }
        }]
    }),
    autoCancel:false
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
        if(this.isBoundSuccess) {
          this.successContentBuilder();
        }
        else {
          this.failContentBuilder();
        }
      },
      theme:{colors:{fontPrimary:this.isBoundSuccess?ColorConstants.SUCCESS_GREEN:ColorConstants.ERROR_RED}},
    }),
    autoCancel:false
  });

  @Builder
  successContentBuilder(){
    Column() {
        Text('设备名称：')
          .fontSize(16)
          .fontColor(ColorConstants.BLACK)
          .margin({ bottom: 6 })

        TextInput({ text: this.device.getName() })
          .width('80%')
          .height(40)
          .backgroundColor('#F0F0F0')
          .fontColor(ColorConstants.BLACK)
          .borderRadius(8)
          .padding({ left: 8, right: 8 })
          .onChange((val: string) => {
            this.newName = val
          })

      Button() {
        Text('确定')
          .fontSize(20)
          .fontColor(ColorConstants.IOS_BLUE)
      }
      .margin({ top: 16 })
      .width("100%")
      .height(24)
      .backgroundColor(ColorConstants.TRANSPARENT)
      .onClick(() => {
        // 更新设备名称
        this.device.name = this.newName;
        this.device.setOnline(true);
        const viewModel: HomePageViewModel = HomePageViewModel.getInstance();
        viewModel.addDevice(this.device);
        // 关闭弹窗
        this.resultDialogController.close();

        console.info('设备名称已修改为：' + this.newName);
      });


    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  failContentBuilder(){
    Column() {
      Button() {
        Text('确定')
          .fontSize(20)
          .fontColor(ColorConstants.IOS_BLUE)
      }
      .width("100%")
      .height(40)
      .backgroundColor(ColorConstants.TRANSPARENT)
      .onClick(() => {
        this.resultDialogController.close();
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }






}
