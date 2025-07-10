package com.xmu.deepseekapi.tools;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import okhttp3.*;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.concurrent.TimeUnit;

@Component
public class DeepseekTool {

    // DeepSeek API 端点
    private static final String API_URL = "https://api.deepseek.com/v1/chat/completions";
    private final ObjectMapper objectMapper = new ObjectMapper();
    // 替换为你自己的真实 API Key
    private static final String API_KEY = "sk-415a45d7bd454f42b3458b361d3ba00f";

    // OkHttpClient，带超时配置
    private final OkHttpClient httpClient = new OkHttpClient.Builder()
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(60, TimeUnit.SECONDS)
            .writeTimeout(60, TimeUnit.SECONDS)
            .build();

    public String ask(String prompt) throws IOException {
        System.out.println("=== AI分析内容 ===");
        System.out.println(prompt);

        MediaType JSON = MediaType.get("application/json; charset=utf-8");

        // 构造与Test中一致的JSON
        String requestJson = String.format("""
    {
      "model": "deepseek-chat",
      "messages": [
        {
          "role": "system",
          "content": "你是一个只能返回 JSON 的智能家居助手。你的全部响应内容必须是一个有效的、无 Markdown 标记、无代码块格式的 JSON 字符串，且只能包含如下格式：{\\"type\\": \\"cmd\\" | \\"normal\\", \\"answer\\": \\"中文回答内容\\"}。不要在回答中添加任何说明、引号外的注释、换行符、解释说明、代码块标记（如```json），只能返回干净的 JSON 字符串。当用户给出控制请求（如“打开空调”、“关闭灯”，或“好冷啊”、“好干燥”），type 应为 \\"cmd\\"，answer 是你自然语言生成的中文回应。当用户只是普通对话（如“你是谁”、“你好”），type 应为 \\"normal\\"，answer 是自然对话回应。你可控制的设备包括：空调、加湿器、音响、风扇、除湿器、灯。严格按照规范格式返回，否则系统将解析失败。"
        },
        {
          "role": "user",
          "content": "%s"
        }
      ],
      "stream": false
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
                System.out.println("AI API调用失败，HTTP状态：" + response.code());
                System.out.println("AI API响应内容：" + responseBody);
                throw new IOException("AI API调用失败，HTTP状态：" + response.code());
            }
            JsonNode root = objectMapper.readTree(responseBody);
            JsonNode contentNode = root.path("choices").get(0).path("message").path("content");
            String answer = contentNode.isMissingNode() ? "" : contentNode.asText();
            return answer;

        }




    }
}
