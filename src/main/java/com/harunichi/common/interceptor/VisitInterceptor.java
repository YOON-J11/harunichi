package com.harunichi.common.interceptor;

import com.harunichi.common.web.IpUtils;
import com.harunichi.visit.service.VisitService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.time.LocalDate;

public class VisitInterceptor extends HandlerInterceptorAdapter {

    @Autowired
    private VisitService visitService;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
            throws Exception {

        // 관리자/정적리소스 제외는 XML에서 패턴으로 처리할 예정
        String todayKey = "visited:" + LocalDate.now(); // 서버 타임존 기준(아래 SQL에서 KST로 보정)
        if (request.getSession().getAttribute(todayKey) == null) {
            String ip = IpUtils.getClientIp(request);
            visitService.insertVisit(ip);               // ★ 진짜 기록 포인트
            request.getSession().setAttribute(todayKey, Boolean.TRUE);
        }
        return true;
    }
}
