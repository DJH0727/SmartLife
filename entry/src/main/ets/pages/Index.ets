import {ColorConstants} from '../common/enums/ColorEnum'
import { HomePage } from './HomePage';
import { ProfilePage } from './ProfilePage';
import { MqttTestPage } from '../test/MqttTestPage';
import { DeviceCardTestPage } from '../test/DeviceCardTestPage';
@Entry
@Component
struct Index {

  @Provide('NavPathStack') pageStack: NavPathStack = new NavPathStack()
  @State currentTab: number = 0;
  aboutToAppear(): void {
    //this.pageStack.pushPathByName('SearchDevicePage', '');
  }


  build() {
    Navigation(this.pageStack) {
      Column() {
        Tabs({ index: this.currentTab }) {
          TabContent() {HomePage();}
          .tabBar(this.createTabItem(0, "家居", $r("app.media.icon_tab_home")))
          TabContent() {DeviceCardTestPage();}
          .tabBar(this.createTabItem(1, "AI", $r("app.media.icon_tab_ai")))
          TabContent() {ProfilePage();}
          .tabBar(this.createTabItem(2, "我的", $r("app.media.icon_tab_profile")))
        }
        .barPosition(BarPosition.End)
        .scrollable(false)
        .layoutWeight(1)
        .onTabBarClick((index)=>{
          this.currentTab = index
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(ColorConstants.TABS_BG_COLOR)
    }
    .mode(NavigationMode.Stack)
    .hideToolBar(true)
    .hideTitleBar(true)
    .hideBackButton(true)
    .width('100%')
    .height('100%')
    .backgroundColor(ColorConstants.NAVIGATION_BG_COLOR)
  }

  @Builder
  createTabItem(index: number, title: string, icon: Resource) {
    Column() {
      Image(icon)
        .width(28)
        .height(28)
        .fillColor(this.currentTab === index ? ColorConstants.TAB_SELECTED : ColorConstants.TAB_UNSELECTED)
        .margin({ bottom: 2 })

      Text(title)
        .fontSize(14)
        .textAlign(TextAlign.Center)
        .fontColor(this.currentTab === index ? ColorConstants.TAB_SELECTED : ColorConstants.TAB_UNSELECTED)
    }
    .alignItems(HorizontalAlign.Center)
    .margin({ top: 4, bottom: 4 })
  }

}