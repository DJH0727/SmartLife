import { http } from '@kit.NetworkKit';
import { WEB_BASE_URL } from '../constants/CommonConstants';

export default class HttpUtil {
  /**
   * 发送 POST 请求，支持泛型类型安全。
   * T: 响应数据的类型
   * K: POST 参数对象的类型
   *
   * @param url 接口地址（相对 WEB_BASE_URL）
   * @param params 要发送的参数对象
   * @returns Promise<T>，请求成功时解析后的响应对象
   */
  static post<T, K>(url: string, params: K): Promise<T> {
    // 创建 HTTP 请求对象
    const httpRequest = http.createHttp();

    // 返回一个 Promise，便于异步处理
    return new Promise((resolve: (value: T) => void, reject: (value?: string) => void) => {
      httpRequest.request(
        WEB_BASE_URL + url, // 完整请求地址：基础地址 + 接口路径
        {
          method: http.RequestMethod.POST, // HTTP 请求方法为 POST
          header: {
            "Content-type": "application/json; charset=utf-8" // 请求体类型 JSON
          },
          extraData: JSON.stringify(params) || "", // POST 请求体参数，序列化为 JSON
          connectTimeout: 600000, // 连接超时时间：10 分钟
          readTimeout: 600000 // 读取超时时间：10 分钟
        },
        // 请求回调：处理成功或失败
        (error: Error, data: http.HttpResponse) => {
          if (!error) {
            // 无错误：解析响应结果 JSON 并返回
            resolve(JSON.parse(data.result as string));
          } else {
            // 有错误：返回错误信息
            reject(error.message || JSON.stringify(error));
          }

          // 关闭事件监听，防止内存泄漏
          httpRequest.off('headersReceive');
          // 销毁 HTTP 请求对象，释放资源
          httpRequest.destroy();
        }
      );
    });
  }

  /**
   * 发送 GET 请求，支持泛型类型安全。
   * T: 响应数据的类型
   *
   * @param url 接口地址（相对 WEB_BASE_URL）
   * @returns Promise<T>，请求成功时解析后的响应对象
   */
  static get<T>(url: string): Promise<T> {
    const httpRequest = http.createHttp();
    return new Promise((resolve: (value: T) => void, reject: (value?: string) => void) => {
      httpRequest.request(
        WEB_BASE_URL + url,
        {
          method: http.RequestMethod.GET,
          connectTimeout: 600000,
          readTimeout: 600000
        },
        (error: Error, data: http.HttpResponse) => {
          if (!error) {
            resolve(JSON.parse(data.result as string));
          } else {
            reject(error.message || JSON.stringify(error));
          }
          httpRequest.off('headersReceive');
          httpRequest.destroy();
        }
      );
    });
  }
}
