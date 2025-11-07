package com.harunichi.member.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.security.SecureRandom;
import java.sql.Date;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.servlet.ModelAndView;

import com.harunichi.board.vo.BoardVo;
import com.harunichi.common.storage.AzureBlobStorageService;
import com.harunichi.member.service.MemberService;
import com.harunichi.member.vo.MemberVo;

@Controller("memberController")
@RequestMapping(value = "/member")
public class MemberControllerImpl implements MemberController {

    private static final Logger logger = LoggerFactory.getLogger(MemberControllerImpl.class);

    @Autowired
    private AzureBlobStorageService blobService;

    @Autowired
    private MemberService memberService;

    @RequestMapping(
        value = {"/loginpage.do", "/addMemberForm.do", "/emailAuthForm.do", "/profileImgAndMyLikeSetting.do", "updateMyInfoForm.do"},
        method = RequestMethod.GET
    )
    @Override
    public ModelAndView showForms(HttpServletRequest request, HttpServletResponse response) {
        String viewName = (String) request.getAttribute("viewName");
        logger.debug("Returning viewName: {}", viewName);
        return new ModelAndView(viewName);
    }

    @RequestMapping(value = "/login.do")
    @ResponseBody
    @Override
    public String login(@RequestParam("id") String id,
                        @RequestParam("password") String password,
                        HttpSession session) {

        MemberVo dbMember = memberService.selectMemberById(id);
        if (dbMember == null || !dbMember.getPass().equals(password)) {
            return "fail";
        }

        session.setAttribute("member", dbMember);
        session.setAttribute("isLogOn", true);
        session.setAttribute("id", dbMember.getId());
        return "success";
    }

    private final String KAKAO_REST_API_KEY = "e0c7dc056f537df0edb757b015e72883";
    private final String KAKAO_REDIRECT_URI = "http://localhost:8090/harunichi/member/KakaoCallback.do";

