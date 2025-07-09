import prompt from '@ohos.prompt';
import { ColorConstants } from '../common/enums/ColorEnum';
import { AirConditionerDevice } from '../model/device/AirConditionerDevice';
import { DeviceBase } from '../model/device/DeviceBase';
import { DeviceCard } from '../view/DeviceCard';


@Component
export  struct DeviceCardTestPage {
  @State private device: DeviceBase = new AirConditionerDevice('ac01', '客厅空调',true);

  build() {
    Column() {
      Grid(){
        GridItem() {
          DeviceCard({
            device: this.device,
          })
        }
        GridItem() {
          DeviceCard({
            device: this.device,
          })
        }
        GridItem() {
          DeviceCard({
            device: this.device,
          })
        }
        GridItem() {
          DeviceCard({
            device: this.device,
          })
        }
      }
      .columnsTemplate('1fr 1fr')
      .rowsGap(20)//竖直方向的间隔
      .columnsGap(20)//水平方向的间隔
      .width("100%")
      .height("90%")
      .scrollBar(BarState.Off)//隐藏滚动条
      .align(Alignment.Top)



    }
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor(ColorConstants.HOME_PAGE_BG_COLOR)
  }
}
