<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>프로필 이미지 & 관심사 설정</title>
    <!-- 스타일 및 폰트 -->
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" /><!-- 셀렉트 라이브러리 -->
    <link href='//spoqa.github.io/spoqa-han-sans/css/SpoqaHanSansNeo.css' rel='stylesheet' type='text/css'><!-- 폰트 -->
    <link href="${contextPath}/resources/css/common.css" rel="stylesheet" type="text/css" media="screen"><!-- 공통스타일 -->
    <link href="${contextPath}/resources/css/member/profileImgAndMyLikeSetting.css" rel="stylesheet" type="text/css" media="screen">
</head>
<body class="auto-translate">
    <jsp:include page="../common/lightHeader.jsp" />
    <section class="profile-setting-wrap">
        <h2>프로필 이미지 & 관심사 설정</h2>
        <form action="profileImgAndMyLikeSettingProcess.do" method="post" enctype="multipart/form-data">
             <!-- 프로필 이미지 설정 -->
            <div>
                <c:if test="${empty profileImgPath}">
                    <img id="profileImage" src="${contextPath}/resources/icon/basic_profile.jpg" alt="기본 프로필 이미지">
                </c:if>
                <c:if test="${not empty profileImgPath}">
				    <img id="profileImage" 
				         src="<c:choose>
				                <c:when test='${fn:startsWith(profileImgPath, "http")}'>
				                    ${profileImgPath}
				                </c:when>
				                <c:otherwise>
				                    ${contextPath}/images/profile/${profileImgPath}
				                </c:otherwise>
				              </c:choose>" 
				         alt="선택한 프로필 이미지">
				</c:if>

                <div class="profile-img-upload">
                    <label for="profileImg" class="custom-file-label">프로필 이미지 선택</label>
                    <input type="file" id="profileImg" name="profileImg" accept="image/*" onchange="previewImage(this)"><!-- 이미지 파일만 첨부할수있게 설정 -->
                </div>
            </div>
            <!-- 관심사 설정 (체크박스) -->
            <div>
                <div class="interest-buttons">
                    <label>
                        <input type="checkbox" name="myLike" value="여행">
                        <span>✈️ 여행</span>
                    </label>
                    <label>
                        <input type="checkbox" name="myLike" value="맛집">
                        <span>🍽️ 맛집</span>
                    </label>
                    <label>
                        <input type="checkbox" name="myLike" value="코딩">
                        <span>💻 코딩</span>
                    </label>
                    <label>
                        <input type="checkbox" name="myLike" value="음악">
                        <span>🎵 음악</span>
                    </label>
                    <label>
                        <input type="checkbox" name="myLike" value="영화">
                        <span>🎬 영화</span>
                    </label>
                    <label>
                        <input type="checkbox" name="myLike" value="스포츠">
                        <span>🏀 스포츠</span>
                    </label>
                    <label>
                        <input type="checkbox" name="myLike" value="패션">
                        <span>👗 패션</span>
                    </label>
                    <label>
                        <input type="checkbox" name="myLike" value="게임">
                        <span>🎮 게임</span>
                    </label>
                    <label>
                        <input type="checkbox" name="myLike" value="반려동물">
                        <span>🐶 반려동물</span>
                    </label>
                    <label>
                        <input type="checkbox" name="myLike" value="요리">
                        <span>🍳 요리</span>
                    </label>
                    <label>
                        <input type="checkbox" name="myLike" value="운동">
                        <span>💪 운동</span>
                    </label>
                    <label>
                        <input type="checkbox" name="myLike" value="독서">
                        <span>📚 독서</span>
                    </label>
                    <label>
                        <input type="checkbox" name="myLike" value="드라마">
                        <span>📺 드라마</span>
                    </label>
                    <label>
                        <input type="checkbox" name="myLike" value="웹툰">
                        <span>🖌️ 웹툰</span>
                    </label>
                    <label>
                        <input type="checkbox" name="myLike" value="커피">
                        <span>☕ 커피</span>
                    </label>
                    <label>
                        <input type="checkbox" name="myLike" value="차">
                        <span>🍵 차</span>
                    </label>
                    <label>
                        <input type="checkbox" name="myLike" value="사진">
                        <span>📷 사진</span>
                    </label>
                    <label>
                        <input type="checkbox" name="myLike" value="DIY">
                        <span>🛠️ DIY</span>
                    </label>
                    <label>
                        <input type="checkbox" name="myLike" value="영화감상">
                        <span>🎥 영화감상</span>
                    </label>
                    <label>
                        <input type="checkbox" name="myLike" value="음악감상">
                        <span>🎧 음악감상</span>
                    </label>
                </div>
            </div>
            <button type="submit">가입 완료</button>
        </form>
    </section>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script><!-- 제이쿼리 -->
    <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script><!-- 셀렉트 라이브러리 -->
    <script>
        // Select2 국가 셀렉트 초기화
        function formatState(state) {
            if (!state.id) return state.text;
            return $('<span style="display:flex; align-items:center; height:33px; line-height:33px;">' +
                    '<img src="' + state.element.dataset.image + '" class="country-icon" style="width: 18px; height: auto; margin-right: 5px;" /> ' +
                    state.text + '</span>');
        }

        $('#country-select').select2({
            minimumResultsForSearch: -1,
            templateResult: formatState,
            templateSelection: formatState
        }).on('change', function() {
            const selectedCountry = $(this).val();
            console.log("선택된 국가:", selectedCountry);

            $.ajax({
                url: '${contextPath}/main/selectCountry',
                type: 'POST',
                data: { nationality: selectedCountry },
                success: function() {
                    console.log("국가 정보 세션 저장 성공!");
                    // 페이지 새로고침
                    location.href = location.href; // 이 방식으로 새로고침
                },
                error: function(xhr, status, error) {
                    console.error("국가 정보 세션 저장 실패:", status, error);
                    alert("국가 정보 저장에 실패했습니다.");
                }
            });
        });

        //이미지 업로드
        function previewImage(input) {
            const file = input.files[0];
            if (!file) return;

            const allowedTypes = ['image/jpeg', 'image/png', 'image/gif'];
            if (!allowedTypes.includes(file.type)) {
                alert("이미지 파일만 업로드 가능합니다 (JPG, PNG, GIF)");
                input.value = "";
                return;
            }

            const reader = new FileReader();
            reader.onload = function (e) {
                document.getElementById('profileImage').src = e.target.result;
            }
            reader.readAsDataURL(file);
        }
    </script>
    <!-- 구글 번역api 활용 -->
    <script>
        document.addEventListener("DOMContentLoaded", function () {
            const selectedCountry = "${selectedCountry}"; // EL은 이 자리에서만 안전하게 사용 가능
            const translationCache = {};
            const targetLang = selectedCountry === 'jp' ? 'ja' : 'ko';

            if (selectedCountry === 'kr' || selectedCountry === 'jp') {
                const nodes = [];

                // body 전체 순회
                function traverse(node) {
                    if (node.nodeType === 3 && node.nodeValue.trim()) {
                        nodes.push(node);
                    } else if (node.nodeType === 1 && node.tagName !== 'SCRIPT') {
                        for (let i = 0; i < node.childNodes.length; i++) {
                            traverse(node.childNodes[i]);
                        }
                    }
                }

                traverse(document.body);

                nodes.forEach(function (node) {
                    const original = node.nodeValue.trim();
                    if (translationCache[original]) {
                        node.nodeValue = translationCache[original];
                        return;
                    }

                    const params = new URLSearchParams({
                        text: original,
                        lang: selectedCountry
                    });

                    fetch("${contextPath}/translate", {
                        method: "POST",
                        headers: {
                            "Content-Type": "application/x-www-form-urlencoded"
                        },
                        body: params
                    })
                    .then(res => res.json())
                    .then(data => {
                        if (data.translatedText) {
                            translationCache[original] = data.translatedText;
                            node.nodeValue = data.translatedText;
                        }
                    })
                    .catch(err => console.error("번역 실패", err));
                });
            }
        });
    </script>

</body>
</html>
