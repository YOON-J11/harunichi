<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<link rel="stylesheet" href="${ctx}/resources/css/product.css">
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<div class="product-detail-container">
	<h2 class="product-title">${product.productTitle}</h2>

	<div class="writer-info">
		  <c:choose>
		    <c:when test="${not empty product.writerProfileImg 
		                   and fn:startsWith(product.writerProfileImg, 'http')}">
		      <img src="${product.writerProfileImg}" 
		           class="writer-img" alt="프로필" loading="lazy"
		           onerror="this.src='${ctx}/resources/icon/basic_profile.jpg'"/>
		    </c:when>
		
		    <c:when test="${not empty product.writerProfileImg}">
		      <img src="${ctx}/resources/profile/${product.writerProfileImg}" 
		           class="writer-img" alt="프로필" loading="lazy"
		           onerror="this.src='${ctx}/resources/icon/basic_profile.jpg'"/>
		    </c:when>
		
		    <c:otherwise>
		      <img src="${ctx}/resources/icon/basic_profile.jpg" 
		           class="writer-img" alt="기본 프로필" loading="lazy"/>
		    </c:otherwise>
		  </c:choose>
		
		  <span class="writer-nick">${product.writerNick}</span>
		</div>


	<div class="product-detail">
		<c:choose>
			<c:when test="${not empty product.productImg}">
				<img src="${ctx}/images/product/${product.productImg}" class="product-image" alt="상품 이미지" />
			</c:when>
			<c:otherwise>
				<img src="${ctx}/images/product/no-image.png" class="product-image" alt="기본 이미지" />
			</c:otherwise>
		</c:choose>

		<div class="product-info-box">
			<ul class="product-meta">
				<li><strong>가격:</strong> <span><fmt:formatNumber
							value="${product.productPrice}" type="number" groupingUsed="true" />원</span>
				</li>
				<li><strong>거래방식:</strong> <span> <c:choose>
							<c:when test="${product.productStatus == -1}">
								<span style="color: red;">판매완료</span>
							</c:when>
							<c:when test="${product.productStatus == 1}">
								<span style="color: green;">나눔</span>
							</c:when>
							<c:otherwise>
								<span style="color: blue;">판매</span>
							</c:otherwise>
						</c:choose>
				</span></li>
				<li><strong>카테고리:</strong> <span> <c:choose>
							<c:when test="${product.productCategory == 'book'}">📚도서</c:when>
							<c:when test="${product.productCategory == 'electronics'}">💻전자제품</c:when>
							<c:when test="${product.productCategory == 'toy'}">🧸장난감</c:when>
							<c:when test="${product.productCategory == 'fashion'}">👕패션</c:when>
							<c:when test="${product.productCategory == 'music'}">💿음반</c:when>
							<c:when test="${product.productCategory == 'etc'}">🎁기타</c:when>
							<c:otherwise>${product.productCategory}</c:otherwise>
						</c:choose>
				</span></li>
				<li><strong>설명:</strong> <pre style="white-space: pre-wrap;">${product.productContent}</pre></li>
				<li><strong>조회수:</strong> <span>${product.productCount}</span></li>
				<li><strong>등록일:</strong> <span><fmt:formatDate
							value="${product.productDate}" pattern="yyyy-MM-dd HH:mm:ss" /></span>
				</li>
			</ul>

			<div class="action-buttons">
				<c:choose>
					<c:when test="${product.productStatus == -1}">
						<div class="soldout-message">⚠️ 판매가 완료된 상품입니다.</div>
					</c:when>
					<c:otherwise>
						<button onclick="startChat('${product.productWriterId}')"
							class="btn btn-chat">채팅하기</button>
						<button onclick="payment('${product.productId}')"
							class="btn btn-pay">결제하기</button>
					</c:otherwise>
				</c:choose>

				<button id="likeButton" class="btn-like">
					<i id="likeIcon" class="fa-regular fa-heart">❤️</i> <span
						id="likeCount">0</span>
				</button>
			</div>
		</div>
	</div>

	<!-- 로그인 사용자 (작성자 or 관리자)인 경우: 수정, 삭제, 목록 모두 나란히 표시 -->
	<c:if
		test="${sessionScope.id eq product.productWriterId or sessionScope.id eq 'admin'}">
		<div class="detail-buttons" style="text-align: left;">
			<form id="editForm" action="${ctx}/product/edit" method="get"
				style="display: inline;">
				<input type="hidden" name="productId" value="${product.productId}">
				<button type="submit" class="btn btn-edit"
					onclick="return checkLogin()">수정</button>
			</form>
			<form id="deleteForm" action="${ctx}/product/delete" method="post"
				style="display: inline;">
				<input type="hidden" name="productId" value="${product.productId}">
				<button type="submit" class="btn btn-delete"
					onclick="return checkLogin()">삭제</button>
			</form>
			<a href="${ctx}/product/list" class="btn btn-list"
				style="display: inline-block;">목록</a>
		</div>
	</c:if>

	<!-- 로그인은 했지만 작성자가 아닌 사용자 OR 로그인하지 않은 사용자 -->
	<c:if
		test="${sessionScope.id ne product.productWriterId and sessionScope.id ne 'admin'}">
		<div class="detail-buttons" style="text-align: left;">
			<a href="${ctx}/product/list" class="btn btn-list">목록</a>
		</div>
	</c:if>
