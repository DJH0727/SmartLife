#include <stdio.h>
#include <unistd.h>
#include "ohos_init.h"
#include "cmsis_os2.h"

#include "hi_wifi_api.h"
#include "lwip/ip_addr.h"
#include "lwip/netifapi.h"
#include "lwip/sockets.h"

#include "MQTTClient.h"
#include "common.h"
#include "mqtt1.h"



static MQTTClient mq1_client;

 unsigned char *onenet_mqtt1_buf;
 unsigned char *onenet_mqtt1_readbuf;
 int buf_size1;

Network n1;
MQTTPacket_connectData data1 = MQTTPacket_connectData_initializer;  

int mqtt1_connect(void)
{
    int rc = 0;
    
    NetworkInit(&n1);
    NetworkConnect(&n1, MQTT_BROKER_IP, 1883);

    buf_size1  = 4096 + 1024;
    onenet_mqtt1_buf = (unsigned char *)malloc(buf_size1);
    onenet_mqtt1_readbuf = (unsigned char *)malloc(buf_size1);
    if (!(onenet_mqtt1_buf && onenet_mqtt1_readbuf))
    {
        printf("No memory for MQTT client buffer!\r\n");
        return -2;
    }

    MQTTClientInit(&mq1_client, &n1, 1000, onenet_mqtt1_buf, buf_size1, onenet_mqtt1_readbuf, buf_size1);
    
    MQTTStartTask(&mq1_client);

    data1.keepAliveInterval = 30;
    data1.cleansession = 1;
    data1.clientID.cstring = MQTT_CLIENT_ID_SPEAKER;
    data1.username.cstring = MQTT_USER;
    data1.password.cstring = MQTT_PASSWORD;

    // 连接服务器
    rc = MQTTConnect(&mq1_client, &data1);
    if (rc != 0) {
        printf("MQTTConnect failed with return code %d\r\n", rc);
        return rc;
    }
    if(rc == 0){
        printf("[SP][MQTT1] MQTTConnect success!\r\n");
    }
    
    return 0;
}


void mqtt1_subscribe(const char* topic, int qos, void (*callback)(MessageData* msg_data)) {

    if (mq1_client.isconnected == 0) {
        printf("[SP][publish] client not ready!\n");
        return ;
    }
    MQTTSubscribe(&mq1_client, topic, qos, callback);
}
int mqtt1_publish(const char* topic, const char* payload, int qos)
{

    if (mq1_client.isconnected == 0) {
        printf("[SP][publish] client not ready!\n");
        return -1;
    }

    MQTTMessage message;
    message.qos = qos;
    message.retained = 0;
    message.payload = (void *)payload;
    message.payloadlen = strlen(payload);

    int rc = MQTTPublish(&mq1_client, topic, &message);
    if(rc==0) {
    	printf("[SP][publish] [%s]:%s\r\n",topic,payload);
    }
    else{
    	printf("publish topic:%s,failed!",topic);
    }
    
    return  rc;
}



