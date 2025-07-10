import prompt from '@ohos.prompt';
import { ColorConstants } from '../common/enums/ColorEnum';
import { AirConditionerDevice } from '../model/device/AirConditionerDevice';
import { DeviceBase } from '../model/device/DeviceBase';
import promptAction from '@ohos.promptAction';
import { DeviceEnum } from '../common/enums/DeviceEnum';
import { HomePageViewModel } from '../viewmodel/HomePageViewModel';

@Preview
@Component
export  struct DeviceCard {
  @Prop device: DeviceBase
  private timerId: number | undefined;

  aboutToAppear(): void {
    console.info('设备已添加：' + this.device.getName())
    const topic = `/devices/${this.device.id}/heartbeat`;
    const mqttUtil = HomePageViewModel.getInstance().MqttUtil;
    const dispatcher = HomePageViewModel.getInstance().dispatcher;

    const subscribeIfReady = () => {
      mqttUtil.subscribe(topic, 0);
      dispatcher.registerHandler(topic, (message: string) => {
        console.info('收到心跳：' + topic);
        this.device.setOnline(true);
        this.device.setLastUpdate(Date.now());

        if (this.timerId !== undefined) {
          clearTimeout(this.timerId);
        }

        this.timerId = setTimeout(() => {
          this.device.setOnline(false);
          console.info('心跳超时：' + topic);
        }, 25000);
      });
    };

    if (mqttUtil.isMqttConnected()) {
      // 立即订阅
      subscribeIfReady();
    } else {
      // 循环等待 MQTT 连接成功（最多等 5 秒，100ms 一次）
      let retries = 50;
      const waitInterval = setInterval(() => {
        if (mqttUtil.isMqttConnected()) {
          clearInterval(waitInterval);
          console.info('MQTT连接成功，延迟订阅：' + topic);
          subscribeIfReady();
        } else {
          retries--;
          if (retries <= 0) {
            clearInterval(waitInterval);
            console.warn('等待MQTT连接超时，未能订阅：' + topic);
          }
        }
      }, 100); // 每 100ms 检查一次
    }
  }


  aboutToDisappear(): void {
    const topic = `/devices/${this.device.id}/heartbeat`;
    HomePageViewModel.getInstance().MqttUtil.unsubscribe(topic);
    HomePageViewModel.getInstance().dispatcher.unregisterHandler(topic);

    if (this.timerId !== undefined) {
      clearTimeout(this.timerId);
    }
  }

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
          //TODO: 模拟控制设备开关
          //向/devices/this.device.id/set 发送命令
          if(!this.device.isOnline()){
            promptAction.showToast({ message: this.device.getName() + ' 设备未连接' })
            return;
          }
          const rc =  HomePageViewModel.getInstance().sendSetRequest(this.device.id,'set')
          if(!rc){
            promptAction.showToast({ message: this.device.getName() + ' 操作失败' })
            return;
          }
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
