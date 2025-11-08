package com.harunichi.common.web;

import javax.servlet.http.HttpServletRequest;
import java.util.Arrays;
import java.util.List;

public class IpUtils {
    private static final List<String> CANDIDATES = Arrays.asList(
        "X-Forwarded-For","X-Real-IP","CF-Connecting-IP",
        "Proxy-Client-IP","WL-Proxy-Client-IP","HTTP_CLIENT_IP","HTTP_X_FORWARDED_FOR"
    );

    public static String getClientIp(HttpServletRequest request) {
        for (String h : CANDIDATES) {
            String v = request.getHeader(h);
            if (v != null && v.length() != 0 && !"unknown".equalsIgnoreCase(v)) {
                return v.split(",")[0].trim();
            }
        }
        return request.getRemoteAddr();
    }
}
