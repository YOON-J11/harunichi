<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<!-- 스타일 css -->
<link href="${contextPath}/resources/css/member/mypage.css" rel="stylesheet" type="text/css" media="screen">
<body>
	<section class="mypage-wrap">
		<div class="mypage-inner-header">
			<!-- 왼쪽: 뒤로가기 -->
			<a href="javascript:void(0);" onclick="history.back();">
				<img src="${contextPath}/resources/icon/back_icon.svg" alt="뒤로가기버튼">
			</a>
		</div>
		<div class="mypage-profile-area">
			<div class="profile-area-left">
			  <c:choose>
			    <c:when test="${not empty pageOwner.profileImg}">
			      <c:choose>
			        <c:when test="${fn:startsWith(pageOwner.profileImg, 'http')}">
			          <img src="${pageOwner.profileImg}" alt="프로필 이미지">
			        </c:when>
			        <c:otherwise>
			          <img src="${contextPath}/resources/images/profile/${pageOwner.profileImg}" alt="프로필 이미지">
			        </c:otherwise>
			      </c:choose>
			    </c:when>
			    <c:otherwise>
			      <img src="${contextPath}/resources/icon/basic_profile.jpg" alt="기본 이미지">
			    </c:otherwise>
			  </c:choose>
			</div>

			<div class="profile-area-middle">
				<div class="nick-and-email">
					<span>${pageOwner.nick}</span>
					<span>${pageOwner.email}</span>
				</div>
				<div class="join-date">
					<img src="${contextPath}/resources/icon/calendar_icon.svg"><p>가입일: <fmt:formatDate value="${pageOwner.joindate}" pattern="yyyy년 M월 d일" /></p>
				</div>
				<div class="follow-area">
					<a href="${contextPath}/follow/mypageFollow?id=${pageOwner.id}&type=following">
					  <span id="followingCountNum">${followingCount}</span> 팔로우중
					</a>
					
					<a href="${contextPath}/follow/mypageFollow?id=${pageOwner.id}&type=follower">
					  <span id="followerCountNum">${followerCount}</span> 팔로워
					</a>
				</div>
				<div class="chat-edit-follow">
					<c:if test="${isMyPage}">
					    <a href="${contextPath}/member/updateMyInfoForm.do" class="edit-btn">프로필 수정</a>
					</c:if>
					<c:if test="${not isMyPage}">
					    <button id="followBtn" class="follow-btn follow" onclick="follow('${contextPath}', '${pageOwner.id}')">팔로우</button>
						<form id="chatForm" action="${contextPath}/chat/createChat" method="POST" style="display:none;">
						    <input type="hidden" name="receiverId" value="${pageOwner.id}">
						    <input type="hidden" name="chatType" value="personal">
						</form>
						<a href="javascript:void(0);" class="chat-btn" onclick="chatOpen();">
						    <img src="${contextPath}/resources/icon/chat_line_icon.svg" class="on-icons">
						</a>
					</c:if>
				</div>
			</div>
		</div>
		<div class="mypage-contents-area">
			<div class="mypage-contents-tab">
			    <div class="mypage-contents-tab-inner">
			    	<a href="javascript:void(0);" data-url="${contextPath}/member/myBoardList.do?id=${pageOwner.id}">
				        <c:choose>
				            <c:when test="${isMyPage}">나의 게시글</c:when>
				            <c:otherwise>${pageOwner.nick}님의 게시글</c:otherwise>
				        </c:choose>
				    </a>
				    <a href="javascript:void(0);" data-url="${contextPath}/member/myLikeBoardList.do?id=${pageOwner.id}">좋아요한 게시글</a>
				        <a href="javascript:void(0);" data-url="${contextPath}/product/myList?id=${pageOwner.id}">
					        <c:choose>
					            <c:when test="${isMyPage}">나의 거래글</c:when>
					            <c:otherwise>${pageOwner.nick}님의 거래글</c:otherwise>
					        </c:choose>
					    </a>
				    <a href="javascript:void(0);" data-url="${contextPath}/like/myLike?id=${pageOwner.id}">좋아요한 거래글</a>
				    <c:if test="${isMyPage}">
					    <a href="javascript:void(0);" data-url="${contextPath}/payment/orderList">나의 주문 내역</a>
					</c:if>
				</div>
			</div>
			
			<div class="mypage-contents-con">
			</div>
		</div>
	</section>
	
	<script type="text/javascript">
	
	    document.addEventListener("DOMContentLoaded", function() {
	    	
	    	console.log("pageOwner.id: ${pageOwner.id}");
	    	console.log("session member id: ${sessionScope.member.id}");

	        const boardSideEls = document.querySelectorAll('.board-side');
	        boardSideEls.forEach(function(el) {
	            el.style.display = 'none';
	        });
	        
	        const contextPath = '${contextPath}';
	        const followeeId = '${pageOwner.id}';
	        const myId = '${sessionScope.member != null ? sessionScope.member.id : ""}';
	
	        const btn = document.getElementById("followBtn");
	        if (btn) {
	            fetch(contextPath + "/follow/isFollowing?followeeId=" + encodeURIComponent(followeeId))
	                .then(response => response.json())
	                .then(isFollowing => {
	                    if (isFollowing) {
	                        setFollowingButton(contextPath, followeeId, myId);
	                    }
	                });
	        }
	        
	        
	        const tabs = document.querySelectorAll('.mypage-contents-tab-inner a');
	        const contentCon = document.querySelector('.mypage-contents-con');

	        tabs.forEach(tab => {
	            tab.addEventListener('click', function() {
	                const url = this.getAttribute('data-url');
	                if (url) {
	                    fetch(url)
	                        .then(response => response.text())
	                        .then(html => {
	                            contentCon.innerHTML = html;
	                            requestAnimationFrame(() => {
	                                translateAJAXContent();
	                            });
	                        })
	                        .catch(() => {
	                            contentCon.innerHTML = '<p>불러오기 실패</p>';
	                        });
	                }
	                
	                tabs.forEach(t => t.classList.remove('active-tab'));
	                this.classList.add('active-tab');
	            });
	        });

	        const firstTab = document.querySelector('.mypage-contents-tab-inner a[data-url]');
	        if (firstTab) {
	            firstTab.click();
	        }
	        
	    });
		
	    function setFollowingButton(contextPath, followeeId, myId) {
	        const btn = document.getElementById("followBtn");
	        btn.textContent = "팔로잉";
	        btn.classList.remove("follow", "unfollow");
	        btn.classList.add("following");
	
	        btn.onmouseenter = function() {
	            btn.textContent = "언팔로우";
	            btn.classList.remove("following");
	            btn.classList.add("unfollow");
	        };
	
	        btn.onmouseleave = function() {
	            btn.textContent = "팔로잉";
	            btn.classList.remove("unfollow");
	            btn.classList.add("following");
	        };
	
	        btn.onclick = function() {
	            unfollow(contextPath, followeeId, myId);
	        };
	    }
	
	    function setFollowButton(contextPath, followeeId, myId) {
	        const btn = document.getElementById("followBtn");
	        btn.textContent = "팔로우";
	        btn.classList.remove("following", "unfollow");
	        btn.classList.add("follow");
	
	        btn.onmouseenter = null;
	        btn.onmouseleave = null;
	
	        btn.onclick = function() {
	            follow(contextPath, followeeId, myId);
	        };
	    }
	
	    function follow(contextPath, followeeId, myId) {
	        fetch(contextPath + "/follow/add", {
	            method: "POST",
	            headers: { "Content-Type": "application/x-www-form-urlencoded" },
	            body: "followeeId=" + encodeURIComponent(followeeId)
	        })
	        .then(response => response.text())
	        .then(data => {
	            if (data === "success") {
	                setFollowingButton(contextPath, followeeId, myId);
	                updateFollowerCount(contextPath, followeeId);
	                if (followeeId === myId) {
	                    updateFollowingCount(contextPath, myId);
	                }
	            } else {
	                alert("팔로우 실패");
	            }
	        })
	        .catch(() => alert("서버 오류"));
	    }
	
	    
	    function unfollow(contextPath, followeeId, myId) {
	        if (confirm("언팔로우하시겠습니까?")) {
	            fetch(contextPath + "/follow/remove", {
	                method: "POST",
	                headers: { "Content-Type": "application/x-www-form-urlencoded" },
	                body: "followeeId=" + encodeURIComponent(followeeId)
	            })
	            .then(response => response.text())
	            .then(data => {
	                if (data === "success") {
	                    setFollowButton(contextPath, followeeId, myId);
	                    updateFollowerCount(contextPath, followeeId);
	                    if (followeeId === myId) {
	                        updateFollowingCount(contextPath, myId);
	                    }
	                } else {
	                    alert("언팔로우 실패");
	                }
	            })
	            .catch(() => alert("서버 오류"));
	        }
	    }
	
	    
	    function updateFollowerCount(contextPath, followeeId) {
	        fetch(contextPath + "/follow/followerCount?followeeId=" + encodeURIComponent(followeeId))
	        .then(response => response.text())
	        .then(count => {
	            document.getElementById("followerCountNum").textContent = count;
	        });
	    }
	
	    
	    function updateFollowingCount(contextPath, followerId) {
	        fetch(contextPath + "/follow/followingCount?followerId=" + encodeURIComponent(followerId))
	        .then(response => response.text())
	        .then(count => {
	            document.getElementById("followingCountNum").textContent = count;
	        });
	    }
	    
	    
	    function chatOpen(){
		    document.getElementById("chatForm").submit();
		}
	    
	    
	    let translationCache = {}; 

	    function translatePageContent() {
	        const selectedCountry = "${selectedCountry}";

	        if (selectedCountry === 'kr' || selectedCountry === 'jp') {
	            const nodes = [];


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
	    }

	    function translateAJAXContent() {
	        translatePageContent();
	    }

	    const observer = new MutationObserver(function(mutations) {
	        mutations.forEach(function(mutation) {
	            if (mutation.type === 'childList' && mutation.target.classList.contains('mypage-contents-con')) {
	                translateAJAXContent();
	            }
	        });
	    });

	    const contentArea = document.querySelector('.mypage-contents-con');
	    if (contentArea) {
	        observer.observe(contentArea, { childList: true, subtree: true });
	    }
	</script>

</body>