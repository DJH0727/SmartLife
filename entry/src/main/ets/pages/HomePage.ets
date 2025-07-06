import { ColorConstants } from "../common/constants/ColorConstants"
import { UserName } from "../common/constants/CommonConstants"
@Component
export struct HomePage {
  build() {
    Column() {
      this.CustomTitleBar(UserName+"的家","0个设备")
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ColorConstants.HOME_PAGE_BG_COLOR) // 页面整体背景
  }






  @Builder
  CustomTitleBar(content: string,subtitle: string) {
    Row() {
      // 左侧主副标题
      Column() {
        Text(content)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#000000')

        Text(subtitle)
          .fontSize(14)
          .fontColor('#666666')
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
          console.log("添加设备")
        })
    }
  }



}
