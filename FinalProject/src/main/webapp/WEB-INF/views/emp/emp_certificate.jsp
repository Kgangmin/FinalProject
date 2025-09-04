<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  String ctxPath = request.getContextPath();
%>
<style>
/* 최소 모달 스타일 */
.dtm{ position:fixed; inset:0; display:none; z-index:1050; }
.dtm.is-open{ display:block; }
.dtm__backdrop{ position:absolute; inset:0; background:rgba(0,0,0,.35); }
.dtm__panel{ position:relative; z-index:1; width:560px; max-width:90vw; margin:10vh auto 0;
  background:#fff; border-radius:12px; box-shadow:0 10px 30px rgba(0,0,0,.2); }
.dtm__head{ display:flex; justify-content:space-between; align-items:center; padding:16px 20px; border-bottom:1px solid #eee; }
.dtm__body{ padding:18px 20px 22px 20px; }
.dtm__close{ border:0; background:transparent; font-size:22px; line-height:1; cursor:pointer; }
.dtm__grid{ display:grid; grid-template-columns:1fr 1fr; gap:14px; }
.dtm__card{ display:flex; align-items:center; justify-content:center; min-height:120px;
  border:1px solid #e6e6e6; border-radius:12px; background:#fafafa; cursor:pointer; transition:.15s; }
.dtm__card:hover{ transform:translateY(-2px); box-shadow:0 8px 18px rgba(0,0,0,.08); background:#fff; }
.dtm__title{ font-weight:600; }
</style>

<div class="mb-3">
  <h5 class="mb-2">서류 발급</h5>
  <p class="text-muted mb-0">원하는 서류를 선택하세요.</p>
</div>

<div id="paperworkTypeModal" class="dtm" aria-hidden="true" role="dialog">
  <div class="dtm__backdrop" data-close></div>
  <div class="dtm__panel" role="document" tabindex="-1" aria-modal="true">
    <div class="dtm__head">
      <strong>발급할 서류를 선택하세요</strong>
      <button type="button" class="dtm__close" data-close aria-label="닫기">×</button>
    </div>
    <div class="dtm__body">
      <div class="dtm__grid">
        <button type="button" class="dtm__card" data-type="payslip">
          <div class="dtm__title">급여명세서</div>
        </button>
        <button type="button" class="dtm__card" data-type="COE">
          <div class="dtm__title">재직증명서</div>
        </button>
      </div>
    </div>
  </div>
</div>

<script>
(function(){
  const modal = document.getElementById('paperworkTypeModal');
  const panel = modal.querySelector('.dtm__panel');

  function openModal(){
    modal.classList.add('is-open');
    modal.setAttribute('aria-hidden','false');
    setTimeout(()=> panel.focus(), 0);
  }
  function closeModal(){
    modal.classList.remove('is-open');
    modal.setAttribute('aria-hidden','true');
  }

  document.addEventListener('DOMContentLoaded', openModal);

  modal.addEventListener('click', (e)=>{
    if (e.target.matches('[data-close], .dtm__backdrop')) closeModal();
  });
  document.addEventListener('keydown', (e)=>{
    if (e.key === 'Escape' && modal.classList.contains('is-open')) closeModal();
  });

  modal.addEventListener('click', (e)=>{
    const btn = e.target.closest('.dtm__card');
    if (!btn) return;
    const type = btn.getAttribute('data-type');
    if (type === 'payslip') {
      location.href = '<%=ctxPath%>/emp/certificate/payslip';
    } else if (type === 'COE') {
      location.href = '<%=ctxPath%>/emp/certificate/coe';
    }
  });
})();
</script>
