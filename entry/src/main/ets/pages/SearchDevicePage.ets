import { DeviceBase } from "../model/device/DeviceBase";
import { DeviceEnum } from "../common/enums/DeviceEnum";
import { UnboundDeviceCard } from "../view/UnboundDeviceCard";
import { Prompt } from "@kit.ArkUI";
import { ColorConstants } from "../common/enums/ColorEnum";
import { SearchDeviceViewModel } from "../viewmodel/SearchDeviceViewModel";


@Builder
export function SearchDevicePageBuilder() {
  SearchDevicePage()
}

@Component
struct SearchDevicePage {
  @Consume('NavPathStack') pageStack: NavPathStack;
  @State viewModel: SearchDeviceViewModel = new SearchDeviceViewModel();
  @State refreshOffset: number = 0;
  @State refreshState: RefreshStatus = RefreshStatus.Inactive;



  aboutToAppear(): void {
    this.viewModel.startSearchDevices();
  }

  aboutToDisappear(): void {
    this.viewModel.stopSearchDevices();
  }


  build() {
    NavDestination(){
      this.SearchPageTitleBar("添加设备")
      Divider().height(2).color(0xCCCCCC)

        this.UnboundDeviceList()
    }
    .width("100%")
    .height("100%")
    .hideTitleBar(true)
    .backgroundColor(ColorConstants.SEARCH_PAGE_BG_COLOR)



  }

  @Builder
  EmptyDeviceNotify() {
    Column() {
      Text("没有找到设备")
        .fontSize(20)
    }
    .width("100%")
    .height("100%")
  }

  @Builder
  UnboundDeviceList() {
    Refresh({ refreshing: $$this.viewModel.refreshing, builder: this.refreshBuilder() }) {

      List() {
        LazyForEach(this.viewModel.unboundDevicesDS, (device: DeviceBase) => {
          ListItem() {
            UnboundDeviceCard({ device })
              .width("100%")
              //.onClick(() => this.viewModel.bindDevice(device))
          }
          .margin({ bottom: 20 })
        }, (device: DeviceBase) => device.getId())
      }
      .width("100%")
      .height("100%")
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })

    }
    .padding(20)
    .onOffsetChange((offset: number) => this.refreshOffset = offset)
    .onStateChange((state: RefreshStatus) => this.refreshState = state)
    .onRefreshing(() => this.onRefresh())
  }



  @Builder
  refreshBuilder() {
    Stack({ alignContent: Alignment.Bottom }) {
      if (this.refreshState !== RefreshStatus.Inactive && this.refreshState !== RefreshStatus.Done) {
        Progress({ value: this.refreshOffset, total: 64, type: ProgressType.Ring })
          .width(32).height(32)
          .style({ status: this.viewModel.refreshing ? ProgressStatus.LOADING : ProgressStatus.PROGRESSING })
          .margin(10)
      }
    }
    .clip(true)
    .height("100%")
    .width("100%")
  }

  private onRefresh() {
    this.viewModel.refreshUnboundDevices();
  }


  @Builder
  SearchPageTitleBar(content: string) {
    Row() {

      Row(){
        Image($r('app.media.icon_back'))
        .width(24)
        .height(24)
        .onClick(() => {
          this.pageStack.pop();
        })

        Text(content)
          .fontSize(20)
          .fontColor('#000000')
          .margin({ left: 10 })
      }
      Button({ type: ButtonType.Normal, stateEffect: true })
      {
        Image($r('app.media.icon_help'))
          .width(24)
          .height(24)
      }
      .height(50)
      .width(50)
      .backgroundColor(ColorConstants.SEARCH_PAGE_TITLE_BG_COLOR)
    }
    .width('100%')
    .height(50)
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween) // 左右分布
    .alignItems(VerticalAlign.Center)
    .backgroundColor(ColorConstants.SEARCH_PAGE_TITLE_BG_COLOR)
  }

}
