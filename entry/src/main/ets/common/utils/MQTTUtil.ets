import { MqttAsync, MqttClient, MqttMessage, MqttQos } from '@ohos/mqtt';

export interface MQTTConnectOptions {
  url: string;
  clientId: string;
  username?: string;
  password?: string;
  connectTimeout?: number;
}

export interface MQTTSubscription {
  topic: string;
  qos: MqttQos;          // QoS 等级：0/1/2
}

export type MessageCallback = (err: Error | null, message: MqttMessage) => void;

export default class MQTTUtil {
  private static instance: MQTTUtil;                  // 单例实例
  private mqttAsyncClient: MqttClient | null = null;

  private constructor() {}

  /**
   * 获取MQTTUtil单例实例
   */
  public static getInstance(): MQTTUtil {
    if (!MQTTUtil.instance) {
      MQTTUtil.instance = new MQTTUtil();
    }
    return MQTTUtil.instance;
  }

  /**
   * 连接并可选订阅
   */
  async connect(
    options: MQTTConnectOptions,
    subscriptions: MQTTSubscription[] = [],
    messageCallback?: MessageCallback
  ): Promise<boolean> {
    console.log(`MQTT connecting to: ${options.url} clientId: ${options.clientId}`);

    this.mqttAsyncClient = MqttAsync.createMqtt({
      url: options.url,
      clientId: options.clientId,
      persistenceType: 1,
    });

    const isConnect = await this.mqttAsyncClient.connect({
      userName: options.username,
      password: options.password,
      connectTimeout: options.connectTimeout ?? 300,
    });
    if (!isConnect) {
      console.error('MQTT连接失败');
      return false;
    }

    if (messageCallback) {
      this.mqttAsyncClient.messageArrived(messageCallback);
    }

    for (const sub of subscriptions) {
      await this.mqttAsyncClient.subscribe({
        topic: sub.topic,
        qos: sub.qos,
      });
      console.log(`已订阅主题: ${sub.topic}`);
    }

    console.log('MQTT连接并订阅成功');
    return true;
  }

  /**
   * 发布消息
   */
  async publish(topic_: string, message_: string, qos_: MqttQos = 0): Promise<void> {
    if (!this.mqttAsyncClient) {
      console.error('MQTT客户端未连接');
      return;
    }
    await this.mqttAsyncClient.publish({
      topic: topic_,
      payload: message_,
      qos: qos_,
    });
    console.log(`已发布消息到 ${topic_}`);
  }

  /**
   * 动态订阅主题
   */
  async subscribe(topic: string, qos: MqttQos = 0): Promise<void> {
    if (!this.mqttAsyncClient) {
      console.error('MQTT客户端未连接');
      return;
    }
    await this.mqttAsyncClient.subscribe({ topic, qos });
    console.log(`已动态订阅主题: ${topic}`);
  }

  /**
   * 断开连接
   */
  async disconnect(): Promise<void> {
    if (this.mqttAsyncClient) {
      await this.mqttAsyncClient.disconnect();
      console.log('MQTT已断开');
    }
  }
}
