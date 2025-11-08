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
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
</head>
<body>

	<form id="chatForm" action="${ctx}/chat/createChat" method="POST">
		<input type="hidden" id="receiverId" name="receiverId">
		<input type="hidden" id="chatType" name="chatType" value="personal">
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
										<c:when test="${not empty member.profileImg and fn:startsWith(member.profileImg, 'http')}">
											<img class="profile-img" src="${member.profileImg}" alt="프로필 이미지">
										</c:when>
										<c:when test="${not empty member.profileImg and fn:startsWith(member.profileImg, '/')}">
											<img class="profile-img" src="${ctx}${member.profileImg}" alt="프로필 이미지">
										</c:when>
										<c:when test="${not empty member.profileImg}">
											<img class="profile-img" src="${ctx}/images/profile/${member.profileImg}" alt="프로필 이미지">
										</c:when>
										<c:otherwise>
											<img class="profile-img" src="${ctx}/resources/icon/basic_profile.jpg" alt="기본 프로필">
										</c:otherwise>
									</c:choose>
								</a>
								<p class="nick">${member.nick}</p>
								<p><span style="color: #a3daff; font-weight: bold;">LIKE </span>${member.myLike}</p>
								<a href="#" class="do-chat-btn" data-id="${member.id}" onclick="chatOpen(this);">채팅하기</a>
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
			<div id=""><p id="recText">내 채팅 목록</p></div>
			<div class="openChatCon">
				<ul class="open-chat-list">
					<c:if test="${empty myChatList}">
						<li><p class="empty-chat">아직 참여 중인 채팅방이 없어요. 새로운 채팅을 시작해보세요!💬</p></li>
					</c:if>
					<c:forEach var="myChat" items="${myChatList}" varStatus="status">
						<c:set var="chatMessage" value="${myChatMessage[status.index]}" />
						<c:set var="profile" value="${profileList[status.index]}" />
						<c:if test="${not empty chatMessage}">
							<li>
								<div class="open-chat-item" data-room-id="${myChat.roomId}" data-room-type="${myChat.chatType}" onclick="doChat(this)">
									<a href="#">
										<c:choose>
											<c:when test="${myChat.productId != 0}">
												<c:choose>
													<c:when test="${empty profile.profileImg}">
														<img data-product-id="${myChat.productId}" class="open-chat-img" src="${ctx}/resources/icon/basic_profile.jpg" alt="거래채팅방 기본 프로필사진">
													</c:when>
													<c:otherwise>
														<c:choose>
															<c:when test="${fn:startsWith(profile.profileImg, 'http')}">
																<img data-product-id="${myChat.productId}" class="open-chat-img" src="${profile.profileImg}" alt="거래채팅방 프로필사진">
															</c:when>
															<c:when test="${fn:startsWith(profile.profileImg, '/')}">
																<img data-product-id="${myChat.productId}" class="open-chat-img" src="${ctx}${profile.profileImg}" alt="거래채팅방 프로필사진">
															</c:when>
															<c:otherwise>
																<img data-product-id="${myChat.productId}" class="open-chat-img" src="${ctx}/images/profile/${profile.profileImg}" alt="거래채팅방 프로필사진">
															</c:otherwise>
														</c:choose>
													</c:otherwise>
												</c:choose>
											</c:when>

											<c:when test="${myChat.chatType eq 'personal' and myChat.productId == 0}">
												<c:choose>
													<c:when test="${not empty profile.profileImg}">
														<c:choose>
															<c:when test="${fn:startsWith(profile.profileImg, 'http')}">
																<img class="open-chat-img" src="${profile.profileImg}" alt="개인채팅방 프로필사진">
															</c:when>
															<c:when test="${fn:startsWith(profile.profileImg, '/')}">
																<img class="open-chat-img" src="${ctx}${profile.profileImg}" alt="개인채팅방 프로필사진">
															</c:when>
															<c:otherwise>
																<img class="open-chat-img" src="${ctx}/images/profile/${profile.profileImg}" alt="개인채팅방 프로필사진">
															</c:otherwise>
														</c:choose>
													</c:when>
													<c:otherwise>
														<img class="open-chat-img" src="${ctx}/resources/icon/basic_profile.jpg" alt="개인채팅방 기본 프로필사진">
													</c:otherwise>
												</c:choose>
											</c:when>

											<c:when test="${myChat.chatType eq 'group'}">
												<c:choose>
													<c:when test="${not empty myChat.profileImg and fn:startsWith(myChat.profileImg, 'http')}">
														<img class="open-chat-img" src="${myChat.profileImg}" alt="오픈채팅방 프로필사진">
													</c:when>
													<c:when test="${not empty myChat.profileImg and fn:startsWith(myChat.profileImg, '/')}">
														<img class="open-chat-img" src="${ctx}${myChat.profileImg}" alt="오픈채팅방 프로필사진">
													</c:when>
													<c:when test="${not empty myChat.profileImg}">
														<img class="open-chat-img" src="${ctx}/images/chat/${myChat.profileImg}" alt="오픈채팅방 프로필사진">
													</c:when>
													<c:otherwise>
														<img class="open-chat-img"
														     src="data:image/svg+xml,%3Csvg xmlns=%27http://www.w3.org/2000/svg%27 width=%2780%27 height=%2780%27 viewBox=%270 0 24 24%27%3E%3Crect width=%2724%27 height=%2724%27 rx=%274%27 fill=%27%23E2E8F0%27/%3E%3Cpath d=%27m0 22.013c.14-1.537.93-2.877 2.091-3.777.466-.361 1.146-.266 1.536.174l1.873 2.112 1.849-2.119c.387-.444 1.069-.544 1.537-.184 1.173.9 1.972 2.248 2.113 3.794.014 1.093-.878 1.987-1.984 1.987H1.984C.879 24-.014 23.106 0 22.013Zm13 0c-.014 1.093.878 1.987 1.984 1.987h7.032c1.106 0 1.998-.894 1.984-1.987-.141-1.547-.941-2.895-2.113-3.794-.469-.36-1.15-.26-1.537.184l-1.849 2.119-1.873-2.112c-.39-.44-1.07-.535-1.536-.174-1.16.9-1.951 2.24-2.091 3.777Zm9.5-10.013c0-2.206-1.794-4-4-4s-4 1.794-4 4 1.794 4 4 4 4-1.794 4-4Zm-6.5-8c0-2.206-1.794-4-4-4s-4 1.794-4 4 1.794 4 4 4 4-1.794 4-4Zm-6.5 8c0-2.206-1.794-4-4-4s-4 1.794-4 4 1.794 4 4 4 4-1.794 4-4Z%27 fill=%27%23718096%27/%3E%3C/svg%3E"
														     alt="오픈채팅방 기본 이미지">
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
					<li><p class="empty-chat">만들어진 오픈 채팅방이 없어요. 채팅방을 만들어 많은 사람들과 대화를 나눠보세요!💬</p></li>
				</c:if>
				<c:forEach var="openChat" items="${openChatList}">
					<li data-room-id="${openChat.roomId}" onclick="doOpenChat(this);">
						<div class="open-chat-item">
							<a id="doOpenChat" href="#">
								<c:choose>
									<c:when test="${empty openChat.profileImg}">
										<img class="open-chat-img"
										     src="data:image/svg+xml,%3Csvg xmlns=%27http://www.w3.org/2000/svg%27 width=%2780%27 height=%2780%27 viewBox=%270 0 24 24%27%3E%3Crect width=%2724%27 height=%2724%27 rx=%274%27 fill=%27%23E2E8F0%27/%3E%3Cpath d=%27m0 22.013c.14-1.537.93-2.877 2.091-3.777.466-.361 1.146-.266 1.536.174l1.873 2.112 1.849-2.119c.387-.444 1.069-.544 1.537-.184 1.173.9 1.972 2.248 2.113 3.794.014 1.093-.878 1.987-1.984 1.987H1.984C.879 24-.014 23.106 0 22.013Zm13 0c-.014 1.093.878 1.987 1.984 1.987h7.032c1.106 0 1.998-.894 1.984-1.987-.141-1.547-.941-2.895-2.113-3.794-.469-.36-1.15-.26-1.537.184l-1.849 2.119-1.873-2.112c-.39-.44-1.07-.535-1.536-.174-1.16.9-1.951 2.24-2.091 3.777Zm9.5-10.013c0-2.206-1.794-4-4-4s-4 1.794-4 4 1.794 4 4 4 4-1.794 4-4Zm-6.5-8c0-2.206-1.794-4-4-4s-4 1.794-4 4 1.794 4 4 4 4-1.794 4-4Zm-6.5 8c0-2.206-1.794-4-4-4s-4 1.794-4 4 1.794 4 4 4 4-1.794 4-4Z%27 fill=%27%23718096%27/%3E%3C/svg%3E"
										     alt="오픈채팅방 기본 이미지">
									</c:when>
									<c:otherwise>
										<c:choose>
											<c:when test="${fn:startsWith(openChat.profileImg, 'http')}">
												<img class="open-chat-img" src="${openChat.profileImg}" alt="오픈채팅방 프로필사진">
											</c:when>
											<c:when test="${fn:startsWith(openChat.profileImg, '/')}">
												<img class="open-chat-img" src="${ctx}${openChat.profileImg}" alt="오픈채팅방 프로필사진">
											</c:when>
											<c:otherwise>
												<img class="open-chat-img" src="${ctx}/images/chat/${openChat.profileImg}" alt="오픈채팅방 프로필사진">
											</c:otherwise>
										</c:choose>
									</c:otherwise>
								</c:choose>
							</a>
							<div class="open-chat-info">
								<p class="open-chat-title">${openChat.title}
									<span data-persons="${openChat.persons}">(<span data-user-count="${openChat.userCount}">${openChat.userCount}/</span>${openChat.persons})</span>
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

	<div id="myModal" class="modal">
		<div class="modal-content">
			<span class="close" onclick="closeModal()">&times;</span>
			<h2>오픈채팅방 만들기</h2>
			<form action="${ctx}/chat/createOpenChat" id="newChatForm" method="POST" enctype="multipart/form-data">
				<label>프로필 이미지</label>
				<div class="open-chat-img-wrap">
					<img id="openChatImg" class="open-chat-profile-img"
					     src="data:image/svg+xml,%3Csvg xmlns=%27http://www.w3.org/2000/svg%27 width=%2780%27 height=%2780%27 viewBox=%270 0 24 24%27%3E%3Crect width=%2724%27 height=%2724%27 rx=%274%27 fill=%27%23E2E8F0%27/%3E%3Cpath d=%27m0 22.013c.14-1.537.93-2.877 2.091-3.777.466-.361 1.146-.266 1.536.174l1.873 2.112 1.849-2.119c.387-.444 1.069-.544 1.537-.184 1.173.9 1.972 2.248 2.113 3.794.014 1.093-.878 1.987-1.984 1.987H1.984C.879 24-.014 23.106 0 22.013Zm13 0c-.014 1.093.878 1.987 1.984 1.987h7.032c1.106 0 1.998-.894 1.984-1.987-.141-1.547-.941-2.895-2.113-3.794-.469-.36-1.15-.26-1.537.184l-1.849 2.119-1.873-2.112c-.39-.44-1.07-.535-1.536-.174-1.16.9-1.951 2.24-2.091 3.777Zm9.5-10.013c0-2.206-1.794-4-4-4s-4 1.794-4 4 1.794 4 4 4 4-1.794 4-4Zm-6.5-8c0-2.206-1.794-4-4-4s-4 1.794-4 4 1.794 4 4 4 4-1.794 4-4Zm-6.5 8c0-2.206-1.794-4-4-4s-4 1.794-4 4 1.794 4 4 4 4-1.794 4-4Z%27 fill=%27%23718096%27/%3E%3C/svg%3E"
					     alt="오픈 채팅방 기본 이미지">
					<input type="hidden" id="openchatProfileImg" name="chatProfileImg" value="">
					<label for="imgUpload" class="adit-profile-img">
						<img src="${ctx}/resources/icon/camera_icon.svg" alt="사진 업로드 아이콘">
					</label>
					<input type="file" id="imgUpload" name="imgUpload" accept="image/*" onchange="uploadImg(this)">
				</div>
				<label>채팅방 이름</label>
				<input id="openChatTitle" name="title" class="open-chat-form" type="text" maxlength="20" onkeyup="validateTitle()">
				<p class="modal-input-msg">최대 20자까지 입력 가능합니다.</p>
				<label>최대 인원</label>
				<input id="openChatPersons" name="persons" class="open-chat-form" type="number" min="2" max="8" onkeyup="validatePersons()">
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
		const receiverId = btn.getAttribute("data-id");
		document.getElementById("receiverId").value = receiverId;
		document.getElementById("chatForm").submit();
	}

	let currentIndex = 0;
	const list = document.querySelector(".profile-list");
	const items = document.querySelectorAll(".profile-list li");
	const cardWidth = 230 + 20;
	const visibleCards = 4;
	const totalCards = items.length;
	const maxIndex = totalCards - visibleCards;
	const joinedOpenRooms = new Set([
		  <c:forEach var="mc" items="${myChatList}">
		    <c:if test="${mc.chatType eq 'group'}">
		      '${mc.roomId}',
		    </c:if>
		  </c:forEach>
		  ]);

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

	function openModal(event) {
		event.preventDefault();
		const userId = '<%=session.getAttribute("id") == null ? "" : session.getAttribute("id")%>';
		if (!userId) {
			location.href = "${ctx}/chat/loginCheck";
			return;
		}
		document.getElementById("myModal").style.display = "block";
	}

	function closeModal() {
		document.getElementById("newChatForm").reset();
		const msgAll = document.querySelectorAll(".modal-input-msg");
		msgAll.forEach((msg, index) => {
			if (index === 0) msg.textContent = "최대 20자까지 입력 가능합니다.";
			if (index === 1) msg.textContent = "최대 8명까지 입장 가능합니다.";
			msg.classList.remove("err")
		});
		document.getElementById("openChatImg").src =
		  "data:image/svg+xml,%3Csvg xmlns=%27http://www.w3.org/2000/svg%27 width=%2780%27 height=%2780%27 viewBox=%270 0 24 24%27%3E%3Crect width=%2724%27 height=%2724%27 rx=%274%27 fill=%27%23E2E8F0%27/%3E%3Cpath d=%27m0 22.013c.14-1.537.93-2.877 2.091-3.777.466-.361 1.146-.266 1.536.174l1.873 2.112 1.849-2.119c.387-.444 1.069-.544 1.537-.184 1.173.9 1.972 2.248 2.113 3.794.014 1.093-.878 1.987-1.984 1.987H1.984C.879 24-.014 23.106 0 22.013Zm13 0c-.014 1.093.878 1.987 1.984 1.987h7.032c1.106 0 1.998-.894 1.984-1.987-.141-1.547-.941-2.895-2.113-3.794-.469-.36-1.15-.26-1.537.184l-1.849 2.119-1.873-2.112c-.39-.44-1.07-.535-1.536-.174-1.16.9-1.951 2.24-2.091 3.777Zm9.5-10.013c0-2.206-1.794-4-4-4s-4 1.794-4 4 1.794 4 4 4 4-1.794 4-4Zm-6.5-8c0-2.206-1.794-4-4-4s-4 1.794-4 4 1.794 4 4 4 4-1.794 4-4Zm-6.5 8c0-2.206-1.794-4-4-4s-4 1.794-4 4 1.794 4 4 4 4-1.794 4-4Z%27 fill=%27%23718096%27/%3E%3C/svg%3E";
		document.getElementById("openchatProfileImg").value = "";
		document.getElementById("myModal").style.display = "none";
	}

	function confirmAction(event) {
		event.preventDefault();
		const isValid = validate();
		if (isValid) { document.getElementById("newChatForm").submit(); }
	}

	function validate() {
		const isTitleValid = validateTitle();
		const isPersonsValid = validatePersons();
		return isTitleValid && isPersonsValid;
	}

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

	function doChat(event){
		const roomId = event.getAttribute("data-room-id");
		const chatType = event.getAttribute("data-room-type");
		const imgEl = event.querySelector("img");
		const productId = imgEl ? imgEl.getAttribute("data-product-id") : null;
		const base = "${ctx}/chat/doChat?roomId=" + roomId + "&chatType=" + chatType;
		location.href = productId ? (base + "&productId=" + productId) : base;
	}

	function doOpenChat(event){
		  const roomId = event.getAttribute("data-room-id");

		  // 이미 내가 속한 방이면 정원 관계없이 바로 입장
		  if (joinedOpenRooms.has(roomId)) {
		    location.href = "${ctx}/chat/doOpenChat?roomId=" + roomId;
		    return;
		  }

		  // 내가 속한 방이 아니면 정원 체크
		  const personsEl = event.querySelector("span[data-persons]");
		  const countEl = event.querySelector("span[data-user-count]");
		  const persons = personsEl ? parseInt(personsEl.getAttribute("data-persons"), 10) : NaN;
		  const count = countEl ? parseInt(countEl.getAttribute("data-user-count"), 10) : NaN;

		  if (!isNaN(persons) && !isNaN(count) && persons <= count){
		    alert("이 채팅방은 이미 인원이 다 찼어요.");
		    return;
		  }

		  location.href = "${ctx}/chat/doOpenChat?roomId=" + roomId;
		}


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
