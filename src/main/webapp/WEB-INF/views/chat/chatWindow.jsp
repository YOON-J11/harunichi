<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}"/>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>채팅창</title>
<link href="${contextPath}/resources/css/chat/chatWindow.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
</head>
<body>
<div class="chat-center-wrapper">
  <div id="chatContainer">
    <div id="chatTop">
      <div class="chat-top-left">
        <c:choose>
          <c:when test="${chatType eq 'personal'}">
            <c:choose>
              <c:when test="${not empty profileImg and fn:startsWith(profileImg, 'http')}">
                <img class="profile-img" src="${profileImg}" alt="개인채팅 사용자 프로필" onerror="this.onerror=null;this.src='${contextPath}/resources/icon/basic_profile.jpg'">
              </c:when>
              <c:when test="${not empty profileImg and fn:startsWith(profileImg, '/')}">
                <img class="profile-img" src="${contextPath}${profileImg}" alt="개인채팅 사용자 프로필" onerror="this.onerror=null;this.src='${contextPath}/resources/icon/basic_profile.jpg'">
              </c:when>
              <c:when test="${not empty profileImg}">
                <img class="profile-img" src="${contextPath}/images/profile/${profileImg}" alt="개인채팅 사용자 프로필" onerror="this.onerror=null;this.src='${contextPath}/resources/icon/basic_profile.jpg'">
              </c:when>
              <c:otherwise>
                <img class="profile-img" src="${contextPath}/resources/icon/basic_profile.jpg" alt="기본 프로필">
              </c:otherwise>
            </c:choose>
          </c:when>
          <c:otherwise>
            <c:choose>
              <c:when test="${not empty profileImg and fn:startsWith(profileImg, 'http')}">
                <img class="profile-img" src="${profileImg}" alt="오픈채팅방 이미지" onerror="this.onerror=null;this.src='data:image/svg+xml,%3Csvg xmlns=%27http://www.w3.org/2000/svg%27 width=%2780%27 height=%2780%27 viewBox=%270 0 24 24%27%3E%3Crect width=%2724%27 height=%2724%27 rx=%274%27 fill=%27%23E2E8F0%27/%3E%3Cpath d=%27m0 22.013c.14-1.537.93-2.877 2.091-3.777.466-.361 1.146-.266 1.536.174l1.873 2.112 1.849-2.119c.387-.444 1.069-.544 1.537-.184 1.173.9 1.972 2.248 2.113 3.794.014 1.093-.878 1.987-1.984 1.987H1.984C.879 24-.014 23.106 0 22.013Zm13 0c-.014 1.093.878 1.987 1.984 1.987h7.032c1.106 0 1.998-.894 1.984-1.987-.141-1.547-.941-2.895-2.113-3.794-.469-.36-1.15-.26-1.537.184l-1.849 2.119-1.873-2.112c-.39-.44-1.07-.535-1.536-.174-1.16.9-1.951 2.24-2.091 3.777Zm9.5-10.013c0-2.206-1.794-4-4-4s-4 1.794-4 4 1.794 4 4 4 4-1.794 4-4Zm-6.5-8c0-2.206-1.794-4-4-4s-4 1.794-4 4 1.794 4 4 4 4-1.794 4-4Zm-6.5 8c0-2.206-1.794-4-4-4s-4 1.794-4 4 1.794 4 4 4 4-1.794 4-4Z%27 fill=%27%23718096%27/%3E%3C/svg%3E';">
              </c:when>
              <c:when test="${not empty profileImg and fn:startsWith(profileImg, '/')}">
                <img class="profile-img" src="${contextPath}${profileImg}" alt="오픈채팅방 이미지" onerror="this.onerror=null;this.src='data:image/svg+xml,%3Csvg xmlns=%27http://www.w3.org/2000/svg%27 width=%2780%27 height=%2780%27 viewBox=%270 0 24 24%27%3E%3Crect width=%2724%27 height=%2724%27 rx=%274%27 fill=%27%23E2E8F0%27/%3E%3Cpath d=%27m0 22.013c.14-1.537.93-2.877 2.091-3.777.466-.361 1.146-.266 1.536.174l1.873 2.112 1.849-2.119c.387-.444 1.069-.544 1.537-.184 1.173.9 1.972 2.248 2.113 3.794.014 1.093-.878 1.987-1.984 1.987H1.984C.879 24-.014 23.106 0 22.013Zm13 0c-.014 1.093.878 1.987 1.984 1.987h7.032c1.106 0 1.998-.894 1.984-1.987-.141-1.547-.941-2.895-2.113-3.794-.469-.36-1.15-.26-1.537.184l-1.849 2.119-1.873-2.112c-.39-.44-1.07-.535-1.536-.174-1.16.9-1.951 2.24-2.091 3.777Zm9.5-10.013c0-2.206-1.794-4-4-4s-4 1.794-4 4 1.794 4 4 4 4-1.794 4-4Zm-6.5-8c0-2.206-1.794-4-4-4s-4 1.794-4 4 1.794 4 4 4 4-1.794 4-4Zm-6.5 8c0-2.206-1.794-4-4-4s-4 1.794-4 4 1.794 4 4 4 4-1.794 4-4Z%27 fill=%27%23718096%27/%3E%3C/svg%3E';">
              </c:when>
              <c:when test="${not empty profileImg}">
                <img class="profile-img" src="${contextPath}/images/chat/${profileImg}" alt="오픈채팅방 이미지" onerror="this.onerror=null;this.src='data:image/svg+xml,%3Csvg xmlns=%27http://www.w3.org/2000/svg%27 width=%2780%27 height=%2780%27 viewBox=%270 0 24 24%27%3E%3Crect width=%2724%27 height=%2724%27 rx=%274%27 fill=%27%23E2E8F0%27/%3E%3Cpath d=%27m0 22.013c.14-1.537.93-2.877 2.091-3.777.466-.361 1.146-.266 1.536.174l1.873 2.112 1.849-2.119c.387-.444 1.069-.544 1.537-.184 1.173.9 1.972 2.248 2.113 3.794.014 1.093-.878 1.987-1.984 1.987H1.984C.879 24-.014 23.106 0 22.013Zm13 0c-.014 1.093.878 1.987 1.984 1.987h7.032c1.106 0 1.998-.894 1.984-1.987-.141-1.547-.941-2.895-2.113-3.794-.469-.36-1.15-.26-1.537.184l-1.849 2.119-1.873-2.112c-.39-.44-1.07-.535-1.536-.174-1.16.9-1.951 2.24-2.091 3.777Zm9.5-10.013c0-2.206-1.794-4-4-4s-4 1.794-4 4 1.794 4 4 4 4-1.794 4-4Zm-6.5-8c0-2.206-1.794-4-4-4s-4 1.794-4 4 1.794 4 4 4 4-1.794 4-4Zm-6.5 8c0-2.206-1.794-4-4-4s-4 1.794-4 4 1.794 4 4 4 4-1.794 4-4Z%27 fill=%27%23718096%27/%3E%3C/svg%3E';">
              </c:when>
              <c:otherwise>
                <img class="profile-img" src="data:image/svg+xml,%3Csvg xmlns=%27http://www.w3.org/2000/svg%27 width=%2780%27 height=%2780%27 viewBox=%270 0 24 24%27%3E%3Crect width=%2724%27 height=%2724%27 rx=%274%27 fill=%27%23E2E8F0%27/%3E%3Cpath d=%27m0 22.013c.14-1.537.93-2.877 2.091-3.777.466-.361 1.146-.266 1.536.174l1.873 2.112 1.849-2.119c.387-.444 1.069-.544 1.537-.184 1.173.9 1.972 2.248 2.113 3.794.014 1.093-.878 1.987-1.984 1.987H1.984C.879 24-.014 23.106 0 22.013Zm13 0c-.014 1.093.878 1.987 1.984 1.987h7.032c1.106 0 1.998-.894 1.984-1.987-.141-1.547-.941-2.895-2.113-3.794-.469-.36-1.15-.26-1.537.184l-1.849 2.119-1.873-2.112c-.39-.44-1.07-.535-1.536-.174-1.16.9-1.951 2.24-2.091 3.777Zm9.5-10.013c0-2.206-1.794-4-4-4s-4 1.794-4 4 1.794 4 4 4 4-1.794 4-4Zm-6.5-8c0-2.206-1.794-4-4-4s-4 1.794-4 4 1.794 4 4 4 4-1.794 4-4Zm-6.5 8c0-2.206-1.794-4-4-4s-4 1.794-4 4 1.794 4 4 4 4-1.794 4-4Z%27 fill=%27%23718096%27/%3E%3C/svg%3E" alt="오픈채팅방 기본 이미지">
              </c:otherwise>
            </c:choose>
          </c:otherwise>
        </c:choose>
        <div class="room-info">
          <span class="room-title" id="receiverId">${title}<span class="user-count">(${count})</span></span>
        </div>
      </div>
      <div class="chat-top-right">
        <a href="#" id="searchIcon" class="chat-setting" onclick="chatSearch();"><i class="bi bi-search"></i></a>
        <form action="#" id="searchBar" class="hidden">
          <input type="text" name="chatKeyword" placeholder="대화내용 입력">
          <button id="searchBtn" onclick="searchSubmit(event);">검색</button>
        </form>
        <a href="#" id="chatSettingBtn" class="chat-setting" onclick="chatSetting();"><i class="bi bi-list"></i></a>
        <button class="disconnect-btn" onclick="disconnect();"><i class="bi bi-x-lg"></i></button>
      </div>
      <div id="chatSettingMenu" class="chat-setting-menu hidden">
        <ul>
          <li onclick="showChatInfo()" class="chat-setting-list"><span><i class="bi bi-info-circle"></i></span>채팅방 정보</li>
          <li onclick="leaveChatRoom()" class="chat-setting-list"><span><i class="bi bi-box-arrow-right"></i></span>채팅방 나가기</li>
        </ul>
      </div>
    </div>

    <div id="searchNavigation" class="hidden">
      <button onclick="goToPrev()"><i class="bi bi-arrow-up-short"></i></button>
      <span id="searchIndex">0 / 0</span>
      <button onclick="goToNext()"><i class="bi bi-arrow-down-short"></i></button>
    </div>
    <p id="noResultMsg" class="hidden">검색된 결과가 없습니다.</p>

    <c:if test="${!empty productVo}">
      <div id="productWrap">
        <div id="productImg">
          <c:if test="${productVo.productStatus eq -1}">
            <a href="${contextPath}/product/view?productId=${productVo.productId}">
              <img class="product-img sold-out" src="${contextPath}/images/product/${productVo.productImg}" alt="상품 이미지">
            </a>
          </c:if>
          <c:if test="${productVo.productStatus != -1}">
            <a href="${contextPath}/product/view?productId=${productVo.productId}">
              <img class="product-img" src="${contextPath}/images/product/${productVo.productImg}" alt="상품 이미지">
            </a>
          </c:if>
        </div>
        <div id="productInfo">
          <p>
            <span class="product-status bold">
              <c:if test="${productVo.productStatus eq 1}">나눔</c:if>
              <c:if test="${productVo.productStatus eq 0}">판매</c:if>
              <c:if test="${productVo.productStatus eq -1}">거래완료</c:if>
            </span>
            <span>${productVo.productTitle}</span>
          </p>
          <p class="bold">${productVo.productPrice} 원</p>
        </div>
        <div class="product-btn-wrap">
          <c:if test="${productVo.productStatus != -1}">
            <a href="#" class="product-btn pay" onclick="doPay()">결제하기</a>
          </c:if>
          <a href="#" class="product-btn" onclick="closeProduct()">닫기</a>
        </div>
      </div>
    </c:if>

    <div id="messageContainer"></div>
    <div id="inputContainer">
      <input type="text" id="chatMessage" onkeyup="enterKey();">
      <button id="sendBtn" onclick="sendMessage();">전송</button>
    </div>
  </div>
