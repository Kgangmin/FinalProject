<%@ page contentType="text/html; charset=UTF-8" %>
<% String ctx = request.getContextPath(); %>

<style>
/* === Draft Type Modal === */

.dtm.show{display:flex;}

.dtm__panel{position:relative;background:#fff;border-radius:12px;box-shadow:0 10px 30px rgba(0,0,0,.2);
            width:560px;max-width:calc(100% - 32px);outline:0;}
.dtm__head{display:flex;justify-content:space-between;align-items:center;padding:14px 16px;border-bottom:1px solid #e5e7eb;}
.dtm__close{border:0;background:transparent;font-size:20px;line-height:1;cursor:pointer;}
.dtm__body{padding:16px;}
.dtm__grid{display:grid;grid-template-columns:1fr 1fr 1fr;gap:12px;}
.dtm__card{padding:16px;border:1px solid #e5e7eb;border-radius:10px;background:#fff;cursor:pointer;text-align:left;}
.dtm__card:hover{box-shadow:0 6px 16px rgba(0,0,0,.08);transform:translateY(-1px)}
.dtm__title{font-weight:700;margin-bottom:6px;}
.dtm__desc{color:#6b7280;font-size:.9rem;}
@media (max-width:640px){ .dtm__grid{grid-template-columns:1fr;}}

.dtm{
  position: fixed;
  inset: 0;              /* top/left/right/bottom 모두 0 → 전체 덮기 */
  display: none;
  align-items: center;
  justify-content: center;
  z-index: 9999;         /* 헤더보다 확실히 높게 */
}
.dtm__backdrop{
  position: absolute;
  inset: 0;
  background: rgba(0,0,0,.45);
}
</style>

<!-- 신청타입 선택 모달 -->
<div id="draftTypeModal" class="dtm" aria-hidden="true" role="dialog">
  <div class="dtm__backdrop" data-close></div>
  <div class="dtm__panel" role="document" tabindex="-1">
    <div class="dtm__head">
      <strong>어떤 유형으로 신청할까요?</strong>
      <button type="button" class="dtm__close" data-close aria-label="닫기">×</button>
    </div>
    <div class="dtm__body">
      <div class="dtm__grid">
        <button type="button" class="dtm__card" data-type="PROPOSAL">
          <div class="dtm__title">업무기안서</div>
          <div class="dtm__desc">보고/요청/승인</div>
        </button>
        <button type="button" class="dtm__card" data-type="EXPENSE">
          <div class="dtm__title">지출결의서</div>
          <div class="dtm__desc">경비/영수증 첨부</div>
        </button>
        <button type="button" class="dtm__card" data-type="LEAVE">
          <div class="dtm__title">휴가신청서</div>
          <div class="dtm__desc">연차/반차 등</div>
        </button>
      </div>
    </div>
  </div>
</div>

<script>
$(function(){
	  var ctx = '<%=ctx%>';
	  var $modal = $('#draftTypeModal');

	  function openModal(){
	    $modal.addClass('show');
	    $modal.find('.dtm__panel').attr('tabindex', -1).focus();
	    $('body').css('overflow', 'hidden');
	  }
	  function closeModal(){
	    $modal.removeClass('show');
	    $('body').css('overflow', '');
	  }

	  // ① "신청하기" 링크 클릭 가로채서 모달 열기
	  //    href가 '/draft/write'로 끝나는 모든 <a>
	  $(document).on('click', 'a[href$="/draft/write"]', function(e){
	    e.preventDefault();
	    openModal();
	  });

	  // ② 모달 내 타입 버튼 → 등록 페이지로 이동(리로드)
	  $(document).on('click', '#draftTypeModal [data-type]', function(){
	    var t = $(this).data('type'); // PROPOSAL | EXPENSE | LEAVE
	    location.href = ctx + '/draft/register?type=' + t;
	  });

	  // ③ 닫기: X 버튼/배경 클릭/ESC
	  $(document).on('click', '#draftTypeModal [data-close], #draftTypeModal .dtm__backdrop', function(){
	    closeModal();
	  });
	  $(document).on('keydown', '#draftTypeModal', function(e){
	    if (e.key === 'Escape' || e.keyCode === 27) closeModal();
	  });
	});
</script>
	