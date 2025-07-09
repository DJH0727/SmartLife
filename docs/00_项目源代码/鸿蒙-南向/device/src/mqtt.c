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
#include "mqtt.h"



static MQTTClient mq_client;

 unsigned char *onenet_mqtt_buf;
 unsigned char *onenet_mqtt_readbuf;
 int buf_size;

Network n;
MQTTPacket_connectData data = MQTTPacket_connectData_initializer;  

int mqtt_connect(void)
{
    int rc = 0;
    
    NetworkInit(&n);
    NetworkConnect(&n, MQTT_BROKER_IP, 1883);

    buf_size  = 4096 + 1024;
    onenet_mqtt_buf = (unsigned char *)malloc(buf_size);
    onenet_mqtt_readbuf = (unsigned char *)malloc(buf_size);
    if (!(onenet_mqtt_buf && onenet_mqtt_readbuf))
    {
        printf("No memory for MQTT client buffer!\r\n");
        return -2;
    }

    MQTTClientInit(&mq_client, &n, 1000, onenet_mqtt_buf, buf_size, onenet_mqtt_readbuf, buf_size);
    
    MQTTStartTask(&mq_client);

    data.keepAliveInterval = 30;
    data.cleansession = 1;
    data.clientID.cstring = MQTT_CLIENT_ID_AC;
    data.username.cstring = MQTT_USER;
    data.password.cstring = MQTT_PASSWORD;

    // 连接服务器
    rc = MQTTConnect(&mq_client, &data);
    if (rc != 0) {
        printf("MQTTConnect failed with return code %d\r\n", rc);
        return rc;
    }
    if(rc == 0){
        printf("[AC][MQTT] MQTTConnect success!\r\n");
    }
    
    return 0;
}


void mqtt_subscribe(const char* topic, int qos, void (*callback)(MessageData* msg_data)) {
    if (mq_client.isconnected == 0) {
        printf("[AC][publish] client not ready!\n");
        return;
    }
    MQTTSubscribe(&mq_client, topic, qos, callback);
}
int mqtt_publish(const char* topic, const char* payload, int qos)
{
    if (mq_client.isconnected == 0) {
        printf("[AC][publish] client not ready!\n");
        return -1;
    }

    MQTTMessage message;
    message.qos = qos;
    message.retained = 0;
    message.payload = (void *)payload;
    message.payloadlen = strlen(payload);

    int rc = MQTTPublish(&mq_client, topic, &message);
    if(rc==0) {
    	printf("[AC][publish] [%s]:%s\r\n",topic,payload);
    }
    else{
    	printf("publish topic:%s,failed!",topic);
    }
    
    return  rc;
}