</div>

<div id="chatInfoModal" class="chat-info-modal">
  <div class="modal-content">
    <span class="close" onclick="closeModal()">&times;</span>
    <h2>채팅방 정보</h2>
    <form action="${contextPath}/chat/updateOpenChat" id="updateChatForm" method="POST" enctype="multipart/form-data">
      <div class="chat-img-wrap">
        <c:choose>
          <c:when test="${chatType eq 'personal'}">
            <c:choose>
              <c:when test="${not empty profileImg and fn:startsWith(profileImg, 'http')}">
                <img class="chat-profile-img" src="${profileImg}" alt="개인채팅 사용자 프로필" onerror="this.onerror=null;this.src='${contextPath}/resources/icon/basic_profile.jpg'">
              </c:when>
              <c:when test="${not empty profileImg and fn:startsWith(profileImg, '/')}">
                <img class="chat-profile-img" src="${contextPath}${profileImg}" alt="개인채팅 사용자 프로필" onerror="this.onerror=null;this.src='${contextPath}/resources/icon/basic_profile.jpg'">
              </c:when>
              <c:when test="${not empty profileImg}">
                <img class="chat-profile-img" src="${contextPath}/images/profile/${profileImg}" alt="개인채팅 사용자 프로필" onerror="this.onerror=null;this.src='${contextPath}/resources/icon/basic_profile.jpg'">
              </c:when>
              <c:otherwise>
                <img class="chat-profile-img" src="${contextPath}/resources/icon/basic_profile.jpg" alt="기본 프로필">
              </c:otherwise>
            </c:choose>
          </c:when>
          <c:otherwise>
            <c:choose>
              <c:when test="${not empty profileImg and fn:startsWith(profileImg, 'http')}">
                <img id="openChatImg" class="chat-profile-img" src="${profileImg}" alt="오픈채팅방 이미지" onerror="this.onerror=null;this.src='data:image/svg+xml,%3Csvg xmlns=%27http://www.w3.org/2000/svg%27 width=%2724%27 height=%2724%27 viewBox=%270 0 24 24%27%3E%3Cpath d=%27m0 22.013c.14-1.537.93-2.877 2.091-3.777.466-.361 1.146-.266 1.536.174l1.873 2.112 1.849-2.119c.387-.444 1.069-.544 1.537-.184 1.173.9 1.972 2.248 2.113 3.794.014 1.093-.878 1.987-1.984 1.987H1.984C.879 24-.014 23.106 0 22.013Zm13 0c-.014 1.093.878 1.987 1.984 1.987h7.032c1.106 0 1.998-.894 1.984-1.987-.141-1.547-.941-2.895-2.113-3.794-.469-.36-1.15-.26-1.537.184l-1.849 2.119-1.873-2.112c-.39-.44-1.07-.535-1.536-.174-1.16.9-1.951 2.24-2.091 3.777Zm9.5-10.013c0-2.206-1.794-4-4-4s-4 1.794-4 4 1.794 4 4 4 4-1.794 4-4Zm-6.5-8c0-2.206-1.794-4-4-4s-4 1.794-4 4 1.794 4 4 4 4-1.794 4-4Zm-6.5 8c0-2.206-1.794-4-4-4s-4 1.794-4 4 1.794 4 4 4 4-1.794 4-4Z%27 fill=%27%23838BA0%27/%3E%3C/svg%3E';">
              </c:when>
              <c:when test="${not empty profileImg and fn:startsWith(profileImg, '/')}">
                <img id="openChatImg" class="chat-profile-img" src="${contextPath}${profileImg}" alt="오픈채팅방 이미지" onerror="this.onerror=null;this.src='data:image/svg+xml,%3Csvg xmlns=%27http://www.w3.org/2000/svg%27 width=%2724%27 height=%2724%27 viewBox=%270 0 24 24%27%3E%3Cpath d=%27m0 22.013c.14-1.537.93-2.877 2.091-3.777.466-.361 1.146-.266 1.536.174l1.873 2.112 1.849-2.119c.387-.444 1.069-.544 1.537-.184 1.173.9 1.972 2.248 2.113 3.794.014 1.093-.878 1.987-1.984 1.987H1.984C.879 24-.014 23.106 0 22.013Zm13 0c-.014 1.093.878 1.987 1.984 1.987h7.032c1.106 0 1.998-.894 1.984-1.987-.141-1.547-.941-2.895-2.113-3.794-.469-.36-1.15-.26-1.537.184l-1.849 2.119-1.873-2.112c-.39-.44-1.07-.535-1.536-.174-1.16.9-1.951 2.24-2.091 3.777Zm9.5-10.013c0-2.206-1.794-4-4-4s-4 1.794-4 4 1.794 4 4 4 4-1.794 4-4Zm-6.5-8c0-2.206-1.794-4-4-4s-4 1.794-4 4 1.794 4 4 4 4-1.794 4-4Zm-6.5 8c0-2.206-1.794-4-4-4s-4 1.794-4 4 1.794 4 4 4 4-1.794 4-4Z%27 fill=%27%23838BA0%27/%3E%3C/svg%3E';">
              </c:when>
              <c:when test="${not empty profileImg}">
                <img id="openChatImg" class="chat-profile-img" src="${contextPath}/images/chat/${profileImg}" alt="오픈채팅방 이미지" onerror="this.onerror=null;this.src='data:image/svg+xml,%3Csvg xmlns=%27http://www.w3.org/2000/svg%27 width=%2724%27 height=%2724%27 viewBox=%270 0 24 24%27%3E%3Cpath d=%27m0 22.013c.14-1.537.93-2.877 2.091-3.777.466-.361 1.146-.266 1.536.174l1.873 2.112 1.849-2.119c.387-.444 1.069-.544 1.537-.184 1.173.9 1.972 2.248 2.113 3.794.014 1.093-.878 1.987-1.984 1.987H1.984C.879 24-.014 23.106 0 22.013Zm13 0c-.014 1.093.878 1.987 1.984 1.987h7.032c1.106 0 1.998-.894 1.984-1.987-.141-1.547-.941-2.895-2.113-3.794-.469-.36-1.15-.26-1.537.184l-1.849 2.119-1.873-2.112c-.39-.44-1.07-.535-1.536-.174-1.16.9-1.951 2.24-2.091 3.777Zm9.5-10.013c0-2.206-1.794-4-4-4s-4 1.794-4 4 1.794 4 4 4 4-1.794 4-4Zm-6.5-8c0-2.206-1.794-4-4-4s-4 1.794-4 4 1.794 4 4 4 4-1.794 4-4Zm-6.5 8c0-2.206-1.794-4-4-4s-4 1.794-4 4 1.794 4 4 4 4-1.794 4-4Z%27 fill=%27%23838BA0%27/%3E%3C/svg%3E';">
              </c:when>
              <c:otherwise>
                <img id="openChatImg" class="chat-profile-img" src="data:image/svg+xml,%3Csvg xmlns=%27http://www.w3.org/2000/svg%27 width=%2724%27 height=%2724%27 viewBox=%270 0 24 24%27%3E%3Cpath d=%27m0 22.013c.14-1.537.93-2.877 2.091-3.777.466-.361 1.146-.266 1.536.174l1.873 2.112 1.849-2.119c.387-.444 1.069-.544 1.537-.184 1.173.9 1.972 2.248 2.113 3.794.014 1.093-.878 1.987-1.984 1.987H1.984C.879 24-.014 23.106 0 22.013Zm13 0c-.014 1.093.878 1.987 1.984 1.987h7.032c1.106 0 1.998-.894 1.984-1.987-.141-1.547-.941-2.895-2.113-3.794-.469-.36-1.15-.26-1.537.184l-1.849 2.119-1.873-2.112c-.39-.44-1.07-.535-1.536-.174-1.16.9-1.951 2.24-2.091 3.777Zm9.5-10.013c0-2.206-1.794-4-4-4s-4 1.794-4 4 1.794 4 4 4 4-1.794 4-4Zm-6.5-8c0-2.206-1.794-4-4-4s-4 1.794-4 4 1.794 4 4 4 4-1.794 4-4Zm-6.5 8c0-2.206-1.794-4-4-4s-4 1.794-4 4 1.794 4 4 4 4-1.794 4-4Z%27 fill=%27%23838BA0%27/%3E%3C/svg%3E" alt="오픈채팅방 기본 이미지">
              </c:otherwise>
            </c:choose>
          </c:otherwise>
        </c:choose>
        <input type="hidden" id="originalImg" name="chatProfileImg" value="${profileImg}">
        <c:if test="${sessionScope.member.id eq leader}">
          <label for="imgUpload" class="adit-profile-img hidden" id="aditProfileImg">
            <img src="${contextPath}/resources/icon/camera_icon.svg" alt="사진 업로드 아이콘">
          </label>
          <input type="file" id="imgUpload" name="imgUpload" accept="image/*" onchange="uploadImg(this)" style="display:none;">
        </c:if>
      </div>
      <div id="chatInfoWrap" class="chat-info-wrap">
        <label class="chat-title">${title}</label>
        <input id="chatTitle" name="title" class="chat-form hidden" type="text" maxlength="20" onkeyup="validateTitle()">
        <p class="modal-input-msg hidden"></p>
        <label class="chat-persons"><i class="bi bi-person-fill"></i> ${count} / ${persons}</label>
        <input id="chatPersons" name="persons" class="chat-form hidden" type="number" min="${count}" max="8" onkeyup="validatePersons()">
        <p class="modal-input-msg hidden"></p>
      </div>
      <ul class="user-list">
        <c:forEach var="user" items="${userList}">
          <li>
            <c:if test="${user.id ne leader}">
              <input type="radio" class="selected-user-id hidden" name="selectedUserId" data-user-nick="${user.nick}" value="${user.id}">
            </c:if>
            <a href="${contextPath}/mypage?id=${user.id}">
              <c:choose>
                <c:when test="${not empty user.profileImg and fn:startsWith(user.profileImg, 'http')}">
                  <img class="user-profile-img" src="${user.profileImg}" alt="채팅 참여자 프로필" onerror="this.onerror=null;this.src='${contextPath}/resources/icon/basic_profile.jpg'">
                </c:when>
                <c:when test="${not empty user.profileImg and fn:startsWith(user.profileImg, '/')}">
                  <img class="user-profile-img" src="${contextPath}${user.profileImg}" alt="채팅 참여자 프로필" onerror="this.onerror=null;this.src='${contextPath}/resources/icon/basic_profile.jpg'">
                </c:when>
                <c:when test="${not empty user.profileImg}">
                  <img class="user-profile-img" src="${contextPath}/images/profile/${user.profileImg}" alt="채팅 참여자 프로필" onerror="this.onerror=null;this.src='${contextPath}/resources/icon/basic_profile.jpg'">
                </c:when>
                <c:otherwise>
                  <img class="user-profile-img" src="${contextPath}/resources/icon/basic_profile.jpg" alt="기본 프로필">
                </c:otherwise>
              </c:choose>
            </a>
            <span>${user.nick}</span>
            <c:if test="${user.id eq leader}">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-star-fill" viewBox="0 0 16 16"><path d="M3.612 15.443c-.386.198-.824-.149-.746-.592l.83-4.73L.173 6.765c-.329-.314-.158-.888.283-.95l4.898-.696L7.538.792c.197-.39.73-.39.927 0l2.184 4.327 4.898.696c.441.062.612.636.282.95l-3.522 3.356.83 4.73c.078.443-.36.79-.746.592L8 13.187l-4.389 2.256z"/></svg>
            </c:if>
          </li>
        </c:forEach>
      </ul>
      <c:if test="${sessionScope.id eq leader}">
        <div class="modal-btn-wrap">
          <button class="modal-btn" id="editBtn" onclick="chatRoomUpdate(event)">채팅방 수정</button>
          <button class="modal-btn" id="chatMemberBtn" type="button" onclick="memberManagement()">참여자 관리</button>
          <button class="modal-btn" id="editSubmitBtn" onclick="submitEdit(event)">수정</button>
          <button type="button" class="modal-btn hidden" id="changeRoomLeader" onclick="changeLeader()">방장위임</button>
          <button type="button" class="modal-btn hidden" id="kickMemberFromRoom" onclick="kickMember()">강퇴</button>
          <button type="button" class="modal-btn" id="editCancelBtn" onclick="cancelEdit()">취소</button>
        </div>
      </c:if>
      <input type="hidden" name="chatType" value="group">
      <input type="hidden" name="roomId" value="${roomId}">
    </form>
  </div>