    @RequestMapping(value = "/KakaoCallback.do", method = RequestMethod.GET)
    public ModelAndView kakaoCallback(@RequestParam("code") String code,
                                      @RequestParam(value = "state", required = false, defaultValue = "login") String mode,
                                      HttpServletRequest request) {

        ModelAndView mav = new ModelAndView();
        HttpSession session = request.getSession();

        RestTemplate restTemplate = new RestTemplate();
        String tokenUrl = "https://kauth.kakao.com/oauth/token";

        HttpHeaders headers = new HttpHeaders();
        headers.add("Content-type", "application/x-www-form-urlencoded;charset=utf-8");

        MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
        params.add("grant_type", "authorization_code");
        params.add("client_id", KAKAO_REST_API_KEY);
        params.add("redirect_uri", KAKAO_REDIRECT_URI);
        params.add("code", code);

        HttpEntity<MultiValueMap<String, String>> tokenRequestEntity = new HttpEntity<>(params, headers);
        ResponseEntity<Map> tokenResponse = restTemplate.exchange(tokenUrl, HttpMethod.POST, tokenRequestEntity, Map.class);
        Map<String, Object> tokenInfo = tokenResponse.getBody();
        String accessToken = (String) tokenInfo.get("access_token");

        String userInfoUrl = "https://kapi.kakao.com/v2/user/me";
        HttpHeaders userInfoHeaders = new HttpHeaders();
        userInfoHeaders.add("Authorization", "Bearer " + accessToken);
        userInfoHeaders.add("Content-type", "application/x-www-form-urlencoded;charset=utf-8");

        HttpEntity<MultiValueMap<String, String>> userInfoRequestEntity = new HttpEntity<>(userInfoHeaders);
        ResponseEntity<Map> userInfoResponse = restTemplate.exchange(userInfoUrl, HttpMethod.GET, userInfoRequestEntity, Map.class);

        Map<String, Object> userinfo = userInfoResponse.getBody();

        MemberVo memberVo = new MemberVo();
        String kakaoId = String.valueOf(userinfo.get("id"));
        memberVo.setId("kakao_" + kakaoId);
        memberVo.setKakao_id(kakaoId);
        memberVo.setContry("kr");
        memberVo.setPass(GenerateRandomPassword(12));

        if (userinfo.containsKey("properties")) {
            Map<String, Object> properties = (Map<String, Object>) userinfo.get("properties");
            memberVo.setNick((String) properties.get("nickname"));
        }

        if (userinfo.containsKey("kakao_account")) {
            Map<String, Object> kakaoAccount = (Map<String, Object>) userinfo.get("kakao_account");

            if (kakaoAccount.containsKey("name")) {
                memberVo.setName((String) kakaoAccount.get("name"));
            }
            if (kakaoAccount.containsKey("email")) {
                memberVo.setEmail((String) kakaoAccount.get("email"));
            }
            if (kakaoAccount.containsKey("gender")) {
                String gender = (String) kakaoAccount.get("gender");
                if ("female".equals(gender)) memberVo.setGender("F");
                else if ("male".equals(gender)) memberVo.setGender("M");
                else memberVo.setGender("");
            }
            if (kakaoAccount.containsKey("phone_number")) {
                String rawPhone = (String) kakaoAccount.get("phone_number");
                if (rawPhone != null) {
                    String cleanedPhone = rawPhone.replaceAll("[\\s\\-]", "");
                    memberVo.setTel(cleanedPhone);
                }
            }
            if (kakaoAccount.containsKey("birthday") && kakaoAccount.containsKey("birthyear")) {
                try {
                    String birthday = (String) kakaoAccount.get("birthday");
                    String birthyear = (String) kakaoAccount.get("birthyear");
                    Calendar cal = Calendar.getInstance();
                    cal.set(Integer.parseInt(birthyear),
                            Integer.parseInt(birthday.substring(0, 2)) - 1,
                            Integer.parseInt(birthday.substring(2)));
                    memberVo.setYear(new Date(cal.getTimeInMillis()));
                } catch (Exception e) {
                    logger.warn("생년월일 파싱 오류", e);
                }
            }
            if (kakaoAccount.containsKey("shipping_address")) {
                Map<String, Object> shippingAddress = (Map<String, Object>) kakaoAccount.get("shipping_address");
                if (shippingAddress != null && shippingAddress.containsKey("base_address")) {
                    memberVo.setAddress((String) shippingAddress.get("base_address"));
                }
            }
        }

        session.setAttribute("memberVo", memberVo);
        session.setAttribute("authType", "kakao");

        MemberVo dbMember;
        try {
            logger.info("DB 조회 시도: kakao_id = {}", kakaoId);
            dbMember = memberService.selectMemberByKakaoId(kakaoId);
            logger.info("DB 조회 결과 (dbMember): {}", dbMember);
        } catch (Exception e) {
            logger.error("카카오 ID 조회 오류", e);
            dbMember = new MemberVo();
        }

        if ("login".equals(mode)) {
            if (dbMember != null && dbMember.getId() != null) {
                session.setAttribute("member", dbMember);
                session.setAttribute("isLogOn", true);
                session.setAttribute("id", dbMember.getId());
                mav.setViewName("redirect:/");
            } else {
                boolean isEmailDuplicate = memberService.isEmailDuplicate(memberVo.getEmail());
                if (isEmailDuplicate) {
                    try {
                        HttpServletResponse response = ((org.springframework.web.context.request.ServletRequestAttributes)
                                org.springframework.web.context.request.RequestContextHolder.getRequestAttributes()).getResponse();
                        response.setContentType("text/html;charset=UTF-8");
                        PrintWriter out = response.getWriter();
                        String contextPath = request.getContextPath();
                        out.println("<script>");
                        out.println("alert('이미 이 이메일로 가입된 계정이 있습니다. 일반 로그인을 시도해주세요.');");
                        out.println("location.href='" + contextPath + "/member/loginpage.do';");
                        out.println("</script>");
                        out.flush();
                    } catch (IOException e) {
                        logger.error("응답 쓰기 오류", e);
                    }
                    return null;
                }
                session.setAttribute("kakaoUserInfo", userinfo);
                try {
                    HttpServletResponse response = ((org.springframework.web.context.request.ServletRequestAttributes)
                            org.springframework.web.context.request.RequestContextHolder.getRequestAttributes()).getResponse();
                    response.setContentType("text/html;charset=UTF-8");
                    PrintWriter out = response.getWriter();
                    String contextPath = request.getContextPath();
                    out.println("<script>");
                    out.println("if (confirm('회원이 아닙니다. 카카오 계정으로 가입하시겠습니까?')) {");
                    out.println("    location.href='" + contextPath + "/member/profileImgAndMyLikeSetting.do';");
                    out.println("} else {");
                    out.println("    location.href='" + contextPath + "/member/loginpage.do';");
                    out.println("}");
                    out.println("</script>");
                    out.flush();
                } catch (IOException e) {
                    logger.error("응답 쓰기 오류", e);
                }
                return null;
            }
        } else if ("join".equals(mode)) {
            if (dbMember != null && dbMember.getId() != null) {
                try {
                    session.setAttribute("member", dbMember);
                    session.setAttribute("isLogOn", true);
                    session.setAttribute("id", dbMember.getId());
                    HttpServletResponse response = ((org.springframework.web.context.request.ServletRequestAttributes)
                            org.springframework.web.context.request.RequestContextHolder.getRequestAttributes()).getResponse();
                    response.setContentType("text/html;charset=UTF-8");
                    PrintWriter out = response.getWriter();
                    String contextPath = request.getContextPath();
                    out.println("<script>");
                    out.println("alert('이미 가입된 카카오 계정입니다. 해당 아이디로 로그인합니다.');");
                    out.println("location.href='" + contextPath + "/';");
                    out.println("</script>");
                    out.flush();
                } catch (IOException e) {
                    logger.error("응답 쓰기 오류", e);
                }
                return null;
            }
            if (memberService.isEmailDuplicate(memberVo.getEmail())) {
                try {
                    HttpServletResponse response = ((org.springframework.web.context.request.ServletRequestAttributes)
                            org.springframework.web.context.request.RequestContextHolder.getRequestAttributes()).getResponse();
                    response.setContentType("text/html;charset=UTF-8");
                    PrintWriter out = response.getWriter();
                    out.println("<script>");
                    out.println("alert('이미 이 이메일로 가입된 계정이 있습니다. 일반 로그인을 시도해주세요.');");
                    out.println("location.href='" + request.getContextPath() + "/member/loginpage.do';");
                    out.println("</script>");
                    out.flush();
                } catch (IOException e) {
                    logger.error("응답 쓰기 오류", e);
                }
                return null;
            } else {
                session.setAttribute("memberVo", memberVo);
                session.setAttribute("authType", "kakao");
                mav.setViewName("redirect:/member/profileImgAndMyLikeSetting.do");
            }
        }

        return mav;
    }

