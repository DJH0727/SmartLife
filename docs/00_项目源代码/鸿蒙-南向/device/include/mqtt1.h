/*
 * Copyright (c) 2020 HiSilicon (Shanghai) Technologies CO., LIMITED.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef __MQTT_H_1_
#define __MQTT_H_1_
#include "MQTTClient.h"
//连接mqtt服务器
int mqtt1_connect(void);
void mqtt1_subscribe(const char* topic, int qos, void (*callback)(MessageData* msg_data));
int mqtt1_publish(const char* topic, const char* payload, int qos);
#endif /* __MQTT_H_1_ */