</div>
</body>

<script type="text/javascript">
var chatWindow, chatMessage;
var webSocket, receiverId, lastDate, userNick;
var roomId = "${roomId}";
var senderId = "${sessionScope.id}";
var chatType = "${chatType}";
var count = "${count}";
var leader = "${leader}";

window.onload = function() {
  chatWindow = document.getElementById("messageContainer");
  chatMessage = document.getElementById("chatMessage");
  receiverId = document.getElementById("receiverId").value;

  fetch("${pageContext.request.contextPath}/chat/history?roomId=" + roomId)
    .then(response => response.json())
    .then(messages => {
      messages.forEach(msg => {
        const sentDate = new Date(msg.sentTime);
        const year = sentDate.getFullYear();
        const month = (sentDate.getMonth() + 1).toString().padStart(2, '0');
        const day = sentDate.getDate().toString().padStart(2, '0');
        const currentDateStr = year + "-" + month + "-" + day;
        if (lastDate !== currentDateStr) {
          const dateDisplay = new Date(sentDate).toLocaleDateString('ko-KR', {year:'numeric', month:'long', day:'numeric'});
          chatWindow.innerHTML += "<div class='date-text'>" + dateDisplay + "</div>";
          lastDate = currentDateStr;
        }
        const sender = msg.senderId;
        const nickname = msg.nickname;
        const message = msg.message;
        const time = formatTime(sentDate);
        const isGroupChat = chatType === "group";
        chatWindow.innerHTML += (isGroupChat && sender !== senderId ? "<div class='nickname'>" + nickname + "</div>" : "")
          + "<div class='" + (sender === senderId ? "my-msg" : "other-msg") + "'>"
          + "<div class='message'>" + message + "</div>"
          + "<span class='time'>" + time + "</span></div>";
      });
      chatWindow.scrollTop = chatWindow.scrollHeight;
      connectWebSocket();
    });
}

