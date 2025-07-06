import {Test} from './Test'
import {ColorConstants} from '../common/constants/ColorConstants'
@Entry
@Component
struct Index {
  pageStack: NavPathStack = new NavPathStack()
  @State currentTab: number = 0;
  build() {
    Navigation(this.pageStack) {
      Column() {
        Tabs({ index: this.currentTab }) {
          TabContent() {
            Test();
          }.tabBar(this.createTabItem(0, "家居", $r("app.media.icon_tab_home")))

          TabContent() {
            Test();
          }.tabBar(this.createTabItem(1, "AI", $r("app.media.icon_tab_ai")))

          TabContent() {
            Test();
          }.tabBar(this.createTabItem(2, "我的", $r("app.media.icon_tab_profile")))
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
      .backgroundColor(Color.White)
    }
    .mode(NavigationMode.Stack)
    .hideToolBar(true)
    .hideTitleBar(true)
    .hideBackButton(true)
    .width('100%')
    .height('100%')
    .backgroundColor(ColorConstants.NAVIGATION_COLOR)
  }
  @State animColor: string = '#9E9E9E';  // 初始未选中颜色

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