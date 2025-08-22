<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true"%>
<%
  String ctxPath = request.getContextPath();
%>
<jsp:include page="/WEB-INF/views/header/header.jsp" />

<div class="content-wrapper">
  <div class="dashboard-toolbar">
    <div class="h5 mb-0">날씨</div>
    <div class="d-flex" style="gap:8px;">
      <input id="latInput" class="form-control form-control-sm" style="width:130px" placeholder="위도(lat)">
      <input id="lonInput" class="form-control form-control-sm" style="width:130px" placeholder="경도(lon)">
      <button id="btnLoadLatLon" class="btn btn-outline-secondary btn-sm">좌표로 불러오기</button>
      <button id="btnUseMyLocation" class="btn btn-outline-primary btn-sm">내 위치로</button>
    </div>
  </div>

  <div class="container-fluid py-3">
    <div id="wxPageMsg" class="alert d-none" role="alert" style="margin:12px 0;"></div>

    <!-- 현재 -->
    <div class="card mb-3">
      <div class="card-body d-flex align-items-center">
        <div id="curIcon" style="font-size:48px; line-height:1; margin-right:12px;">⛅</div>
        <div>
          <div class="h2 mb-1"><span id="curTemp">--</span>°</div>
          <div class="text-muted">
            <span id="curSummary">-</span>
            · 체감 <span id="curFeels">-</span>°
            · 습도 <span id="curReh">-</span>%
            · 풍속 <span id="curWsd">-</span> m/s
            · 강수량 <span id="curRn1">-</span> mm
          </div>
          <div class="small text-secondary mt-1">
            기준 nx=<span id="curNx">-</span>, ny=<span id="curNy">-</span>
          </div>
        </div>
      </div>
    </div>

    <!-- 시간별 -->
    <div class="card mb-3">
      <div class="card-header font-weight-bold">시간별 예보</div>
      <div class="card-body">
        <div id="hourlyWrap" class="d-flex overflow-auto" style="gap:12px;"></div>
      </div>
    </div>

    <!-- 일별 -->
    <div class="card mb-5">
      <div class="card-header font-weight-bold">일별 예보</div>
      <div class="card-body">
        <div id="dailyWrap" class="row"></div>
      </div>
    </div>
  </div>
</div>