function formatTime(date) {
  const d = date ? new Date(date) : new Date();
  const hours = d.getHours();
  const minutes = d.getMinutes().toString().padStart(2, '0');
  const ampm = hours >= 12 ? "오후" : "오전";
  const displayHour = hours % 12 === 0 ? 12 : hours % 12;
  return ampm + " " + displayHour + ":" + minutes;
}

function connectWebSocket(){
  webSocket = new WebSocket("<%=application.getInitParameter("CHAT_ADDR")%>/ChattingServer?roomId=" + roomId);
  webSocket.onopen = function() {
    if (chatType == 'personal' && count < 2) {
      chatWindow.innerHTML += "<p class='server-mag'>대화 상대가 없습니다.</p><br/>";
      chatWindow.scrollTop = chatWindow.scrollHeight;
      document.getElementById("chatMessage").disabled = true;
      document.getElementById("sendBtn").disabled = true;
      webSocket.close();
      return;
    } else {
      chatWindow.innerHTML += "<p class='server-mag'>채팅방에 입장하였습니다.</p><br/>";
      chatWindow.scrollTop = chatWindow.scrollHeight;
    }
  };
  webSocket.onclose = function() {
    chatWindow.innerHTML += "<p class='server-mag'>채팅방 연결이 종료되었습니다.</p><br/>";
    chatWindow.scrollTop = chatWindow.scrollHeight;
  };
  webSocket.onerror = function(event) {
    alert(event.data);
    chatWindow.innerHTML += "<p class='server-mag'>채팅 중에 에러가 발생하였습니다.</p><br/>";
    chatWindow.scrollTop = chatWindow.scrollHeight;
  };
  webSocket.onmessage = function(event) {
    var message = event.data.split("|");
    var sender = message[0];
    var nickname = message[1];
    var content = message[2];
    var time = formatTime();
    if (sender === "SYSTEM") {
      chatWindow.innerHTML += "<p class='server-mag'>" + message[1] + "</p><br/>";
      if(chatType === "personal"){
        document.getElementById("chatMessage").disabled = true;
        document.getElementById("sendBtn").disabled = true;
      }
      chatWindow.scrollTop = chatWindow.scrollHeight;
      return;
    }
    if (content != "") {
      const isGroupChat = chatType === "group";
      chatWindow.innerHTML += (isGroupChat ? "<div class='nickname'>" + nickname + "</div>" : "")
        + "<div class='other-msg'><div class='message'>" + content + "</div>"
        + "<span class='time'>" + time + "</span></div>";
    }
    chatWindow.scrollTop = chatWindow.scrollHeight;
  };
}

