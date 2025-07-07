

export class MqttMessageDispatcher {
  private handlers: Map<string, (payload: string) => void> = new Map();
  private static instance: MqttMessageDispatcher;   // 单例实例
  private constructor() {
    // 构造函数私有化，禁止外部 new
  }
  // 注册主题处理器
  registerHandler(topic: string, handler: (payload: string) => void) {
    this.handlers.set(topic, handler);
  }
  static getInstance(): MqttMessageDispatcher {
    if (!MqttMessageDispatcher.instance) {
      MqttMessageDispatcher.instance = new MqttMessageDispatcher();
    }
    return MqttMessageDispatcher.instance;
  }

  // 移除主题处理器
  unregisterHandler(topic: string) {
    this.handlers.delete(topic);
  }

  // 消息分发
  dispatch(topic: string, payload: string) {
    // 精确匹配
    if (this.handlers.has(topic)) {
      this.handlers.get(topic)!(payload);
    } else {
      console.warn(`未注册处理器的主题：${topic}`);
    }
  }
}
