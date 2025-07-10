package com.xmu.deepseekapi.controller;

import com.xmu.deepseekapi.model.ResultData;
import com.xmu.deepseekapi.tools.DeepseekTool;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;

@RestController
@RequestMapping("/ai")
public class qaController {

    private final DeepseekTool deepseekTool;

    public qaController(DeepseekTool deepseekTool) {
        this.deepseekTool = deepseekTool;
    }

    @PostMapping("/analysis")
    public ResponseEntity<ResultData<String>> analysis(@RequestBody String content) {
        ResultData<String> result = new ResultData<>();
        try {
            // 调用 DeepSeek 进行分析
            String aiAnswer = deepseekTool.ask(content);
            result.setSuccess(true);
            result.setData(aiAnswer);
            result.setMessage("AI分析完成");
        } catch (IOException e) {
            result.setSuccess(false);
            result.setData("AI调用失败");
            result.setMessage("AI调用失败: " + e.getMessage());
            System.out.println("AI调用失败: " + e.getMessage());
        }

        return ResponseEntity.ok(result);
    }
}