function getByteLength(str) { return new Blob([str]).size; }
document.getElementById("chatMessage").addEventListener("input", function () {
  let msg = this.value, maxByte = 1000;
  while (getByteLength(msg) > maxByte) { msg = msg.slice(0, -1); }
  this.value = msg;
});

function sendMessage() {
  if (chatMessage.value == "") { return; }
  const chatData = {
    roomId : "${roomId}",
    chatType : "${chatType != null ? chatType : param.chatType}",
    senderId : senderId,
    nickname : "${nickname}",
    receiverId : "${receiverId != null ? receiverId : param.receiverId}",
    message : chatMessage.value
  };
  chatWindow.innerHTML += "<div class='my-msg'><div class='message'>" + chatMessage.value + "</div><span class='time'>" + formatTime() + "</span></div>";
  webSocket.send(JSON.stringify(chatData));
  chatMessage.value = "";
  chatWindow.scrollTop = chatWindow.scrollHeight;
}

function enterKey() { if (window.event.keyCode == 13) { sendMessage(); } }

function disconnect() {
  webSocket.close();
  window.location.href="${contextPath}/chat/main";
}

function closeProduct(){
  const chatTop = document.getElementById("productWrap");
  if (chatTop) {
    chatTop.remove();
    location.href = "${contextPath}/chat/deleteProductId?roomId=${roomId}&productId=${productVo.productId}";
  }
}

