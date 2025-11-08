<%@ page language="java" contentType="text/html; charset=utf-8"
    pageEncoding="utf-8"
    isELIgnored="false"
    %>
<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles" %>    
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="contextPath"  value="${pageContext.request.contextPath}" />



<section class="header-inner">

    <a href="${pageContext.request.contextPath}/" class="header-logo">
	    <img src="${pageContext.request.contextPath}/resources/icon/logo2.svg">
	</a>
    
    <div class="header-main-content">
    	<div> </div>
	    <nav class="header-menu">
	        <ul>
	            <li>
	                <select id="country-select" name="country">
	                    <option value="kr" data-image="${contextPath}/resources/icon/south-korea_icon.png"${selectedCountry == 'kr' ? 'selected' : ''}>korea</option>
	                    <option value="jp" data-image="${contextPath}/resources/icon/japan_icon.png"${selectedCountry == 'jp' ? 'selected' : ''}>Japan</option>
	                </select>
	            </li>
	            <li>
	            	<c:if test="${sessionScope.id == 'admin'}">
					    <a href="${contextPath}/admin" class="go-to-admin-page-btn">어드민 페이지</a>
					</c:if>
	            </li>
	            <li>
	            	<c:if test="${not empty sessionScope.id}">
	            		<div class="login-status">
		            		<div class="profile-area-wrap">
		            			<a class="profile-area" onclick="toggleUserMenu(event)" style="cursor: pointer;">
									<c:choose>
									  <c:when test="${not empty sessionScope.member.profileImg}">
									    <c:choose>
									      <c:when test="${fn:startsWith(sessionScope.member.profileImg, 'http')}">
									        <img class="profile-image" src="${sessionScope.member.profileImg}" alt="프로필 이미지">
									      </c:when>
									      <c:otherwise>
									        <img class="profile-image"
									             src="<c:url value='/images/profile/${sessionScope.member.profileImg}'/>"
									             alt="프로필 이미지">
									      </c:otherwise>
									    </c:choose>
									  </c:when>
									  <c:otherwise>
									    <img class="profile-image" src="<c:url value='/resources/icon/basic_profile.jpg'/>" alt="기본 프로필">
									  </c:otherwise>
									</c:choose>
				            	</a>
				            	<div id="userMenuLayer"><jsp:include page="../member/profileWindow.jsp" /></div>
		            		</div>
			            	<a href="#"><img src="${contextPath}/resources/icon/chat_icon.svg" class="on-icons"></a>
			            	<a href="#"><img src="${contextPath}/resources/icon/bell_icon.svg" class="on-icons"></a>
	            		</div>
	            	</c:if>
	            	<c:if test="${empty sessionScope.id}">
                        <a href="${contextPath}/member/loginpage.do">
                            <span>로그인</span>
                        </a>
                    </c:if>
	            </li>
	            <li><a href="#"><img src="${contextPath}/resources/icon/grid_icon.svg" class="on-icons"></a></li>
	        </ul>
	    </nav>
    </div>
    
</section>