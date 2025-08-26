<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String ctxPath = request.getContextPath();
%>
<link rel="stylesheet" href="<%= ctxPath %>/css/email.css">

<jsp:include page="/WEB-INF/views/header/header.jsp" />

<style>

.recipient-field{
  min-height:42px; gap:6px; position:relative; padding:6px 8px;
}
.recipient-input-inline{
  border:0; outline:0; flex:1 0 180px; min-width:120px;
}
.recipient-suggest{
  position:absolute; left:0; right:0; top:100%; z-index:30; display:none;
  max-height:260px; overflow:auto;
}
.recipient-suggest .list-group-item{ cursor:pointer; padding:6px 10px; }
.recipient-suggest .highlight{ background:#f1f3f5; }

.recipient-chip{
  display:inline-flex; align-items:center; gap:6px;
  padding:3px 8px; border-radius:999px; margin:2px 0;
  border-width:1px; border-style:solid; font-size:0.875rem; line-height:1.2;
}
.recipient-chip.valid{
  background:#e7f1ff; border-color:#9ec5fe; color:#0d6efd; /* 파랑 */
}
.recipient-chip.invalid{
  background:#fde2e1; border-color:#f1aeb5; color:#dc3545; /* 빨강 */
}
.recipient-chip .chip-x{ cursor:pointer; font-weight:bold; opacity:.7; }
.recipient-chip .chip-x:hover{ opacity:1; }
.recipient-field:focus-within{ box-shadow:0 0 0 .2rem rgba(13,110,253,.15); }
</style>

<div class="mail-wrap">
  <!-- 좌측: 메일 전용 사이드바 재사용 -->
  <jsp:include page="/WEB-INF/views/mail/mail_sidebar.jsp" />

  <!-- 우측: 메일 작성 폼 -->
  <section class="flex-grow-1">
    <div class="mail-card card" style="border:1px solid #e9ecef;">
      <div class="card-header">
        <div class="h6 mb-0">메일 쓰기</div>
      </div>
      <div class="card-body">
        <form id="composeForm" action="<%=ctxPath%>/mail/send" method="post" enctype="multipart/form-data" autocomplete="off">

          <!-- 받는사람: 자동완성 + 칩 -->
          <div class="form-group">
            <label class="font-weight-bold">받는사람(사내이메일)</label>

            <div id="toField" class="recipient-field form-control d-flex flex-wrap align-items-center">
              <!-- chips 가 들어가는 영역 -->
              <input id="toInput" type="text" class="recipient-input-inline" placeholder="이름/팀/이메일 입력 후 Enter">
              <!-- 자동완성 드롭다운 -->
              <div id="toSuggest" class="recipient-suggest list-group shadow-sm"></div>
            </div>

            <!-- 서버 제출 값: 콤마로 조인 -->
            <input type="hidden" name="to_emp_email_csv" id="toHidden"
                   value="<c:out value='${param.to_emp_email_csv != null ? param.to_emp_email_csv : param.to}'/>" required>
            <small class="text-muted">여러 명이면 쉼표(,)로 구분</small>
          </div>

          <!-- 보낸사람(사내이메일) - readonly -->
          <div class="form-group">
            <label class="font-weight-bold">보낸사람</label>
            <input type="text" class="form-control" value="${sessionScope.loginuser.emp_email}(${sessionScope.loginuser.emp_name})" readonly>
          </div>

          <!-- 제목 -->
          <div class="form-group">
            <label for="email_title" class="font-weight-bold">제목</label>
            <input type="text" class="form-control" id="email_title" name="email_title" value="${param.subject}" required>
          </div>

          <!-- 내용 -->
          <div class="form-group">
            <label for="email_content" class="font-weight-bold">내용</label>
            <textarea class="form-control" id="email_content" name="email_content" rows="12" required><c:out value="${param.content}"/></textarea>
          </div>

          <!-- 첨부 -->
          <div class="form-group">
            <label for="attachments" class="font-weight-bold">첨부파일</label>
            <input type="file" id="attachments" name="attachments" multiple class="form-control-file">
          </div>

          <div class="d-flex justify-content-end">
            <a href="<%=ctxPath%>/mail/email" class="btn btn-outline-secondary mr-2">취소</a>
            <button type="submit" class="btn btn-primary">보내기</button>
          </div>
        </form>
      </div>
    </div>
  </section>
</div>

<jsp:include page="/WEB-INF/views/footer/footer.jsp" />

<script>
  // 메일 페이지 레이아웃 활성화
  document.addEventListener('DOMContentLoaded', function(){
    document.body.classList.add('mail-page');
  });

  (function(){
    var CTX = '<%=ctxPath%>';
    var SEARCH_URL = CTX + '/mail/api/contacts/search'; // GET ?q=...

    var EMAIL_RE = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;
    function isEmail(s){ return EMAIL_RE.test(String(s||'').trim()); }
    function esc(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;'); }

    function dedupe(arr){
      var m={}, out=[]; for(var i=0;i<arr.length;i++){
        var k=String(arr[i]).trim().toLowerCase(); if(!k) continue;
        if(!m[k]){ m[k]=1; out.push(arr[i]); }
      } return out;
    }

    function splitCandidates(text){
      var t = String(text||'');
      var res = [];
      var m = t.match(/<\s*([^>]+)\s*>/);
      if(m && m[1]){ res.push(m[1]); t = t.replace(/<[^>]+>/g,' '); }
      t.split(/[\s,;]+/).forEach(function(p){ if(p){ res.push(p); }});
      res = res.filter(function(x){ return x && x.indexOf('@')>-1; });
      return res;
    }

    function debounce(fn,wait){
      var t=null; return function(){ var ctx=this, args=arguments;
        clearTimeout(t); t=setTimeout(function(){ fn.apply(ctx,args); }, wait||300);
      };
    }

    function initRecipientField(wrapId, inputId, suggestId, hiddenId){
      var wrap   = document.getElementById(wrapId);
      var input  = document.getElementById(inputId);
      var listEl = document.getElementById(suggestId);
      var hidden = document.getElementById(hiddenId);

      var emails = [];
      var meta   = {}; // email -> {name, team, verified:boolean}

      function renderHidden(){ hidden.value = emails.join(','); }
      function hasEmail(email){
        var e = String(email||'').trim().toLowerCase();
        for(var i=0;i<emails.length;i++){ if(emails[i].toLowerCase()===e) return true; }
        return false;
      }

      function removeChip(email, chipEl){
        var e = String(email||'').trim();
        emails = emails.filter(function(x){ return x !== e; });
        delete meta[e];
        if(chipEl && chipEl.parentNode) chipEl.parentNode.removeChild(chipEl);
        renderHidden();
      }

      function addChip(email, info){
        var clean = String(email||'').trim();
        if(!clean) return;
        if(hasEmail(clean)) return;

        var ok = isEmail(clean);
        emails.push(clean);
        if(info && typeof info==='object'){ meta[clean] = { name:info.name||'', team:info.teamName||'', verified:true }; }
        else { meta[clean] = { name:'', team:'', verified:false }; }

        var chip = document.createElement('span');
        chip.className = 'recipient-chip ' + (ok ? 'valid' : 'invalid');
        chip.setAttribute('data-email', clean);

        var label = clean;
        if(info && info.name){ label = info.name + ' <' + clean + '>'; }

        chip.innerHTML =
          '<span class="chip-label">' + esc(label) + '</span>' +
          '<span class="chip-x" aria-label="remove" title="삭제">&times;</span>';

        chip.querySelector('.chip-x').addEventListener('click', function(){
          removeChip(clean, chip);
        });

        wrap.insertBefore(chip, input);
        input.value=''; hideSuggest();
        renderHidden();
      }

      function commitInput(){
        var raw = input.value;
        if(!raw) return false;
        var cands = splitCandidates(raw);
        if(cands.length===0){
          if(isEmail(raw)) cands=[raw];
        }
        cands = dedupe(cands);
        for(var i=0;i<cands.length;i++){ addChip(cands[i]); }
        input.value=''; hideSuggest();
        return cands.length>0;
      }

      function hideSuggest(){ listEl.style.display='none'; listEl.innerHTML=''; activeIndex=-1; }
      function showSuggest(items){
        if(!items || items.length===0){ hideSuggest(); return; }
        var html = '';
        for(var i=0;i<items.length;i++){
          var it = items[i];
          var right = it.email;
          if(it.teamName){ right += ' · ' + it.teamName; }
          html += '<button type="button" class="list-group-item list-group-item-action" data-idx="' + i + '">'
                +   '<div class="d-flex justify-content-between align-items-center">'
                +     '<div><strong>' + esc(it.name) + '</strong></div>'
                +     '<div class="small text-muted">' + esc(right) + '</div>'
                +   '</div>'
                + '</button>';
        }
        listEl.innerHTML = html;
        listEl.style.display='block';
        Array.prototype.forEach.call(listEl.querySelectorAll('.list-group-item'), function(btn){
          btn.addEventListener('click', function(){
            var i = parseInt(btn.getAttribute('data-idx'),10);
            var it = items[i];
            addChip(it.email, it);
          });
        });
        activeIndex = -1;
      }

      var doSearch = debounce(function(q){
        q = String(q||'').trim();
        if(q.length < 2){ hideSuggest(); return; }
        fetch(SEARCH_URL + '?q=' + encodeURIComponent(q), { headers:{'Accept':'application/json'} })
          .then(function(r){ if(!r.ok) throw new Error('HTTP '+r.status); return r.json(); })
          .then(function(res){
            var list = (res && res.list) ? res.list : [];
            list = list.filter(function(it){ return it && it.email && !hasEmail(it.email); });
            showSuggest(list);
          })
          .catch(function(){ hideSuggest(); });
      }, 250);

      // 이벤트
      input.addEventListener('input', function(){ doSearch(input.value); });

      input.addEventListener('blur', function(){
        setTimeout(function(){ if(listEl.style.display==='none'){ commitInput(); } }, 120);
      });

      var activeIndex=-1;
      input.addEventListener('keydown', function(e){
        var key = e.key;

        if(key === 'Enter' || key === 'Tab' || key === ',' || key === ';'){
          if(input.value.trim()!==''){
            e.preventDefault(); commitInput();
          }
          return;
        }

        if(key === 'Backspace' && input.value.trim()===''){
          var chips = wrap.querySelectorAll('.recipient-chip');
          if(chips.length>0){
            var last = chips[chips.length-1];
            removeChip(last.getAttribute('data-email'), last);
          }
          return;
        }

        if(listEl.style.display!=='none' && (key==='ArrowDown' || key==='ArrowUp' || key==='Enter')){
          var items = listEl.querySelectorAll('.list-group-item');
          if(items.length===0) return;
          e.preventDefault();
          if(key==='ArrowDown'){ activeIndex = (activeIndex+1) % items.length; }
          else if(key==='ArrowUp'){ activeIndex = (activeIndex-1+items.length) % items.length; }
          Array.prototype.forEach.call(items, function(el,i){
            if(i===activeIndex) el.classList.add('highlight'); else el.classList.remove('highlight');
          });
          if(key==='Enter' && activeIndex>-1){
            items[activeIndex].click(); activeIndex=-1; hideSuggest();
          }
        }
      });

      wrap.addEventListener('click', function(e){ if(e.target===wrap){ input.focus(); } });

      var form = wrap.closest('form');
      if(form){
        form.addEventListener('submit', function(){
          commitInput(); renderHidden();
          // 필요 시: 무효 이메일 존재하면 전송 막기
          // var anyInvalid = (emails.filter(function(x){ return !isEmail(x); }).length>0);
          // if(anyInvalid){ alert('잘못된 이메일이 포함되어 있습니다.'); event.preventDefault(); }
        });
      }

      // 초기값 칩으로 반영
      (function initFromHidden(){
        var seed = String(hidden.value||'').trim();
        if(!seed) return;
        var parts = seed.split(',').map(function(s){ return s.trim(); }).filter(function(s){ return !!s; });
        parts = dedupe(parts);
        for(var i=0;i<parts.length;i++){ addChip(parts[i]); }
      })();

      return { add:function(email, info){ addChip(email, info); }, getAll:function(){ return emails.slice(); } };
    }

    // 초기화
    initRecipientField('toField','toInput','toSuggest','toHidden');
  })();
</script>