function doPay() { location.href = "${contextPath}/payment/form?productId=${productVo.productId}"; }

function chatSearch(){
  const search = document.getElementById("searchBar");
  search.classList.toggle("hidden");
  const searchIcon = document.getElementById("searchIcon");
  searchIcon.classList.toggle("search-icon");
  if(search.classList.contains("hidden")){
    document.getElementById("noResultMsg").classList.add("hidden");
    document.getElementById("searchNavigation").classList.add("hidden");
    document.getElementById("searchNavigation").style.display = "";
    document.querySelector("input[name='chatKeyword']").value = "";
    document.querySelectorAll(".highlight").forEach(el => { el.classList.remove("highlight"); });
  }
}

let matchedMessages = [];
let currentIndex = -1;

function searchSubmit(event){
  event.preventDefault();
  const keyword = document.querySelector("input[name='chatKeyword']").value.trim();
  matchedMessages = [];
  currentIndex = -1;
  document.getElementById("noResultMsg").classList.add("hidden");
  document.getElementById("searchNavigation").classList.add("hidden");
  document.getElementById("searchNavigation").style.display = "";
  if (!keyword) return;
  document.querySelectorAll(".highlight").forEach(el => { el.classList.remove("highlight"); });
  const messages = document.querySelectorAll(".message");
  messages.forEach((msg) => { if (msg.textContent.includes(keyword)) matchedMessages.push(msg); });
  if (matchedMessages.length > 0) {
    document.getElementById("noResultMsg").classList.add("hidden");
    document.getElementById("searchNavigation").classList.remove("hidden");
    document.getElementById("searchNavigation").style.display = "flex";
    currentIndex = 0;
    scrollToMessage(currentIndex);
    updateSearchIndex();
  } else {
    document.getElementById("noResultMsg").classList.remove("hidden");
    document.getElementById("searchNavigation").classList.add("hidden");
  }
}