    @RequestMapping(value = "/NaverCallback.do", method = RequestMethod.GET)
    public ModelAndView naverCallback(@RequestParam("code") String code,
                                      @RequestParam(value = "state", required = false, defaultValue = "login") String mode,
                                      HttpServletRequest request) {

        ModelAndView mav = new ModelAndView();
        HttpSession session = request.getSession();

        String clientId = "v80rEgQ4aPt_g050ZNtj";
        String clientSecret = "nJd3qHAENe";
        String tokenUrl = "https://nid.naver.com/oauth2.0/token?grant_type=authorization_code"
                + "&client_id=" + clientId
                + "&client_secret=" + clientSecret
                + "&code=" + code
                + "&state=" + mode;

        RestTemplate restTemplate = new RestTemplate();
        ResponseEntity<Map> tokenResponse = restTemplate.getForEntity(tokenUrl, Map.class);
        Map<String, Object> tokenInfo = tokenResponse.getBody();
        String accessToken = (String) tokenInfo.get("access_token");

        HttpHeaders headers = new HttpHeaders();
        headers.add("Authorization", "Bearer " + accessToken);
        HttpEntity<String> userInfoRequest = new HttpEntity<>(headers);

        ResponseEntity<Map> userInfoResponse = restTemplate.exchange(
                "https://openapi.naver.com/v1/nid/me", HttpMethod.GET, userInfoRequest, Map.class);
        Map<String, Object> responseMap = (Map<String, Object>) userInfoResponse.getBody().get("response");

        MemberVo memberVo = new MemberVo();
        String naverId = (String) responseMap.get("id");
        memberVo.setId("naver_" + naverId);
        memberVo.setNaver_id(naverId);
        memberVo.setContry("kr");
        memberVo.setPass(GenerateRandomPassword(12));
        memberVo.setEmail((String) responseMap.get("email"));
        memberVo.setName((String) responseMap.get("name"));
        memberVo.setNick((String) responseMap.get("nickname"));
        memberVo.setGender((String) responseMap.get("gender"));
        memberVo.setAddress((String) responseMap.get("address"));

        String rawMobile = (String) responseMap.get("mobile");
        if (rawMobile != null && rawMobile.startsWith("0")) {
            String formattedMobile = "+82" + rawMobile.replaceAll("-", "").substring(1);
            memberVo.setTel(formattedMobile);
        } else {
            memberVo.setTel(rawMobile);
        }

        if (responseMap.containsKey("birthyear") && responseMap.containsKey("birthday")) {
            try {
                String birthyear = (String) responseMap.get("birthyear");   // 1990
                String birthday = (String) responseMap.get("birthday");     // 12-25
                String fullBirth = birthyear + "-" + birthday;
                Date birthDate = Date.valueOf(fullBirth);
                memberVo.setYear(birthDate);
            } catch (Exception e) {
                logger.warn("생년월일 파싱 오류", e);
            }
        }

        session.setAttribute("memberVo", memberVo);
        session.setAttribute("authType", "naver");

        MemberVo dbMember;
        try {
            dbMember = memberService.selectMemberByNaverId(naverId);
        } catch (Exception e) {
            logger.error("네이버 ID 조회 오류", e);
            dbMember = new MemberVo();
        }

        if ("login".equals(mode)) {
            if (dbMember != null && dbMember.getId() != null) {
                session.setAttribute("member", dbMember);
                session.setAttribute("isLogOn", true);
                session.setAttribute("id", dbMember.getId());
                mav.setViewName("redirect:/");
            } else {
                boolean isEmailDuplicate = memberService.isEmailDuplicate(memberVo.getEmail());
                if (isEmailDuplicate) {
                    try {
                        HttpServletResponse response = ((org.springframework.web.context.request.ServletRequestAttributes)
                                org.springframework.web.context.request.RequestContextHolder.getRequestAttributes()).getResponse();
                        response.setContentType("text/html;charset=UTF-8");
                        PrintWriter out = response.getWriter();
                        String contextPath = request.getContextPath();
                        out.println("<script>");
                        out.println("alert('이미 이 이메일로 가입된 계정이 있습니다. 일반 로그인을 시도해주세요.');");
                        out.println("location.href='" + contextPath + "/member/loginpage.do';");
                        out.println("</script>");
                        out.flush();
                    } catch (IOException e) {
                        logger.error("응답 쓰기 오류", e);
                    }
                    return null;
                }
                session.setAttribute("naverUserInfo", responseMap);
                try {
                    HttpServletResponse response = ((org.springframework.web.context.request.ServletRequestAttributes)
                            org.springframework.web.context.request.RequestContextHolder.getRequestAttributes()).getResponse();
                    response.setContentType("text/html;charset=UTF-8");
                    PrintWriter out = response.getWriter();
                    String contextPath = request.getContextPath();
                    out.println("<script>");
                    out.println("if (confirm('회원이 아닙니다. 네이버 계정으로 가입하시겠습니까?')) {");
                    out.println("    location.href='" + contextPath + "/member/profileImgAndMyLikeSetting.do';");
                    out.println("} else {");
                    out.println("    location.href='" + contextPath + "/member/loginpage.do';");
                    out.println("}");
                    out.println("</script>");
                    out.flush();
                } catch (IOException e) {
                    logger.error("응답 쓰기 오류", e);
                }
                return null;
            }
        } else if ("join".equals(mode)) {
            if (dbMember != null && dbMember.getId() != null) {
                try {
                    session.setAttribute("member", dbMember);
                    session.setAttribute("isLogOn", true);
                    session.setAttribute("id", dbMember.getId());
                    HttpServletResponse response = ((org.springframework.web.context.request.ServletRequestAttributes)
                            org.springframework.web.context.request.RequestContextHolder.getRequestAttributes()).getResponse();
                    response.setContentType("text/html;charset=UTF-8");
                    PrintWriter out = response.getWriter();
                    String contextPath = request.getContextPath();
                    out.println("<script>");
                    out.println("alert('이미 가입된 네이버 계정입니다. 해당 아이디로 로그인합니다.');");
                    out.println("location.href='" + contextPath + "/';");
                    out.println("</script>");
                    out.flush();
                } catch (IOException e) {
                    logger.error("응답 쓰기 오류", e);
                }
                return null;
            }
            if (memberService.isEmailDuplicate(memberVo.getEmail())) {
                try {
                    HttpServletResponse response = ((org.springframework.web.context.request.ServletRequestAttributes)
                            org.springframework.web.context.request.RequestContextHolder.getRequestAttributes()).getResponse();
                    response.setContentType("text/html;charset=UTF-8");
                    PrintWriter out = response.getWriter();
                    out.println("<script>");
                    out.println("alert('이미 이 이메일로 가입된 계정이 있습니다. 일반 로그인을 시도해주세요.');");
                    out.println("location.href='" + request.getContextPath() + "/member/loginpage.do';");
                    out.println("</script>");
                    out.flush();
                } catch (IOException e) {
                    logger.error("응답 쓰기 오류", e);
                }
                return null;
            } else {
                session.setAttribute("memberVo", memberVo);
                session.setAttribute("authType", "naver");
                mav.setViewName("redirect:/member/profileImgAndMyLikeSetting.do");
            }
        }

        return mav;
    }

