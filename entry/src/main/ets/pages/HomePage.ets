import { ColorConstants } from "../common/enums/ColorEnum"
import { DEVICE_UPDATE_EVENT, UserName } from "../common/constants/CommonConstants"
import { DeviceBase } from "../model/device/DeviceBase"
import { DeviceCard } from "../view/DeviceCard"

import { DeviceEnum } from "../common/enums/DeviceEnum";
import { AirConditionerDevice } from "../model/device/AirConditionerDevice";
import { DeviceDataSource } from "../model/DeviceDataSource";
import { HomePageViewModel } from "../viewmodel/HomePageViewModel";
import { emitter } from "@kit.BasicServicesKit";

@Component
export struct HomePage {
  @Consume('NavPathStack') pageStack: NavPathStack;
  @State viewModel: HomePageViewModel = HomePageViewModel.getInstance()
  @State deviceCount: number = 0;
  aboutToAppear(): void {
    let context = this.getUIContext().getHostContext() as Context;
    this.viewModel.initPreferences(context).then(() => {
      this.viewModel.loadDevices().then(() => {
        this.deviceCount = this.viewModel.deviceCount;
      });

    });
    emitter.on(DEVICE_UPDATE_EVENT, () => {
      console.info('设备更新事件触发')
        this.deviceCount = this.viewModel.deviceCount;
      }
    );
  }

  build() {
    Column() {
      this.CustomTitleBar()
      Scroll(){
        this.DeviceGrid()
      }
      .width('100%')
      .height("92%")
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ColorConstants.HOME_PAGE_BG_COLOR) // 页面整体背景
    .backgroundImage($r('app.media.img_home_bg'))
    .backgroundImageSize({ width:"100%" })
  }



  @Builder
  CustomTitleBar() {
    Row() {
      // 左侧主副标题
      Column() {
        Text(UserName+" 的家")
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(ColorConstants.BLACK)

        Text(this.deviceCount+" 个设备")
          .fontSize(14)
          .fontColor(ColorConstants.SUBTITLE_FONT_COLOR)
      }
      .alignItems(HorizontalAlign.Start) // 左对齐

      // 右侧“+”按钮
      Button({ type: ButtonType.Normal, stateEffect: true })
      {
        Image($r('app.media.icon_menu_add'))
          .width(28)
          .height(28)

      }
      .height(50)
      .width(50)
      .bindMenu(this.HomePageMenu)
      .backgroundColor(ColorConstants.HOME_PAGE_TITLE_BG_COLOR)
    }
    .width('100%')
    .height(60)
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween) // 左右分布
    .alignItems(VerticalAlign.Center)
    .backgroundColor(ColorConstants.HOME_PAGE_TITLE_BG_COLOR)
  }


  @Builder
  HomePageMenu() {
    Menu() {
      MenuItem({ content: "添加设备" })
        .onClick(() => {
          this.pageStack.pushPathByName('SearchDevicePage', '');
          console.log("添加设备")
        })
      MenuItem({ content: " Test" })
        .onClick(() => {
          this.viewModel.addDeviceTest();

        })
    }
  }
  @Builder
  DeviceGridItem(device:DeviceBase){
      DeviceCard({device})
        .width(340)

  }


  @Builder
  DeviceGrid(){
    Column(){
      Grid(){
        LazyForEach(this.viewModel.devicesDS, (device: DeviceBase) => {
          GridItem(){
            DeviceCard({device})
          }
        }, (device: DeviceBase) => device.getId())
      }
      .columnsTemplate('1fr 1fr')
      .rowsGap(20)//竖直方向的间隔
      .columnsGap(20)//水平方向的间隔
      .width("100%")
      .height("100%")
      .scrollBar(BarState.Off)//隐藏滚动条
      .align(Alignment.Top)
      .editMode(true)
      .supportAnimation(true) // 设置支持动画
      .onItemDragStart((event: ItemDragInfo, itemIndex: number) => { //第一次拖拽此事件绑定的组件时，触发回调。
        return this.DeviceGridItem(this.viewModel.devicesDS.getData(itemIndex))
      })
      .onItemDrop((event: ItemDragInfo, itemIndex: number, insertIndex: number, isSuccess: boolean) => { //绑定此事件的组件可作为拖拽释放目标，当在本组件范围内停止拖拽行为时，触发回调。
        // isSuccess=false时，说明drop的位置在grid外部；insertIndex > length时，说明有新增元素的事件发生
        if (!isSuccess || insertIndex >= this.viewModel.devicesDS.totalCount()) {
          return;
        }
        console.info('DeviceItem' + itemIndex + '', insertIndex + ''); //itemIndex拖拽起始位置，insertIndex拖拽插入位置
        this.viewModel.swapDevices(itemIndex, insertIndex);
      })

    }
    .width('100%')
    .height('100%')
    .padding(20)

  }




}
