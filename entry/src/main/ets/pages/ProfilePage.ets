
import promptAction from '@ohos.promptAction';
import { UserName } from "../common/constants/CommonConstants"


@Component
export struct ProfilePage {

  build() {
    Stack() {
      Column() {
        Image($r('app.media.img_avatar_mine'))
          .width(100)
          .height(100)
          .borderRadius(50)
          .margin({ top: "8%" })
        Text(UserName)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Black)
          .margin({ top: 20 })

      }
      .width('100%')
      .height('50%')
      .backgroundImage( $r('app.media.img_profile_ikun'))
      .backgroundImageSize({ height: '100%', width: '100%' })
      .backgroundBlurStyle(BlurStyle.Regular)
      Column({ space: 10 }) {
        this.mineItemBuilder($r('app.media.icon_mine_info'), '我的信息', () => {
          promptAction.showToast({ message: '没有信息' })
        })
        Divider()
        this.mineItemBuilder($r('app.media.ic_mine_update'), '检查更新', () => {
          promptAction.showToast({ message: '已是最新' })
        })
        Divider()
        this.mineItemBuilder($r('app.media.ic_mine_about'), '关于', () => {
          promptAction.showToast({ message: '没有关于' })
        })
        Divider()
        this.mineItemBuilder($r('app.media.icon_mine_setting'), '设置', () => {
          promptAction.showToast({ message: '没有设置' })
        })
        Blank()
        Button('退出登录')
          .width('100%')
          .fontSize(18)
          .backgroundColor(Color.Gray)
          .fontColor(Color.White)

      }
      .width('100%')
      .height('60%')
      .offset({ y: '40%' })
      .borderRadius({ topLeft: 50, topRight: 50 })
      .backgroundColor(Color.White)
      .padding(30)
    }.width('100%')
    .height('100%')
    .alignContent(Alignment.Top)
  }


  @Builder
  mineItemBuilder(icon: Resource, title: string, callback?: () => void) {
    Row({ space: 10 }) {
      Image(icon)
        .width(24)
        .height(24)
      Text(title)
        .fontSize(16)
        .height(24)
        .fontWeight(FontWeight.Medium)
      Blank()
      Image($r('app.media.ic_arrow_right'))
        .width(24)
        .height(24)
    }.width('100%')
    .height(40)
    .onClick(() => {
      if(callback){
        callback()
      }
    })
  }


}