<script>
(function(){
  var CTX = '<%=ctxPath%>';

  function $(id){ return document.getElementById(id); }
  function z(n){ return String(n).padStart(2,'0'); }
  function fmtHM(dt){ var d = new Date(dt); return z(d.getHours())+'시'; }
  function fmtMD(dt){ var d = new Date(dt); return (d.getMonth()+1)+'/'+d.getDate(); }
  function text(el, v){ el.textContent = (v == null ? '-' : v); }
  function isFiniteNum(v){ return typeof v === 'number' && isFinite(v); }

  function icon(sky, pty){
    if (pty && pty !== 0){
      if (pty===1 || pty===5) return '🌧️';
      if (pty===2 || pty===6) return '🌨️';
      if (pty===3 || pty===7) return '❄️';
      return '🌦️';
    }
    if (sky===1) return '☀️';
    if (sky===3) return '⛅';
    if (sky===4) return '☁️';
    return '☀️';
  }

  function showMsg(kind, msg){
    var box = $('wxPageMsg');
    box.className = 'alert alert-' + (kind || 'info');
    box.textContent = msg || '';
  }
  function hideMsg(){ var b=$('wxPageMsg'); if(b){ b.classList.add('d-none'); } }

  function renderCurrent(s){
    var c = (s && s.current) || {};
    var loc = (s && s.location) || {};
    $('curIcon').textContent = icon(c.sky, c.pty);
    text($('curTemp'),  c.temperature);
    text($('curFeels'), c.feelsLike);
    text($('curReh'),   c.humidity);
    text($('curWsd'),   c.windSpeed);
    text($('curRn1'),   c.rain1h);
    text($('curSummary'), c.summary);
    text($('curNx'), loc.nx);
    text($('curNy'), loc.ny);
  }

  function renderHourly(s){
    var wrap = $('hourlyWrap');
    wrap.innerHTML = '';
    var arr = (s && s.hourly) || [];
    for (var i=0; i<arr.length; i++){
      var h = arr[i];
      var card = document.createElement('div');
      card.className = 'text-center border rounded p-2';
      card.style.minWidth = '72px';

      var t1 = document.createElement('div');
      t1.className = 'small text-muted mb-1';
      t1.textContent = fmtHM(h.time);

      var t2 = document.createElement('div');
      t2.style.fontSize = '28px';
      t2.style.lineHeight = '1';
      t2.textContent = icon(h.sky, h.pty);

      var t3 = document.createElement('div');
      t3.className = 'mt-1';
      t3.textContent = (h.temperature == null ? '-' : h.temperature) + '°';

      var t4 = document.createElement('div');
      t4.className = 'small text-secondary';
      t4.textContent = (h.rainProb != null ? (h.rainProb + '%') : ' ');

      card.appendChild(t1); card.appendChild(t2); card.appendChild(t3); card.appendChild(t4);
      wrap.appendChild(card);
    }
  }

  function renderDaily(s){
    var wrap = $('dailyWrap');
    wrap.innerHTML = '';
    var arr = (s && s.daily) || [];
    for (var i=0; i<arr.length; i++){
      var d = arr[i];
      var col = document.createElement('div');
      col.className = 'col-6 col-md-4 col-lg-3 mb-3';

      var box = document.createElement('div');
      box.className = 'border rounded p-2 h-100';

      var top = document.createElement('div');
      top.className = 'd-flex justify-content-between align-items-center';

      var day = document.createElement('div');
      day.className = 'font-weight-bold';
      day.textContent = fmtMD(d.date);

      var ic = document.createElement('div');
      ic.style.fontSize = '28px';
      ic.style.lineHeight = '1';
      ic.textContent = icon(d.skyNoon, d.ptyNoon);

      top.appendChild(day);
      top.appendChild(ic);

      var temp = document.createElement('div');
      temp.className = 'mt-2';
      temp.innerText = '최고 ' + (d.tmax == null ? '-' : d.tmax) + '° / 최저 ' + (d.tmin == null ? '-' : d.tmin) + '°';

      var pop = document.createElement('div');
      pop.className = 'text-secondary small';
      pop.innerText = '강수확률 ' + (d.popDay != null ? d.popDay : '-') + '%';

      box.appendChild(top); box.appendChild(temp); box.appendChild(pop);
      col.appendChild(box);
      wrap.appendChild(col);
    }
  }

  function renderAll(summary){
    if (!summary || !summary.current) throw new Error('Empty data');
    renderCurrent(summary);
    renderHourly(summary);
    renderDaily(summary);
  }

  // 좌표 결정
  function parseQS(){
    var p = new URLSearchParams(location.search);
    var lat = parseFloat(p.get('lat'));
    var lon = parseFloat(p.get('lon'));
    return { lat: (isFinite(lat)?lat:null), lon: (isFinite(lon)?lon:null) };
  }
  function getSaved(){
    var lat = parseFloat(localStorage.getItem('wx.lastLat'));
    var lon = parseFloat(localStorage.getItem('wx.lastLon'));
    return { lat: (isFinite(lat)?lat:null), lon: (isFinite(lon)?lon:null) };
  }
  function setSaved(lat, lon){
    if (isFiniteNum(lat)) localStorage.setItem('wx.lastLat', String(lat));
    if (isFiniteNum(lon)) localStorage.setItem('wx.lastLon', String(lon));
  }
  function getDefault(){ return { lat: 37.5665, lon: 126.9780 }; }
  function getGeoOrNull(timeoutMs){
    return new Promise(function(resolve){
      if(!navigator.geolocation) return resolve(null);
      var done = false;
      var timer = setTimeout(function(){ if(!done) resolve(null); }, timeoutMs || 3500);
      navigator.geolocation.getCurrentPosition(
        function(pos){ done=true; clearTimeout(timer); resolve({lat:pos.coords.latitude, lon:pos.coords.longitude}); },
        function(){ done=true; clearTimeout(timer); resolve(null); },
        { enableHighAccuracy:false, timeout:(timeoutMs||3500), maximumAge:600000 }
      );
    });
  }
  async function decideInitialCoords(){
    var qs = parseQS(); if (isFiniteNum(qs.lat) && isFiniteNum(qs.lon)) return qs;
    var geo = await getGeoOrNull(3500); if (geo && isFiniteNum(geo.lat) && isFiniteNum(geo.lon)) return geo;
    var saved = getSaved(); if (isFiniteNum(saved.lat) && isFiniteNum(saved.lon)) return saved;
    return getDefault();
  }

  // 호출
  function buildUrl(lat, lon){
    return CTX + '/api/weather/summary?lat=' + encodeURIComponent(lat) + '&lon=' + encodeURIComponent(lon);
  }
  async function fetchSummary(lat, lon){
    var res = await fetch(buildUrl(lat, lon), {
      credentials: 'include',
      cache: 'no-store',
      headers: { 'Accept': 'application/json' }
    });
    if (!res.ok) throw new Error('HTTP ' + res.status);
    var body = await res.json();
    if (body && typeof body === 'object' && Object.prototype.hasOwnProperty.call(body,'ok')){
      if (!body.ok) throw new Error(body.message || 'Server returned ok=false');
      return body.data;
    }
    return body;
  }
  async function loadAndRender(lat, lon, notice){
    showMsg('info', '날씨를 불러오는 중...');
    try{
      var data = await fetchSummary(lat, lon);
      hideMsg();
      renderAll(data);
      $('latInput').value = String(lat);
      $('lonInput').value = String(lon);
      setSaved(lat, lon);
      if (notice){ showMsg('success', notice); setTimeout(hideMsg, 1200); }
    }catch(e){
      console.warn('[WEATHER] fetch failed:', e);
      showMsg('danger', '날씨를 불러오지 못했습니다. 잠시 후 다시 시도해주세요.');
    }
  }

  // 초기화
  async function init(){
    var coords = await decideInitialCoords();
    if (!isFiniteNum(coords.lat) || !isFiniteNum(coords.lon)){
      var d = getDefault();
      await loadAndRender(d.lat, d.lon, '기본 위치(서울)로 표시합니다.');
    } else {
      await loadAndRender(coords.lat, coords.lon);
    }

    $('btnUseMyLocation') && $('btnUseMyLocation').addEventListener('click', async function(){
      var geo = await getGeoOrNull(4000);
      if (!geo) return showMsg('warning', '현재 위치를 가져오지 못했습니다.');
      loadAndRender(geo.lat, geo.lon, '현재 위치로 갱신되었습니다.');
    });

    $('btnLoadLatLon') && $('btnLoadLatLon').addEventListener('click', function(){
      var lat = parseFloat($('latInput').value);
      var lon = parseFloat($('lonInput').value);
      if (!isFinite(lat) || !isFinite(lon)) return showMsg('warning', '위도/경도를 올바르게 입력하세요.');
      loadAndRender(lat, lon, '입력한 좌표로 갱신되었습니다.');
    });
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();
})();
</script>

<jsp:include page="/WEB-INF/views/footer/footer.jsp" />