</div>

	<div class="other-products">
		<h3>👍 ${product.writerNick}님의 다른 상품</h3>
		<div class="other-products-row">
			<button id="prevBtn" class="btn-nav">◀️ 이전</button>
			<div id="other-product-list" class="other-product-list"></div>
			<button id="nextBtn" class="btn-nav">다음 ▶️</button>
		</div>
	</div>

<script>
  const ctx = '${ctx}';
  const writerId = '${product.productWriterId}';
  const currentProductId = '${product.productId}';
  const currentUserId = '${sessionScope.id}';
  let page = 1;
  const size = 4;

  function loadOtherProducts() {
    $.ajax({
      url: ctx + '/product/other',
      method: 'GET',
      data: {
        writerId: writerId,
        productId: currentProductId,
        page: page,
        size: size
      },
      success: function (data) {
        const listEl = $('#other-product-list');
        listEl.empty();

        if (!data || data.length === 0) {
        	  $('#other-product-list').html('<p style="margin: 20px auto;">작성자의 다른 상품이 없습니다.</p>');
        	  return;
        }

        data.forEach(p => {
          const title = p.productTitle || '제목 없음';
          const price = p.productPrice != null ? Number(p.productPrice).toLocaleString() + '원' : '가격 미정';
          const imgSrc = p.productImg
	          ? ctx + '/images/product/' + p.productImg
	          : ctx + '/images/product/no_image.png';

          const html =
            '<div class="other-product-card" onclick="location.href=\'' + ctx + '/product/view?productId=' + p.productId + '\'">' +
              '<img src="' + imgSrc + '" alt="상품 이미지">' +
              '<p class="other-product-title">' + title + '</p>' +
              '<p class="other-product-price">' + price + '</p>' +
            '</div>';

          listEl.append(html);
        });
      },
      error: function () {
        $('#other-product-list').html("<p>작성자의 다른 상품을 불러오지 못했습니다.</p>");
      }
    });
  }

  // 이전/다음 버튼
  $('#prevBtn').on('click', function () {
    if (page > 1) {
      page--;
      loadOtherProducts();
    }
  });

  $('#nextBtn').on('click', function () {
    page++;
    loadOtherProducts();
  });

  
  function startChat(writerId) {
	  if (!currentUserId || currentUserId === 'null') {
	    alert('채팅 기능은 로그인 후 이용 가능합니다.');
	    location.href = ctx + '/member/loginpage.do';
	    return;
	  }
	  if (writerId === currentUserId) {
	    alert('자신과는 채팅할 수 없습니다.');
	    return;
	  }
	  location.href = ctx + '/chat/productChat?productId=' + currentProductId;
	}

	function payment(productId) {
	  if (!currentUserId || currentUserId === 'null') {
	    alert('결제는 로그인 후 이용 가능합니다.');
	    location.href = ctx + '/member/loginpage.do';
	    return;
	  }
	  if (writerId === currentUserId) {
		    alert('내 상품에 거래할 수 없습니다.');
		    return;
	  }
	  location.href = ctx + '/payment/form?productId=' + productId;
	}

  $(document).ready(function () {
    // 좋아요 개수는 로그인과 무관하게 항상 표시
    $.get(ctx + '/like/count', { productId: currentProductId }, function (res) {
      $('#likeCount').text(res.likeCount);
    });
  
    // 로그인한 경우에만 좋아요 상태 조회 및 토글 가능
    if (currentUserId && currentUserId !== 'null') {
      $.get(ctx + '/like/status', { productId: currentProductId }, function (res) {
        if (res.success && res.liked) {
          $('#likeButton').addClass('liked');
          $('#likeIcon').removeClass('fa-regular').addClass('fa-solid');
        }
      });

      $('#likeButton').on('click', function () {
        $.ajax({
          url: ctx + '/like/toggle',
          type: 'POST',
          contentType: 'application/json',
          data: JSON.stringify({ productId: currentProductId }),
          success: function (res) {
            if (!res.success) {
              alert(res.message);
              return;
            }
            $('#likeCount').text(res.likeCount);
            $('#likeButton').toggleClass('liked');
            $('#likeIcon').toggleClass('fa-regular fa-solid');
          }
        });
      });
    } else {
      $('#likeButton').on('click', function () {
        alert('로그인이 필요합니다.');
        location.href = ctx + '/member/loginpage.do';
      });
    }
    loadOtherProducts();
  });
</script>
