package com.xmu.deepseekapi;

import okhttp3.*;

import java.io.IOException;

public class Test {

    // DeepSeek Chat API 端点
    private static final String API_URL = "https://api.deepseek.com/v1/chat/completions";

    // 替换为你自己的 DeepSeek API Key
    private static final String API_KEY = "sk-e2320a6385f64cffba2c9c0b2ffbe91b";

    public static void main(String[] args) {
        String prompt = "当前环境是否适合农作物生长？温度25度，湿度60%，可燃气体0ppm。";
        try {
            String response = askDeepseek(prompt);
            System.out.println("=== AI 返回结果 ===");
            System.out.println(response);
        } catch (IOException e) {
            System.err.println("调用失败：" + e.getMessage());
            e.printStackTrace();
        }
    }

    private static String askDeepseek(String prompt) throws IOException {
        OkHttpClient httpClient = new OkHttpClient.Builder()
                .connectTimeout(30, java.util.concurrent.TimeUnit.SECONDS)
                .readTimeout(60, java.util.concurrent.TimeUnit.SECONDS)
                .writeTimeout(60, java.util.concurrent.TimeUnit.SECONDS)
                .build();

        MediaType JSON = MediaType.get("application/json; charset=utf-8");

        String requestJson = String.format("""
            {
              "model": "deepseek-chat",
              "messages": [
                {"role": "system", "content": "你是一个专业的农业AI顾问"},
                {"role": "user", "content": "%s"}
              ]
            }
            """, prompt.replace("\"", "\\\""));

        System.out.println("=== 请求 JSON ===");
        System.out.println(requestJson);

        RequestBody body = RequestBody.create(requestJson, JSON);

        Request request = new Request.Builder()
                .url(API_URL)
                .addHeader("Content-Type", "application/json")
                .addHeader("Authorization", "Bearer " + API_KEY)
                .post(body)
                .build();

        try (Response response = httpClient.newCall(request).execute()) {
            String responseBody = response.body() != null ? response.body().string() : "";
            if (!response.isSuccessful()) {
                throw new IOException("AI API调用失败，HTTP状态：" + response.code() + "，响应内容：" + responseBody);
            }
            return responseBody;
        }
    }
}