function scrollToMessage(index) {
  matchedMessages.forEach(msg => msg.classList.remove("highlight"));
  const target = matchedMessages[index];
  target.scrollIntoView({ behavior: "smooth", block: "center" });
  target.classList.add("highlight");
}

function updateSearchIndex() { document.getElementById("searchIndex").textContent = (currentIndex + 1) + "/" + matchedMessages.length; }
function goToPrev() { if (matchedMessages.length === 0) return; currentIndex = (currentIndex - 1 + matchedMessages.length) % matchedMessages.length; scrollToMessage(currentIndex); updateSearchIndex(); }
function goToNext() { if (matchedMessages.length === 0) return; currentIndex = (currentIndex + 1) % matchedMessages.length; scrollToMessage(currentIndex); updateSearchIndex(); }

function chatSetting(){
  const menu = document.getElementById("chatSettingMenu");
  menu.classList.toggle("hidden");
}

document.addEventListener("click", function(event) {
  const menu = document.getElementById("chatSettingMenu");
  const button = document.getElementById("chatSettingBtn");
  if (!menu.contains(event.target) && !button.contains(event.target)) {
    menu.classList.add("hidden");
  }
});

function leaveChatRoom() {
  if(senderId === leader && count > 1){
    alert("방장은 채팅방을 나갈 수 없습니다. 권한을 다른 멤버에게 위임해주세요.");
    return;
  }
  if (confirm("정말 채팅방을 나가시겠습니까?")) {
    if (webSocket && webSocket.readyState === WebSocket.OPEN) {
      webSocket.send(JSON.stringify({ senderId : senderId, nickname : (chatType === 'group') ? "${nickname}" : "", message : "SYSTEM|LEAVE", chatType : chatType }));
    }
    setTimeout(() => {
      if (webSocket && webSocket.readyState === WebSocket.OPEN) { webSocket.close(); }
      location.href = "${contextPath}/chat/leaveChatRoom?roomId=${roomId}";
    }, 300);
  }
}

const isLeader = "${sessionScope.member.id eq leader}";
function showChatInfo() {
  event.preventDefault();
  const userId = '<%= session.getAttribute("id") == null ? "" : session.getAttribute("id") %>';
  if (!userId) {
    location.href = "<%= request.getContextPath() %>/chat/loginChek";
    return;
  }
  if(isLeader === 'true'){
    toggleDisplay(["editSubmitBtn", "editCancelBtn"], "none");
    toggleElements(["#editBtn", "#chatMemberBtn"], ["#aditProfileImg"]);
  }
  toggleDisplay(["chatInfoModal"], "block");
}

function closeModal() {
  if(isLeader === 'true'){
    document.getElementById("updateChatForm").reset();
    toggleElements([".chat-title", ".chat-persons"], ["#chatTitle", "#chatPersons", ".modal-input-msg", ".selected-user-id", "#changeRoomLeader", "#kickMemberFromRoom"]);
    toggleDisplay(["editBtn", "chatMemberBtn"], "");
    document.querySelector('.chat-profile-img').src =  "${contextPath}/images/chat/${profileImg}";
  }
  toggleDisplay(["chatInfoModal"], "none");
}

