// xxx.ets
import { ColorConstants } from "../common/enums/ColorEnum";
import { window } from "@kit.ArkUI";
import { EmsData } from "../model/EmsData";
import MQTTUtil from "../common/utils/MQTTUtil";
import { MqttMessageDispatcher } from "../common/utils/MqttMessageDispatcher";
import { ResultData } from "../model/ResultData";
import HttpUtil from "../common/utils/HttpUtil";
import { HomePageViewModel } from "../viewmodel/HomePageViewModel";

interface Message{
  text: string;
  isUser: boolean;
}
interface Answer{
  type: string;
  answer:  string;
}
@Component
export struct AIQaPage {
  scroller: Scroller = new Scroller();
  @State Text: string = '';
  @State keyboardHeight: number = 0; // Soft keyboard height
  @State TextPosition: string = "90%";
  @State messages: Array< Message> = []
  @State emsData:EmsData ={stat:0,gas:0,temp:0,hum:0};
  @State isBusy:boolean = false;


  aboutToAppear(): void {
    const mqttUtil = MQTTUtil.getInstance();
    const dispatcher = MqttMessageDispatcher.getInstance();
    const topic = "ems";
    const subscribeIfReady = () => {
      mqttUtil.subscribe(topic, 1);
      dispatcher.registerHandler(topic, (message: string) => {
        console.info('收到EMS数据：', message);
        try {
          const data = JSON.parse(message) as EmsData;
          this.emsData.stat = data.stat;
          this.emsData.gas = data.gas;
          this.emsData.temp = data.temp;
          this.emsData.hum = data.hum;
        } catch (e) {
          console.error('解析EMS数据失败：', e);
        }
      });
    };
    if (mqttUtil.isMqttConnected()) {
      subscribeIfReady();
    } else {
      let retries = 50;
      const intervalId = setInterval(() => {
        if (mqttUtil.isMqttConnected()) {
          clearInterval(intervalId);
          subscribeIfReady();
        } else {
          retries--;
          if (retries <= 0) {
            clearInterval(intervalId);
            console.warn('MQTT连接超时，EMS订阅失败');
          }
        }
      }, 100);
    }


    window.getLastWindow(this.getUIContext().getHostContext()).then(currentWindow => {
      currentWindow.on('keyboardHeightChange', (data: number) => {
        this.keyboardHeight = this.getUIContext().px2vp(data);
        console.info('keyboardHeightChange: ' + this.keyboardHeight);
      })
    })
  }

