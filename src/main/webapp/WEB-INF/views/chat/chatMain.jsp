<%@page import="com.harunichi.common.util.LoginCheck"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>채팅 메인 페이지</title>
<link href="${ctx}/resources/css/chat/chatMain.css" rel="stylesheet">
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
</head>
<body>

	<form id="chatForm" action="${ctx}/chat/createChat"
		method="POST">
		<input type="hidden" id="receiverId" name="receiverId"> <input
			type="hidden" id="chatType" name="chatType" value="personal">
	</form>
	<div style="margin-bottom: 80px;">
		<p id="recText">채팅친구추천</p>
		<div id="chatMainCon">
			<a href="#" class="btn pre"><i class="bi bi-arrow-left"></i></a>
			<div class="chat-slider-container">
				<ul class="profile-list">
					<c:forEach var="member" items="${memberList}">
						<li>
							<div class="profile-con">
								<a href="${ctx}/mypage?id=${member.id}">
									<c:choose>
										<c:when
											test="${not empty member.profileImg and fn:startsWith(member.profileImg, 'http')}">
											<img class="profile-img" src="${member.profileImg}"
												alt="프로필 이미지">
										</c:when>
										<c:when
											test="${not empty member.profileImg and fn:startsWith(member.profileImg, '/')}">
											<img class="profile-img" src="${ctx}${member.profileImg}"
												alt="프로필 이미지">
										</c:when>
										<c:when test="${not empty member.profileImg}">
											<img class="profile-img"
												src="${ctx}/images/profile/${member.profileImg}"
												alt="프로필 이미지">
										</c:when>
										<c:otherwise>
											<img class="profile-img"
												src="${ctx}/resources/icon/basic_profile.jpg" alt="기본 프로필">
										</c:otherwise>
									</c:choose>


								</a>
								<p class="nick">${member.nick}</p>
								<p>
									<span style="color: #a3daff; font-weight: bold;">LIKE </span>${member.myLike}</p>
								<a href="#" class="do-chat-btn" data-id="${member.id}"
									onclick="chatOpen(this);">채팅하기</a>
							</div>
						</li>
					</c:forEach>
				</ul>
			</div>
			<a href="#" class="btn next"><i class="bi bi-arrow-right"></i></a>
		</div>
	</div>
	<c:if test="${!empty sessionScope.id}">
		<div>
			<div id="">
				<p id="recText">내 채팅 목록</p>
			</div>
			<div class="openChatCon">
				<ul class="open-chat-list">
					<c:if test="${empty myChatList}">
						<li><p class="empty-chat">아직 참여 중인 채팅방이 없어요. 새로운 채팅을
								시작해보세요!💬</p></li>
					</c:if>
					<c:forEach var="myChat" items="${myChatList}" varStatus="status">
						<c:set var="chatMessage" value="${myChatMessage[status.index]}" />
						<c:set var="profile" value="${profileList[status.index]}" />
						<c:if test="${not empty chatMessage}">
							<li>
								<div class="open-chat-item" data-room-id="${myChat.roomId}"
									data-room-type="${myChat.chatType}" onclick="doChat(this)">
									<a href="#"> <c:choose>
											<%-- 거래 채팅방 --%>
											<c:when test="${myChat.productId != 0}">
												<c:choose>
													<c:when test="${empty profile.profileImg}">
														<img data-product-id="${myChat.productId}"
															class="open-chat-img"
															src="${ctx}/resources/icon/basic_profile.jpg"
															alt="거래채팅방 기본 프로필사진">

													</c:when>
													<c:otherwise>
														<c:choose>
															<c:when
																test="${fn:startsWith(profile.profileImg, 'http')}">
																<img data-product-id="${myChat.productId}"
																	class="open-chat-img" src="${profile.profileImg}"
																	alt="거래채팅방 프로필사진">
															</c:when>
															<c:when test="${fn:startsWith(profile.profileImg, '/')}">
																<img data-product-id="${myChat.productId}"
																	class="open-chat-img"
																	src="${ctx}${profile.profileImg}"
																	alt="거래채팅방 프로필사진">
															</c:when>
															<c:otherwise>
																<img data-product-id="${myChat.productId}"
																	class="open-chat-img"
																	src="${ctx}/images/profile/${profile.profileImg}"
																	alt="거래채팅방 프로필사진">
															</c:otherwise>
														</c:choose>
													</c:otherwise>

												</c:choose>
											</c:when>

											<%-- 개인 채팅방 --%>
											<c:when
												test="${myChat.chatType eq 'personal' and myChat.productId == 0}">
												<c:choose>
													<c:when test="${not empty profile.profileImg}">
														<c:choose>
															<c:when
																test="${fn:startsWith(profile.profileImg, 'http')}">
																<img class="open-chat-img" src="${profile.profileImg}"
																	alt="개인채팅방 프로필사진">
															</c:when>
															<c:when test="${fn:startsWith(profile.profileImg, '/')}">
																<img class="open-chat-img"
																	src="${ctx}${profile.profileImg}"
																	alt="개인채팅방 프로필사진">
															</c:when>
															<c:otherwise>
																<img class="open-chat-img"
																	src="${ctx}/images/profile/${profile.profileImg}"
																	alt="개인채팅방 프로필사진">
															</c:otherwise>
														</c:choose>
													</c:when>

													<c:otherwise>
														<img class="open-chat-img"
															src="${ctx}/resources/icon/basic_profile.jpg"
															alt="개인채팅방 기본 프로필사진">

													</c:otherwise>
												</c:choose>
											</c:when>

											<%-- 오픈 채팅방 --%>
											<c:when test="${myChat.chatType eq 'group'}">
												<c:choose>
													<c:when
														test="${not empty myChat.profileImg and fn:startsWith(myChat.profileImg, 'http')}">
														<img class="open-chat-img" src="${myChat.profileImg}"
															alt="오픈채팅방 프로필사진">
													</c:when>
													<c:when
														test="${not empty myChat.profileImg and fn:startsWith(myChat.profileImg, '/')}">
														<img class="open-chat-img"
															src="${ctx}${myChat.profileImg}" alt="오픈채팅방 프로필사진">
													</c:when>
													<c:when test="${not empty myChat.profileImg}">
														<img class="open-chat-img"
															src="${ctx}/images/chat/${myChat.profileImg}"
															alt="오픈채팅방 프로필사진">
													</c:when>
													<c:otherwise>
														<img class="open-chat-img"
															src="${ctx}/resources/icon/basic_profile.jpg"
															alt="오픈채팅방 기본 프로필사진">
													</c:otherwise>
												</c:choose>

											</c:when>
										</c:choose>
									</a>
									<div class="open-chat-info">
										<c:choose>
											<c:when test="${myChat.chatType eq 'personal'}">
												<p class="open-chat-title">${profile.nick}</p>
											</c:when>
											<c:otherwise>
												<p class="open-chat-title">${myChat.title}
													<span>(<span>${myChat.userCount}/</span>${myChat.persons})</span>
												</p>
											</c:otherwise>
										</c:choose>
										<p class="open-chat-content">${chatMessage.message}
											<span class="sent-time">${chatMessage.displayTime}</span>
										</p>
									</div>
								</div>
							</li>
						</c:if>
					</c:forEach>
				</ul>
			</div>
		</div>
	</c:if>
	<div>
		<div id="openTitle">
			<p id="recText">오픈 채팅방</p>
			<a href="#" id="newOpenChatBtn" onclick="openModal(event)">만들기</a>
		</div>
		<div class="openChatCon">
			<ul class="open-chat-list">
				<c:if test="${empty openChatList}">
					<li><p class="empty-chat">만들어진 오픈 채팅방이 없어요. 채팅방을 만들어 많은
							사람들과 대화를 나눠보세요!💬</p></li>
				</c:if>
				<c:forEach var="openChat" items="${openChatList}">
					<li data-room-id="${openChat.roomId}" onclick="doOpenChat(this);">
						<div class="open-chat-item">
							<a id="doOpenChat" href="#"> <c:choose>
									<c:when test="${empty openChat.profileImg}">
										<img class="open-chat-img"
											src="${ctx}/resources/icon/basic_profile.jpg"
											alt="오픈채팅방 프로필사진">
									</c:when>
									<c:otherwise>
										<c:choose>
											<c:when test="${fn:startsWith(openChat.profileImg, 'http')}">
												<img class="open-chat-img" src="${openChat.profileImg}"
													alt="오픈채팅방 프로필사진">
											</c:when>
											<c:when test="${fn:startsWith(openChat.profileImg, '/')}">
												<img class="open-chat-img"
													src="${ctx}${openChat.profileImg}"
													alt="오픈채팅방 프로필사진">
											</c:when>
											<c:otherwise>
												<img class="open-chat-img"
													src="${ctx}/images/chat/${openChat.profileImg}"
													alt="오픈채팅방 프로필사진">
											</c:otherwise>
										</c:choose>

									</c:otherwise>
								</c:choose>
							</a>
							<div class="open-chat-info">
								<p class="open-chat-title">${openChat.title}
									<span data-persons="${openChat.persons}">(<span
										data-user-count="${openChat.userCount}">${openChat.userCount}/</span>${openChat.persons})</span>
								</p>
								<c:forEach var="messageVo" items="${messageList}">
									<c:if test="${openChat.roomId eq messageVo.roomId}">
										<p class="open-chat-content">${messageVo.message}
											<span class="sent-time">${messageVo.displayTime}</span>
										</p>
									</c:if>
								</c:forEach>
							</div>
						</div>
					</li>
				</c:forEach>
			</ul>
		</div>
	</div>
	<!-- 모달창 영역 -->
	<div id="myModal" class="modal">
		<div class="modal-content">
			<span class="close" onclick="closeModal()">&times;</span>
			<h2>오픈채팅방 만들기</h2>
			<form action="${ctx}/chat/createOpenChat" id="newChatForm"
				method="POST" enctype="multipart/form-data">
				<label>프로필 이미지</label>
				<div class="open-chat-img-wrap">
					<img id="openChatImg" class="open-chat-profile-img"
						src="${ctx}/resources/icon/basic_profile.jpg" alt="오픈 채팅방 프로필 이미지">
					<input type="hidden" id="openchatProfileImg" name="chatProfileImg"
						value=""> <label for="imgUpload" class="adit-profile-img">
						<img src="${ctx}/resources/icon/camera_icon.svg"
						alt="사진 업로드 아이콘">
					</label> <input type="file" id="imgUpload" name="imgUpload"
						accept="image/*" onchange="uploadImg(this)">
				</div>
				<label>채팅방 이름</label> <input id="openChatTitle" name="title"
					class="open-chat-form" type="text" maxlength="20"
					onkeyup="validateTitle()">
				<p class="modal-input-msg">최대 20자까지 입력 가능합니다.</p>
				<label>최대 인원</label> <input id="openChatPersons" name="persons"
					class="open-chat-form" type="number" min="2" max="8"
					onkeyup="validatePersons()">
				<p class="modal-input-msg">최대 8명까지 입장 가능합니다.</p>
				<div class="modal-btn-wrap">
					<button class="modal-btn" onclick="confirmAction(event)">만들기</button>
					<button class="modal-btn" type="button" onclick="closeModal()">취소</button>
				</div>
				<input type="hidden" name="chatType" value="group">
			</form>
		</div>
	</div>