    @RequestMapping(value = "/addMemberWriteForm.do", method = RequestMethod.GET)
    public String addMemberWriteForm(HttpSession session, HttpServletResponse response) throws IOException {
        MemberVo memberVo = (MemberVo) session.getAttribute("memberVo");
        response.setContentType("text/html; charset=UTF-8");

        if (memberVo == null || memberVo.getEmail() == null) {
            response.getWriter().write("<script>alert('비정상적인 접근입니다.'); location.href='/harunichi/member/addMemberForm.do';</script>");
            return null;
        }
        if (memberService.isEmailDuplicate(memberVo.getEmail())) {
            session.removeAttribute("memberVo");
            response.getWriter().write("<script>alert('이미 회원으로 등록된 이메일입니다.'); location.href='/harunichi/member/addMemberForm.do';</script>");
            return null;
        }
        return "member/addMemberWriteForm";
    }

    @RequestMapping(value = "/addMemberProcess.do", method = RequestMethod.POST)
    @ResponseBody
    @Override
    public String addMemberProcess(@RequestParam("id") String id,
                                   @RequestParam("pass") String pass,
                                   @RequestParam("name") String name,
                                   @RequestParam("nick") String nick,
                                   @RequestParam("year") String yearString,
                                   @RequestParam(value = "gender", required = false) String gender,
                                   @RequestParam(value = "tel", required = false) String tel,
                                   @RequestParam(value = "address", required = false) String address,
                                   HttpSession session) throws Exception {

        MemberVo memberVo = (MemberVo) session.getAttribute("memberVo");
        if (memberVo == null) {
            return "redirect:/";
        }

        memberVo.setId(id);
        memberVo.setPass(pass);
        memberVo.setName(name);
        memberVo.setNick(nick);

        Date year = null;
        if (yearString != null && !yearString.trim().isEmpty()) {
            try {
                LocalDate localDate = LocalDate.parse(yearString);
                year = Date.valueOf(localDate);
            } catch (DateTimeParseException e) {
                logger.warn("생년월일 파싱 오류: {}", yearString, e);
            } catch (Exception e) {
                logger.warn("생년월일 변환 오류", e);
            }
        }
        memberVo.setYear(year);

        String standardizedGender = null;
        if (gender != null && !gender.isEmpty()) {
            if ("male".equalsIgnoreCase(gender)) standardizedGender = "M";
            else if ("female".equalsIgnoreCase(gender)) standardizedGender = "F";
        }
        memberVo.setGender(standardizedGender);

        if (tel != null && tel.startsWith("0")) {
            String country = memberVo.getContry();
            if ("kr".equalsIgnoreCase(country)) tel = "+82" + tel.substring(1);
            else if ("jp".equalsIgnoreCase(country)) tel = "+81" + tel.substring(1);
        }
        memberVo.setTel(tel);
        memberVo.setAddress(address);

        session.setAttribute("memberVo", memberVo);
        return "success";
    }

