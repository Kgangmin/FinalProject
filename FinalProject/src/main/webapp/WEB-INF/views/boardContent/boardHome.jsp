<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String ctxPath = request.getContextPath();
%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- jQuery만 사용 (Bootstrap JS 불필요) -->
<script type="text/javascript" src="<%=ctxPath%>/js/jquery-3.7.1.min.js"></script>
<!-- 선택: Bootstrap CSS는 모양만 위해 로드 -->
<link rel="stylesheet" href="<%=ctxPath%>/bootstrap-4.6.2-dist/css/bootstrap.min.css" type="text/css" />

<!-- 공통 헤더 -->
<jsp:include page="/WEB-INF/views/header/header.jsp" />

<jsp:include page="/WEB-INF/views/boardContent/boardSideBar.jsp" />

<style>
/* 옅은 파랑 헤더 */
.thead-soft-primary th{
  background-color: rgba(13,110,253,.08); /* 부트스트랩 primary(#0d6efd) 8% */
  color: #0d6efd;                         /* 글자 파랑 */
  border-color: rgba(13,110,253,.15);     /* 경계선도 은은하게 파랑 */
  font-weight: 600;
}
/* 행 호버도 아주 살짝 파랑 */
.table-hover tbody tr:hover{
  background-color: rgba(13,110,253,.03);
}
</style>


<!-- ===== 본문 ===== -->
<div class="board-content">
  <h2 class="mb-3">글목록</h2>

<!-- 게시판추가 했을때 flash 메시지 -->
<c:if test="${not empty msg}">
  <div class="alert alert-success alert-dismissible fade show" role="alert">
    ${msg}
    <button type="button" class="close" data-dismiss="alert" aria-label="Close"
            onclick="this.parentElement.style.display='none'">
      <span aria-hidden="true">&times;</span>
    </button>
  </div>
</c:if>

<c:if test="${not empty error}">
  <div class="alert alert-danger alert-dismissible fade show" role="alert">
    ${error}
    <button type="button" class="close" data-dismiss="alert" aria-label="Close"
            onclick="this.parentElement.style.display='none'">
      <span aria-hidden="true">&times;</span>
    </button>
  </div>
</c:if>


  <div class="table-responsive">
    <table class="table table-bordered table-hover">
      <thead class="thead-soft-primary">
        <tr class="text-center">
          <th style="width: 80px;">순번</th>
          <th style="width: 90px;">글번호</th>
          <th class="text-left">제목</th>
          <th style="width: 120px;">성명</th>
          <th style="width: 160px;">날짜</th>
          <th style="width: 100px;">조회수</th>
        </tr>
      </thead>
      <tbody>
        <c:if test="${not empty requestScope.boardList}">
          <c:forEach var="boardDto" items="${requestScope.boardList}" varStatus="status">
            <tr>
              <td class="text-center">
                ${ (requestScope.totalCount) - (requestScope.currentShowPageNo - 1) * (requestScope.sizePerPage) - (status.index) }
              </td>
              <td class="text-center"><c:out value="${boardDto.seq}"/></td>

              <td class="text-left">
                <c:set var="title"><c:out value="${boardDto.subject}"/></c:set>

                <!-- 답글 들여쓰기 + 아이콘 -->
                <c:if test="${boardDto.fk_seq > 0}">
                  <span style="padding-left:${boardDto.depthno*20}px;">↪️</span>
                </c:if>

                <span class="subject" onclick="goView('${boardDto.seq}')" style="cursor:pointer;">
                  ${title}
                  <c:if test="${not empty boardDto.fileName}"> 💾</c:if>
                  <c:if test="${boardDto.commentCount > 0}">
                    <sup>[<span style="color:#d9534f;font-weight:bold;">
                      <c:out value="${boardDto.commentCount}"/>
                    </span>]</sup>
                  </c:if>
                </span>
              </td>

              <td class="text-center"><c:out value="${boardDto.name}"/></td>
              <td class="text-center"><c:out value="${boardDto.regDate}"/></td>
              <td class="text-center"><c:out value="${boardDto.readCount}"/></td>
            </tr>
          </c:forEach>
        </c:if>

        <c:if test="${empty requestScope.boardList}">
          <tr>
            <td class="text-center text-muted" colspan="6">데이터가 없습니다</td>
          </tr>
        </c:if>
      </tbody>
    </table>
  </div>

  <!-- 페이지바 -->
  <div class="d-flex justify-content-center my-3">
    ${requestScope.pageBar}
  </div>

  <!-- 검색 폼 -->
  <form name="searchFrm" class="form-inline mt-3">
    <select name="searchType" class="form-control mr-2">
      <option value="subject" <c:if test="${param.searchType=='subject'}">selected</c:if>>글제목</option>
      <option value="content" <c:if test="${param.searchType=='content'}">selected</c:if>>글내용</option>
      <option value="subject_content" <c:if test="${param.searchType=='subject_content'}">selected</c:if>>글제목+글내용</option>
      <option value="name" <c:if test="${param.searchType=='name'}">selected</c:if>>글쓴이</option>
    </select>
    <input type="text" name="searchWord" class="form-control mr-2" size="40"
           value="<c:out value='${param.searchWord}'/>" autocomplete="off">
    <input type="text" style="display:none;">
    <button type="button" class="btn btn-secondary btn-sm" onclick="goSearch()">검색</button>
  </form>
</div>
