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
    const httpRequest = http.createHttp();
    return new Promise((resolve: (value: T) => void, reject: (value?: string) => void) => {
      httpRequest.request(
        WEB_BASE_URL + url,
        {
          method: http.RequestMethod.POST,
          header: {
            "Content-type": "application/json; charset=utf-8"
          },
          extraData: JSON.stringify(params) || "",
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