</body>

<script type="text/javascript">

	function chatOpen(btn){
		//'채팅하기'버튼이 눌린 카드의 멤버 ID를 input에 저장
		const receiverId = btn.getAttribute("data-id");
		document.getElementById("receiverId").value = receiverId;
		document.getElementById("chatForm").submit();		
	}	
	
	//추천친구 캐러셀 --------------------------------------------------------------
	let currentIndex = 0;
	
	const list = document.querySelector(".profile-list");
	const items = document.querySelectorAll(".profile-list li");
	const cardWidth = 230 + 20; // 카드 너비 + gap
	const visibleCards = 4;	
	const totalCards = items.length;
	const maxIndex = totalCards - visibleCards;
	
	document.querySelector(".btn.next").addEventListener("click", (e) => {
	  e.preventDefault();
	  if (currentIndex < maxIndex) {
	    currentIndex++;
	    updateSlide();
	  }
	});
	
	document.querySelector(".btn.pre").addEventListener("click", (e) => {
	  e.preventDefault();
	  if (currentIndex > 0) {
	    currentIndex--;
	    updateSlide();
	  }
	});
	
	function updateSlide() {
		const moveX = currentIndex * cardWidth;
		list.style.transform = "translateX(-" + moveX + "px)";
	}
		
	//모달창 -------------------------------------------------------------------------------	
	//모달창 열기
	function openModal(event) {	
		event.preventDefault();		
		//로그인 체크
		const userId = '<%=session.getAttribute("id") == null ? "" : session.getAttribute("id")%>';
		if (!userId) {
			location.href = "${ctx}/chat/loginCheck";
		  return;
		} 
		document.getElementById("myModal").style.display = "block";
	}

	//모달창 닫기
	function closeModal() { 
		//입력된 값 및 폼 초기화
		document.getElementById("newChatForm").reset();

		//유효성 검사 메시지 초기화
		const msgAll = document.querySelectorAll(".modal-input-msg");
		msgAll.forEach((msg, index) => {
			if (index === 0) msg.textContent = "최대 20자까지 입력 가능합니다.";  
			if (index === 1) msg.textContent = "최대 8명까지 입장 가능합니다.";  
			msg.classList.remove("err")});  

		//프로필 이미지 초기화
		document.getElementById("openChatImg").src = "${ctx}/resources/icon/basic_profile.jpg";
document.getElementById("openchatProfileImg").value = "";


		document.getElementById("myModal").style.display = "none"; 
	}

	//모달창 컨펌
	function confirmAction(event) {	
		event.preventDefault();	
		//유효성 검사
		const isValid = validate();
		if (isValid) { document.getElementById("newChatForm").submit(); }
	}	
	
	//유효성 검사 결과 리턴
	function validate() {
		const isTitleValid = validateTitle();
		const isPersonsValid = validatePersons();
		return isTitleValid && isPersonsValid;
	}
	
	//채팅방 이름 유효성 검사
	function validateTitle() {
		const titleInput = document.getElementById("openChatTitle");
		const msgTag = titleInput.nextElementSibling;
		const title = titleInput.value.trim();

		if (title.length === 0) {
			msgTag.textContent = "채팅방 이름을 입력해주세요.";
			msgTag.classList.add("err");
			return false;
		} else {
			msgTag.textContent = "";
			return true;
		}
	}

	//채팅방 인원 유효성 검사
	function validatePersons() {
		const personInput = document.getElementById("openChatPersons");
		const msgTag = personInput.nextElementSibling;
		const value = Number(personInput.value);

		if (isNaN(value) || value < 2 || value > 8) {
			msgTag.textContent = "2명 이상 8명 이하로 입력해주세요.";
			msgTag.classList.add("err");
			return false;
		} else {
			msgTag.textContent = "";
			return true;
		}
	}

	//채팅목록에서 채팅방을 눌렀을 때 함수 -----------------------------------------------------------
	function doChat(event){        
		  const roomId = event.getAttribute("data-room-id");
		  const chatType = event.getAttribute("data-room-type"); 
		  const imgEl = event.querySelector("img");
		  const productId = imgEl ? imgEl.getAttribute("data-product-id") : null;
		
		  const base = "${ctx}/chat/doChat?roomId=" + roomId + "&chatType=" + chatType;
		  location.href = productId ? (base + "&productId=" + productId) : base;
		}

	
	//생성된 오픈 채팅에 참여하는 함수 --------------------------------------------------------------
	function doOpenChat(event){		
		
		const roomId = event.getAttribute("data-room-id");
		
		//채팅방 인원 확인
	    const personsEl = event.querySelector("span[data-persons]");
	    const countEl = event.querySelector("span[data-user-count]");
	    
	    const persons = parseInt(personsEl.getAttribute("data-persons"), 10);
	    const count = parseInt(countEl.getAttribute("data-user-count"), 10);
		
		console.log("persons : " + persons);
		console.log("count : " + count);
		
		if(persons <= count){
			alert("이 채팅방은 이미 인원이 다 찼어요.");
			return;			
		}					
		location.href = "${ctx}/chat/doOpenChat?roomId=" + roomId;
	}
		
	//오픈채팅방 프로필 이미지 업로드 --------------------------------------------------------------
	function uploadImg(input) {
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
	        document.getElementById('openChatImg').src = e.target.result;
	        document.getElementById('openchatProfileImg').value = file.name;
	    }
	    reader.readAsDataURL(file);
	}
	
	
	
	

	
	
</script>

</html>