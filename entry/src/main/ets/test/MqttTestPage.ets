import { MQTT_URL } from "../common/constants/CommonConstants";
import MQTTUtil, { MQTTConnectOptions, MQTTSubscription } from "../common/utils/MQTTUtil";


@Component
export struct MqttTestPage {
  @State connected: boolean = false;
  @State messages: string[] = [];

  private mqtt = MQTTUtil.getInstance();

  private async connect() {
    const options: MQTTConnectOptions = {
      url: MQTT_URL,
      clientId: 'arkts_client',
      username: 'user',
      password: 'pass',
      connectTimeout: 300,
    };
    const subscriptions: MQTTSubscription[] = [];
    const success = await this.mqtt.connect(
      options,
      subscriptions,
      (err, message) => {
        if (err) {
          console.error('MQTT接收消息出错:', err);
          return;
        }

        const topic = message.topic;
        const payload = message.payload?.toString() ?? '';

        console.log(`收到消息 - 主题: ${topic}, 内容: ${payload}`);
        this.messages.push(`${topic}: ${payload}`);

      }
    );
    this.connected = success;
  }



  private async subscribeTopic() {
    if (!this.connected) return;
    await this.mqtt.subscribe('test/topic', 0);
  }

  private async publishMsg() {
    if (!this.connected) return;
    await this.mqtt.publish('test/topic', 'Hello from ArkTS Test', 0);
  }

  @Builder
  build() {
    Column() {
      Text("MQTT测试页面")
        .fontSize(24)
        .fontWeight('bold')
        .margin({ bottom: 20 })

      Row() {
        Button('连接MQTT').onClick(() => { this.connect(); }).margin({ right: 10 })
        Button('订阅主题').onClick(() => { this.subscribeTopic(); }).margin({ right: 10 })
        Button('发送消息').onClick(() => { this.publishMsg(); })
      }.margin({ bottom: 20 })

      Scroll() {
        Column() {
          ForEach(this.messages, (msg:string) => {
            Text(msg)
              .fontSize(16)
              .fontColor(Color.Black)
          })
        }
      }.height(300).width('100%').backgroundColor('#f0f0f0')
    }.padding(20).width('100%').height('100%').backgroundColor('#fff')
  }
}