function chatRoomUpdate(event) {
  event.preventDefault();
  document.getElementById('chatTitle').value = "${title}";
  document.getElementById('chatPersons').value = "${persons}";
  toggleElements(["#chatTitle", "#chatPersons", ".modal-input-msg", "#aditProfileImg"], [".chat-title", ".chat-persons", "#editBtn", "#chatMemberBtn"]);
  toggleDisplay(["editSubmitBtn", "editCancelBtn"], "");
}

function cancelEdit(){
  document.getElementById("updateChatForm").reset();
  document.querySelector('.chat-profile-img').src =  "${contextPath}/images/chat/${profileImg}";
  toggleElements([".chat-title", ".chat-persons", "#editBtn", "#chatMemberBtn"], ["#chatTitle", "#chatPersons", ".modal-input-msg", "#aditProfileImg", "#changeRoomLeader", "#kickMemberFromRoom", ".selected-user-id"]);
  toggleDisplay(["editCancelBtn", "editSubmitBtn"], "none");
  showChatInfo();
}

function submitEdit(event){
  event.preventDefault();
  const isValid = validate();
  if (isValid) { document.getElementById("updateChatForm").submit(); }
}

function validate() {
  const isTitleValid = validateTitle();
  const isPersonsValid = validatePersons();
  return isTitleValid && isPersonsValid;
}

function validateTitle() {
  const titleInput = document.getElementById("chatTitle");
  const msgTag = titleInput.nextElementSibling;
  const title = titleInput.value.trim();
  if (title.length === 0) {
    msgTag.textContent = "채팅방 이름을 입력해주세요. 최대 20자까지 입력 가능합니다.";
    msgTag.classList.add("err");
    return false;
  } else {
    msgTag.textContent = "";
    return true;
  }
}

function validatePersons() {
  const personInput = document.getElementById("chatPersons");
  const msgTag = personInput.nextElementSibling;
  const value = Number(personInput.value);
  const c = "${count}";
  if (isNaN(value) || value < c || value > 8) {
    msgTag.textContent = "현재 채팅방에 참여한 인원 이상 8명 이하로 입력해주세요.";
    msgTag.classList.add("err");
    return false;
  } else {
    msgTag.textContent = "";
    return true;
  }
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
    document.querySelector('.chat-profile-img').src = e.target.result;
  }
  reader.readAsDataURL(file);
}

function memberManagement(){
  toggleElements(["#changeRoomLeader", "#kickMemberFromRoom", ".selected-user-id"], ["#editBtn", "#chatMemberBtn"]);
  toggleDisplay(["editCancelBtn"], "");
}

function changeLeader(){
  const selected = document.querySelector('input[name="selectedUserId"]:checked');
  if (!selected) {
    alert("방장 권한을 위임할 멤버를 선택해주세요.");
    return;
  }
  const selectedUserId = selected.value;
  const userNick = selected.dataset.userNick;
  if (!confirm( userNick + "에게 방장 권한을 위임하시겠습니까?")) return;
  fetch("${contextPath}/chat/changeLeader", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ userId: selectedUserId, roomId: roomId })
  })
  .then(response => { if (!response.ok) throw new Error("서버 오류 발생"); return response.json(); })
  .then(data => {
    if (data.success) { alert("방장 권한이 성공적으로 위임되었습니다!"); location.reload(); }
    else { alert("방장 위임 실패: " + data.message); }
  })
  .catch(() => { alert("방장 위임 중 오류가 발생했습니다."); });
}

function kickMember(){
  const selected = document.querySelector('input[name="selectedUserId"]:checked');
  if (!selected) {
    alert("강퇴할 멤버를 선택해주세요.");
    return;
  }
  const selectedUserId = selected.value;
  const userNick = selected.dataset.userNick;
  if (!confirm("정말 " + userNick + "님을 강퇴하시겠습니까?")) return;
  fetch("${contextPath}/chat/kickMember", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ userId: selectedUserId, roomId: roomId })
  })
  .then(response => { if (!response.ok) throw new Error("서버 오류 발생"); return response.json(); })
  .then(data => {
    if (data.success) { alert(userNick + "님을 강퇴하였습니다."); location.reload(); }
    else { alert("멤버 강퇴 실패: " + data.message); }
  })
  .catch(() => { alert("멤버 강퇴 중 오류가 발생했습니다."); });
}

function toggleElements(showSelectors = [], hideSelectors = []) {
  showSelectors.forEach(sel => { document.querySelectorAll(sel).forEach(el => el.classList.remove('hidden')); });
  hideSelectors.forEach(sel => { document.querySelectorAll(sel).forEach(el => el.classList.add('hidden')); });
}

function toggleDisplay(ids = [], displayValue = "") {
  ids.forEach(id => {
    const el = document.getElementById(id);
    if (el) el.style.display = displayValue;
  });
}
</script>
</html>
