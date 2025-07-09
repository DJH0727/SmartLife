- 操作系统：基于OpenHarmony code1.0
- 开发板：HI3861V100
- 拓展板: OLED显示板、环境监测板
- 语言：C

#### 需移植mqtt

[已经移植好的mqtt](https://gitee.com/lianzhian/OpenHarmony_mqtt)

将整个仓库下载并放入到OpenHarmony的third_party中

#### 修改配置文件
找到vendor\hisi\hi3861\hi3861\build\config\usr_config.mk

添加如下内容：
```
 CONFIG_I2C_SUPPORT=y
 CONFIG_PWM_SUPPORT=y
```


#### 修改common.h中的宏定义
~~~c
#define WIFI_SSID "wifi"
#define WIFI_PASSWORD "pwd"
#define MQTT_BROKER_IP "0.0.0.0"
~~~

### 项目结构：
```
.
├── device_app.c                # 项目主入口，初始化各模块并启动任务
├── BUILD.gn                    
├── ac.c / ac.h                 # 模拟空调设备,模拟绑定设备过程
├── speaker.c / speaker.h       # 模拟音响
├── ems.c / ems.h               # EMS环境监测模块（气体、温湿度采集与上传）
├── include/                    
│     ├── aht20.h                 
│     ├── beep.h                  # 蜂鸣器
│     ├── common.h                # 通用宏定义或公共常量
│     ├── i2c.h                   # I2C 总线初始化
│     ├── key.h                   # 按键检测逻辑与接口
│     ├── mq_2.h                  # MQ-2 可燃气体传感器接口
│     ├── mqtt.h                  # MQTT 用于AC
│     ├── mqtt1.h                 # MQTT1 用于Speaker和EMS
│     ├── oled.h                  # OLED 显示封装函数
│     ├── oled_fonts.h            
│     ├── oled_ssd1306.h          
│     └── wifi.h                  # Wi-Fi 连接封装
└── src/                        
      ├── aht20.c                 
      ├── beep.c                  
      ├── i2c.c                   
      ├── key.c                   
      ├── mq_2.c                  
      ├── mqtt.c                  
      ├── mqtt1.c                
      ├── oled.c                  
      ├── oled_ssd1306.c          
      └── wifi.c                  
```

#### AC
模拟一个空调设备

***未绑定状态，如果有搜索设备的请求，则返回设备信息***

订阅 /devices/unbound/request,如果接收到请求，则向/devices/unbound/response发送自身的信息
```json
{ 
  "id":"dev101",
  "type":"air_conditioner",
  "name":"Gree Air Conditioner",
  "isBind":0
}
```

***未绑定状态，如果有绑定本设备的请求，则返回结果***

订阅 /devices/{device_id}/bound/request,如果接收到请求，则向/devices/{device_id}/bound/response发送自身的信息
```json
{ 
  "result":0,
  "message":"success"
}
```
有绑定请求时，蜂鸣器会响一声提示，OLED会提示用户在8秒内通过按键确认绑定


***绑定状态，如控制本设备的请求***

订阅 /devices/{device_id}/set

接收则蜂鸣器响两声提示操作成功

***绑定状态，每十秒发送一次心跳***

/devices/{device_id}/heartbeat

#### Speaker

模拟音响设备，默认已绑定

订阅 /devices/speaker/set

接收则蜂鸣器响一声提示操作成功，并开始播放生日歌（虽然音不怎么准）

#### ems

模拟环境检测设备

向主题ems发送可燃气体、温度、湿度数据
~~~json
{
  "stat":"%d",
  "gas":"%d",
  "temp":"%.1f",
  "hum":"%.1f"
}
~~~