    @RequestMapping(value = "/checkId.do", method = RequestMethod.GET)
    @ResponseBody
    @Override
    public ResponseEntity<Map<String, Boolean>> checkId(@RequestParam("id") String id,
                                                        HttpServletRequest request,
                                                        HttpServletResponse response) {
        logger.debug("아이디 중복 체크: {}", id);
        boolean exists = memberService.checkId(id);
        Map<String, Boolean> result = new HashMap<>();
        result.put("exists", exists);
        return new ResponseEntity<>(result, HttpStatus.OK);
    }

    @RequestMapping(value = "/profileImgAndMyLikeSettingProcess.do", method = RequestMethod.POST)
    public void profileImgAndMyLikeSettingProcess(@RequestParam("profileImg") org.springframework.web.multipart.MultipartFile profileImg,
                                                  @RequestParam(value = "myLike", required = false) String[] myLikes,
                                                  HttpServletRequest request,
                                                  HttpServletResponse response,
                                                  Model model) {

        response.setContentType("text/html;charset=UTF-8");

        try (PrintWriter out = response.getWriter()) {
            MemberVo memberVo = (MemberVo) request.getSession().getAttribute("memberVo");
            if (memberVo == null) {
                out.println("<script>alert('잘못된 접근입니다. 다시 시도해주세요.'); location.href='" +
                        request.getContextPath() + "/member/addMemberForm.do';</script>");
                out.flush();
                return;
            }

            String url = handleProfileImage(profileImg);
            String myLikeStr = handleMyLikes(myLikes);

            if (url != null) memberVo.setProfileImg(url);
            memberVo.setMyLike(myLikeStr);

            try {
                memberService.insertMember(memberVo);
            } catch (Exception e) {
                logger.error("회원가입 처리 오류", e);
                out.println("<script>alert('회원가입 처리 중 오류가 발생했습니다.'); location.href='" +
                        request.getContextPath() + "/member/addMemberForm.do';</script>");
                out.flush();
                return;
            }

            request.getSession().removeAttribute("memberVo");
            request.getSession().removeAttribute("authType");

            HttpSession session = request.getSession();
            session.setAttribute("member", memberVo);
            session.setAttribute("isLogOn", true);
            session.setAttribute("id", memberVo.getId());

            out.println("<script>alert('회원가입이 완료되었습니다. 환영합니다!'); location.href='" +
                    request.getContextPath() + "/';</script>");
            out.flush();
        } catch (IOException e) {
            logger.error("응답 쓰기 오류", e);
        }
    }

