package com.harunichi.healthz;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
public class HealthController {
    @RequestMapping("/healthz")
    @ResponseBody
    public String health() {
        return "ok";
    }
}

