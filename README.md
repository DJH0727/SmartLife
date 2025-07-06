## 模块权限

在 `module.json5` 中添加网络权限，否则无法连接 MQTT 服务器：

```json5
"reqPermissions": [
  {
    "name": "ohos.permission.INTERNET"
  }
]