    private String handleProfileImage(org.springframework.web.multipart.MultipartFile profileImg) {
        try {
            if (profileImg != null && !profileImg.isEmpty()) {
                AzureBlobStorageService.UploadResult r = blobService.upload("profile", profileImg);
                return r.url;
            }
        } catch (Exception e) {
            logger.error("프로필 이미지 업로드 오류", e);
        }
        return null;
    }

    private String handleMyLikes(String[] myLikes) {
        if (myLikes != null && myLikes.length > 0) {
            return String.join(",", myLikes);
        }
        return "";
    }

    @RequestMapping("/logout.do")
    @Override
    public String logout(HttpServletRequest request) {
        HttpSession session = request.getSession();
        String selectedCountry = (String) session.getAttribute("selectedCountry");
        session.invalidate();

        session = request.getSession(true);
        if (selectedCountry != null) {
            session.setAttribute("selectedCountry", selectedCountry);
        }
        return "redirect:/";
    }

    @RequestMapping(value = "/getRegistrationForm", method = RequestMethod.GET)
    public String getRegistrationForm(@RequestParam("nationality") String nationality, HttpSession session) {
        MemberVo memberVo = (MemberVo) session.getAttribute("memberVo");
        if (memberVo == null) memberVo = new MemberVo();
        memberVo.setContry(nationality);
        session.setAttribute("memberVo", memberVo);

        if ("kr".equals(nationality)) {
            logger.info("Returning Korean registration form.");
            return "member/addMemberFormSelectKr";
        } else if ("jp".equals(nationality)) {
            logger.info("Returning Japanese registration form.");
            return "member/addMemberFormSelectJp";
        } else {
            logger.warn("Invalid nationality: {}", nationality);
            return "error/invalidNationality";
        }
    }