  build() {
    Stack() {
      Column(){
        Scroll(this.scroller) {
          Column({ space: 20 }) {
            ForEach(this.messages, (msg: Message, index: number) => {
              Row() {
                if (!msg.isUser) {
                  // AI 回答显示在左侧
                  Text(msg.text)
                    .fontSize(20)
                    .padding(10)
                    .backgroundColor('#e6f7ff')
                    .borderRadius(10)
                    .align(Alignment.Start)
                } else {
                  Blank() // 占位让右对齐更自然
                }

                if (msg.isUser) {
                  // 用户提问显示在右侧
                  Text(msg.text)
                    .fontSize(20)
                    .padding(10)
                    .backgroundColor('#d1eaff')
                    .borderRadius(10)
                    .align(Alignment.End)
                } else {
                  Blank()
                }
              }
              .width('100%')
              .padding({ left: 20, right: 20 })
              .justifyContent(FlexAlign.SpaceBetween)

            })
          }
          .padding(10)
          .justifyContent(FlexAlign.Start)
        }
        .scrollBar(BarState.Off)


      }
      .width("100%")
      .height("80%")
      .backgroundColor("#FFF9F0")


      // 顶部温湿度展示栏
      Row() {
        // 室内温度卡片
        Row() {
          Text('🌡室内温度 ')
            .fontSize(18)
            .margin({ right: 6 })
          Text(this.emsData.temp.toString())
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor('#222')
          Text('°C')
            .fontSize(18)
            .fontColor('#222')
            .margin({ top: 4 }) // 调整baseline对齐
        }
        .height(70)
        .padding({ top: 10, bottom: 10, left: 12, right: 12 })
        .backgroundColor('#ffffff')
        .borderRadius(12)
        .margin({ left: 12,right: 12 })
        .shadow({ radius: 4, color: '#ccc', offsetX: 1, offsetY: 2 })

        // 湿度卡片
        Row() {
          Text('💧室内湿度 ')
            .fontSize(18)
            .margin({ right: 6 })
          Text(this.emsData.hum.toString())
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor('#222')
            .margin({ top: 4 })
          Text('%')
            .fontSize(18)
            .fontColor('#888')
            .margin({ top: 4 })

        }
        .height(70)
        .padding({ top: 10, bottom: 10, left: 12, right: 12 })
        .backgroundColor('#ffffff')
        .borderRadius(12)
        .margin({ right: 12 })
        .shadow({ radius: 4, color: '#ccc', offsetX: 1, offsetY: 2 })
        // 湿度卡片
        Row() {
          Text('🔥可燃气体浓度 ')
            .fontSize(18)
            .margin({ right: 6 })
          Text(this.emsData.gas.toString())
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor('#222')
            .margin({ top: 4 })
          Text('ppm')
            .fontSize(18)
            .fontColor('#888')
            .margin({ top: 4 })

        }
        .height(70)
        .padding({ top: 10, bottom: 10, left: 12, right: 12 })
        .backgroundColor('#ffffff')
        .borderRadius(12)
        .shadow({ radius: 4, color: '#ccc', offsetX: 1, offsetY: 2 })

      }
      .position({x:0,y:0})
      .width('100%')
      .height("10%")
      .backgroundColor('#FFF9F0')
      .borderRadius(0)


      // 底部输入框
      Row() {
        TextArea({ placeholder: '请输入问题',text: this.Text })
          .onChange((value: string) => {
            this.Text = value;
          })
          .width("80%")
          .height(80)
          .backgroundColor('#ffffff')
          .borderRadius(10)
          .padding(5)
          .margin({left:10})

        Button(this.isBusy? '分析中':'发送')
          .height(40)
          .margin({ left: 20 })
          .enabled(!this.isBusy)
          .onClick(() => {
            if(this.Text.trim() === '') return;
            this.messages.push({ isUser: true, text: this.Text })
            setTimeout(() => {
              this.scroller.scrollEdge(Edge.End)
            }, 100)

            this.isBusy = true

            const param = `
              用户问题：${this.Text}
              当前环境：
              - 温度：${this.emsData.temp}°C
              - 湿度：${this.emsData.hum}%
              - 可燃气体浓度：${this.emsData.gas} ppm
              `;
            this.Text = ''

            HttpUtil.post<ResultData, string>('ai/analysis', param)
              .then((data: ResultData) => {
                //成功后处理数据
                if (data?.success) {
                  const resultString = `${data.data}`;
                  const ans:Answer = JSON.parse(resultString) as Answer;
                  if(ans.type==="cmd"){
                    const mqtt = MQTTUtil.getInstance();
                    mqtt.publish("/devices/dev101/set","set")
                  }
                  this.messages.push({ isUser: false, text: ans.answer })
                }
              })
              .finally(() => {
                //最后更新状态
                this.isBusy = false
                this.scroller.scrollEdge(Edge.End)
              })
              .catch((err: Error) => {
                console.error('请求出错：', err);
                this.messages.push({ isUser: false, text: '⚠️ 网络错误或服务器超时，请检查网络后重试。' });
              })



          })
      }
      .width("100%")
      .backgroundColor('#f8f8f8')
      .padding({ left: 20, right: 20, top: 10, bottom: 10 })
      .position({ top: (this.keyboardHeight === 0) ? "90%" : "60%" })

    }
    .width("100%")
    .height("100%")
  }
}