    public static String GenerateRandomPassword(int len) {
        final String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+";
        SecureRandom random = new SecureRandom();
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < len; i++) sb.append(chars.charAt(random.nextInt(chars.length())));
        String password = sb.toString();
        BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
        return passwordEncoder.encode(password);
    }

    @RequestMapping(value = "/updateMyInfoProcess.do", method = RequestMethod.POST)
    public String updateMyInfoProcess(@RequestParam("id") String id,
                                      @RequestParam(value = "pass", required = false) String pass,
                                      @RequestParam("name") String name,
                                      @RequestParam("nick") String nick,
                                      @RequestParam("email") String email,
                                      @RequestParam("year") String yearString,
                                      @RequestParam(value = "gender", required = false) String gender,
                                      @RequestParam(value = "tel", required = false) String tel,
                                      @RequestParam(value = "address", required = false) String address,
                                      @RequestParam(value = "detailAddress", required = false) String detailAddress,
                                      @RequestParam(value = "contry") String contry,
                                      @RequestParam(value = "myLike", required = false) String[] myLikes,
                                      @RequestParam(value = "profileImg", required = false) org.springframework.web.multipart.MultipartFile profileImg,
                                      @RequestParam(value = "resetProfile", required = false) String resetProfile,
                                      HttpSession session,
                                      HttpServletRequest request,
                                      HttpServletResponse response) throws Exception {

        MemberVo dbMember = memberService.selectMemberById(id);
        if (dbMember == null) {
            try {
                response.setContentType("text/html;charset=UTF-8");
                PrintWriter out = response.getWriter();
                out.println("<script>alert('회원 정보를 찾을 수 없습니다.'); location.href='/harunichi/';</script>");
                out.flush();
                return null;
            } catch (IOException e) {
                logger.error("응답 쓰기 오류", e);
            }
        }

        MemberVo memberVo = dbMember;

        if (pass != null && !pass.trim().isEmpty()) {
            memberVo.setPass(pass);
        }

        memberVo.setName(name);
        memberVo.setNick(nick);
        memberVo.setEmail(email);
        memberVo.setContry(contry);

        if (myLikes != null) memberVo.setMyLike(String.join(",", myLikes));
        else memberVo.setMyLike("");

        if (yearString != null && !yearString.trim().isEmpty()) {
            try {
                LocalDate localDate = LocalDate.parse(yearString);
                memberVo.setYear(Date.valueOf(localDate));
            } catch (DateTimeParseException e) {
                logger.warn("생년월일 파싱 오류: {}", yearString, e);
            }
        }

        String standardizedGender = null;
        if (gender != null && !gender.isEmpty()) {
            if ("male".equalsIgnoreCase(gender)) standardizedGender = "M";
            else if ("female".equalsIgnoreCase(gender)) standardizedGender = "F";
        }
        memberVo.setGender(standardizedGender);

        if (tel != null && tel.startsWith("0")) {
            String country = memberVo.getContry();
            if ("kr".equalsIgnoreCase(country)) tel = "+82" + tel.substring(1);
            else if ("jp".equalsIgnoreCase(country)) tel = "+81" + tel.substring(1);
        }
        memberVo.setTel(tel);

        String fullAddress = address != null ? address.trim() : "";
        if (detailAddress != null && !detailAddress.trim().isEmpty()) {
            fullAddress += " " + detailAddress.trim();
        }
        memberVo.setAddress(fullAddress);

        if ("true".equals(resetProfile)) {
            memberVo.setProfileImg(null);
        } else {
            String url = handleProfileImage(profileImg);
            if (url != null) memberVo.setProfileImg(url);
        }

        try {
            memberService.updateMember(memberVo);
            session.setAttribute("member", memberVo);
            return "redirect:/";
        } catch (Exception e) {
            logger.error("회원정보 수정 오류", e);
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.println("<script>alert('회원정보 수정 중 오류가 발생했습니다.'); location.href='/harunichi/';</script>");
            out.flush();
            return null;
        }
    }

    @RequestMapping(value = "/myLikeBoardList.do", method = RequestMethod.GET)
    public String myLikeBoardList(HttpSession session, Model model) {
        MemberVo member = (MemberVo) session.getAttribute("member");
        if (member == null) return "redirect:/member/loginpage.do";

        List<BoardVo> likedBoards = memberService.getMyLikedBoards(member.getId());
        model.addAttribute("boardList", likedBoards);

        List<Integer> likedBoardIds = likedBoards.stream().map(BoardVo::getBoardId).collect(Collectors.toList());
        Map<Integer, Boolean> likedPosts = new HashMap<>();
        for (Integer boardId : likedBoardIds) likedPosts.put(boardId, true);
        model.addAttribute("likedPosts", likedPosts);

        return "board/list";
    }

    @RequestMapping(value = "/myBoardList.do", method = RequestMethod.GET)
    public String myBoardList(HttpSession session, Model model) {
        MemberVo member = (MemberVo) session.getAttribute("member");
        if (member == null) return "redirect:/member/loginpage.do";

        List<BoardVo> myBoards = memberService.getMyBoards(member.getId());
        model.addAttribute("boardList", myBoards);

        List<Integer> likedBoardIds = memberService.getLikedBoardIds(member.getId());
        Map<Integer, Boolean> likedPosts = new HashMap<>();
        for (Integer boardId : likedBoardIds) likedPosts.put(boardId, true);
        model.addAttribute("likedPosts", likedPosts);

        return "board/list";
    }
}
