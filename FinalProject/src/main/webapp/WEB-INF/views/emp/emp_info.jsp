<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
    
<%
	String ctxPath = request.getContextPath();
%>

<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>

<script type="text/javascript">

	$(function()
	{
		const toggleEditBtn = $('#toggleEditBtn');
		let isEditing = false;						//	default 는 수정 비활성화 상태로

		let originalData = {};						//	수정 활성화가 일어나기 전 원래 값 저장될 객체
		
		//	수정 활성화 시 태그 변경 및 UI 업데이트 해줄 함수
		function replaceInputsWithSpans(dataToDisplay)
		{
			const dynamicInputs = $('.dynamic-input');
			
			dynamicInputs.each(function()
			{
				const input = $(this);
				const name = input.attr('name');
				//	dataToDisplay에 해당 name의 값이 있다면 그 값을 사용하고, 없다면 input의 현재 값을 사용
				const value = dataToDisplay[name] !== undefined ? dataToDisplay[name] : input.val().trim(); 
	
				const span = $('<span>');
				span.addClass('display-field');
				span.data('name', name);
	
				//	기존 input이 editable이었는지 여부를 data-editable 속성으로 복원
				if(input.hasClass('editable-input-style'))	{	span.data('editable', true);	}
				else										{	span.data('editable', false);	}
	
				//	우편번호 필드 그룹 처리
				if(name === 'postcode')
				{
					const postcodeGroupElement = input.parent('.postcode-group');
					span.text(value); // 우편번호 값
					
					if(postcodeGroupElement.length)	{	postcodeGroupElement.replaceWith(span);	}
					else							{	input.replaceWith(span);	}	//	그룹 없이 input만 있던 경우 (혹시 모를 상황 대비)
				}
				/* 주소 관련 개별 input (address, detail_address, extra_address)은 
				// 나중에 combined-address-display span으로 한 번에 교체될 것이므로 여기서는 개별적으로 교체하지 않음
				else if (name === 'address' || name === 'detail_address' || name === 'extra_address')
				{
					// 이 필드들은 여기서 개별적으로 교체하지 않고 아래에서 combined-address-display span으로 한 번에 처리
				}
				*/
				else
				{
					span.text(value); // 일반 필드 값
					input.replaceWith(span);
				}
			});
	
			//	마지막으로 주소 그룹 span 재구성 (우편번호는 위에서 이미 교체됨)
			const addressInputsWrapperElement = $('.address-inputs-wrapper');
			
			if(addressInputsWrapperElement.length)
			{
				const combinedAddressText = dataToDisplay['address'] + 
											(dataToDisplay['detail_address'] ? '  ' + dataToDisplay['detail_address'] : '') + 
											(dataToDisplay['extra_address'] ? ' ' + dataToDisplay['extra_address'] : '');
				
				const addressGroupSpan = $('<span>').text(combinedAddressText)
													.addClass('display-field combined-address-display')
													.data
													({
														'name': 'address_group',
														'editable': true, // detail_address가 editable이었으므로 그룹도 editable
														'address-base': dataToDisplay['address'],
														'address-detail': dataToDisplay['detail_address'],
														'address-extra': dataToDisplay['extra_address']
													});
				
				addressInputsWrapperElement.replaceWith(addressGroupSpan);
			}
	
			//	UI 상태 최종 업데이트
			toggleEditBtn.text('정보수정');
			isEditing = false;
			
			// 파일 입력 필드 숨기기
			$('#profileFileInput').css('display', 'none');
		}
	
		//	수정 활성화 시 수정가능 필드 태그 전환 및 원본데이터 저장
		function handleEnterEditMode()
		{
			const displayFields = $('.display-field');	//	모든 display-field 선택
			
			originalData = {};	//	기존 데이터 초기화 (매번 수정 모드 진입 시 초기화)
			
			displayFields.each(function()
			{//	원본 데이터 저장
				const field = $(this);
				const name = field.data('name');
				const isEditable = field.data('editable') === true;
	
				if(name === 'address_group')
				{//	주소 그룹은 개별 주소 필드들을 저장
					originalData['address'] = field.data('address-base');
					originalData['detail_address'] = field.data('address-detail');
					originalData['extra_address'] = field.data('address-extra');
				}
				else if(isEditable)
				{// editable=true인 모든 필드에 대해 원본 데이터 저장
					originalData[name] = field.text().trim();
				}
			});
			
			displayFields.each(function()
			{//	선택자로 잡은 각각의 'display-field' 모두에게 적용
				const field = $(this);
				const value = field.text().trim();
				const fieldName = field.data('name');               //	필드 이름 가져오기
				const isEditable = field.data('editable') === true;	//	수정 가능 여부 확인
	
				//	주소 그룹 필드 처리 (postcode와 address_group)
				if (fieldName === 'postcode')
				{
					//	postcode input과 버튼 생성
					const inputPostcode = $('<input>').attr({ 'type': 'text', 'name': 'postcode', 'id': 'postcode' }).val(value).prop('readonly', true).addClass('dynamic-input readonly-input-style');
					const searchBtn = $('<button type="button" class="btn btn-secondary" id="zipcodeSearchBtn">우편번호찾기</button>');
	
					//	우편번호찾기 버튼 클릭 이벤트 (Daum Postcode API)
					searchBtn.on('click', function()
					{
						new daum.Postcode
						({
							oncomplete: function(data)
							{//	우편번호와 주소 정보를 해당 필드에 채움
								$('#postcode').val(data.zonecode);
								$('#address').val(data.roadAddress); // 도로명 주소 (기본 주소)
								
								//	참고항목 주소 (예: 건물명, 법정동명) 조합 로직
								let extraAddr = '';
								if(data.userSelectedType === 'R')
								{//	도로명 주소일 경우
									if(data.bname !== '' && /[동|로|가]$/g.test(data.bname))
									{// 법정동명이 있고 마지막 글자가 '동/로/가'로 끝날 경우
										extraAddr += data.bname;
									}
									if(data.buildingName !== '' && data.apartment === 'Y')
									{//	건물명이 있고 공동주택일 경우
										extraAddr += (extraAddr !== '' ? ', ' + data.buildingName : data.buildingName);
									}
									if(extraAddr !== '')
									{//	참고항목이 존재할 경우 괄호로 묶음
										extraAddr = ' (' + extraAddr + ')';
									}
								}
								
								$('#extra_address').val(extraAddr);	//	참고항목 주소 필드에 값 설정
								$('#detail_address').focus();		//	상세 주소 입력 필드로 포커스 이동
							}
						}).open();	// 우편번호 검색 팝업 열기
					});
	
					//	input과 버튼을 감싸는 div 생성 및 교체
					const postcodeInputGroup = $('<div></div>').addClass('input-group postcode-group');
					postcodeInputGroup.append(inputPostcode, searchBtn);	//	input과 버튼을 그룹에 추가
					field.replaceWith(postcodeInputGroup);					//	원래의 <span>을 이 그룹으로 교체
				}
				else if (fieldName === 'address_group')
				{// 주소 그룹 (address_group) 필드 처리
					//	'combined-address-display' <span>에서 개별 주소 데이터(data-속성) 가져오기
					const baseAddress = field.data('address-base');
					const detailAddress = field.data('address-detail');
					const extraAddress = field.data('address-extra');
	
					//	각 주소 부분에 대한 <input> 필드 생성
					const inputBase = $('<input>').attr({ 'type': 'text', 'name': 'address', 'id': 'address' }).val(baseAddress).prop('readonly', true).addClass('dynamic-input readonly-input-style');
					const inputDetail = $('<input>').attr({ 'type': 'text', 'name': 'detail_address', 'id': 'detail_address' }).val(detailAddress).prop('readonly', false).addClass('dynamic-input editable-input-style');
					const inputExtra = $('<input>').attr({ 'type': 'text', 'name': 'extra_address', 'id': 'extra_address' }).val(extraAddress).prop('readonly', true).addClass('dynamic-input readonly-input-style');
	
					//	생성된 input들을 감싸는 <div class="address-inputs-wrapper"> 생성 (레이아웃 유지를 위함)
					const addressInputsWrapper = $('<div></div>').addClass('address-inputs-wrapper');
					addressInputsWrapper.append(inputBase, inputDetail, inputExtra);	//	input들을 래퍼에 추가
						
					field.replaceWith(addressInputsWrapper); // 원래의 'address_group' <span>을 이 래퍼로 교체
				}
				else
				{//	일반 필드 (주소 관련 특수 필드 제외)
					const input = $('<input>');
					input.attr('type', 'text');
					input.val(value);
					input.attr('name', fieldName);
					input.addClass('dynamic-input');
					
					if (!isEditable)
					{//	수정 불가능한 필드
						input.prop('readonly', true);
						input.addClass('readonly-input-style');
					}
					else
					{//	수정 가능한 필드
						input.addClass('editable-input-style');
					}
					field.replaceWith(input);	//	<span>을 <input>으로 교체
				}
			});	//	end of displayFields.each(function()------------------------------------------------------------------
	
			toggleEditBtn.text('수정 완료');	//	jQuery의 text() 메서드로 텍스트 변경
			isEditing = true;
			
			// 파일 입력 필드 보이게 하기
			$('#profileFileInput').css('display', 'block');
		}
	
		//	수정 완료 시 데이터 수집, 유효성 검사, AJAX 통신을 처리하는 함수.
		function handleExitEditMode()
		{
			const dynamicInputs = $('.dynamic-input');	//	모든 dynamic-input 선택
			const currentInputData = {};				// 	현재 input 값들을 담을 객체
			const changedData = {};						// 서버로 보낼, 실제로 변경된 값만 담을 객체
			const addressFieldsInEdit = {};				//	수정 활성화 상태에서 주소 관련 <input> 필드들의 값을 임시로 저장할 객체
	
			dynamicInputs.each(function()
			{//	선택된 모든 dynamic-input 에 대해 실행
				const input = $(this);
				const value = input.val().trim();
				const name = input.attr('name');
	
				// 주소 관련 필드 값 임시 저장
				if (name === 'postcode' || name === 'address' || name === 'detail_address' || name === 'extra_address')
				{
					addressFieldsInEdit[name] = value;
				}
				else
				{//	일반 필드 처리 (currentInputData에 수정 가능한 필드 값만 추가)
					if (input.hasClass('editable-input-style'))
					{
						currentInputData[name] = value;
					}
				}
			});	//	end of dynamicInputs.each(function(){})---------------------------------------------------------------
				
			//	주소 관련 필드 값도 currentInputData에 포함 (유효성 검사를 통과했거나, 수정되지 않았을 경우)
			currentInputData['postcode'] = addressFieldsInEdit['postcode'];
			currentInputData['address'] = addressFieldsInEdit['address'];
			currentInputData['detail_address'] = addressFieldsInEdit['detail_address'];
			currentInputData['extra_address'] = addressFieldsInEdit['extra_address'];

			let hasChangedFields = false;
			
			//	originalData와 currentInputData를 비교하여 변경된 값만 changedData에 담기
            for (const key in currentInputData)
            {//	originalData에 해당 키가 없거나, 값이 다르다면 변경된 것으로 간주
                if(originalData[key] === undefined || String(originalData[key]) !== String(currentInputData[key]))
                {
					changedData[key] = currentInputData[key];
					hasChangedFields = true;
                }
            }
			
			//	선택된 파일 객체 가져오기
			const profileFile = $('#profileFileInput')[0].files[0];
			
			if(profileFile)
			{//	변경할 프로필 사진 선택이 있는경우
				const formData = new FormData();
				
				//	currentData의 모든 필드를 FormData에 추가
				for (const key in changedData)
				{
					if (Object.hasOwnProperty.call(changedData, key))
					{
						formData.append(key, changedData[key]);
					}
				}
				
				// 파일 추가
				formData.append('attach', profileFile); 
				
				$.ajax
				({
					url: ctxPath+"/emp/updateEmpInfoWithFile", // 파일 업로드용 URL
					type:"POST",
					data: formData,
					processData: false,   
					contentType: false,   
					dataType: "json",
					success: function(json)
					{
						console.log('데이터 및 파일 업데이트 성공:', json);
						alert(json.message); 
						replaceInputsWithSpans(currentInputData);
						window.location.reload();
					},
					error: function(request, status, error)
					{
						console.error('데이터 및 파일 업데이트 실패:', request, status, error);
						alert('정보 및 프로필 사진 업데이트에 실패했습니다. 다시 시도해 주세요.');
						replaceInputsWithSpans(originalData); 
					}
				});
			}
			else
			{// 프로필사진 변경 없이 정보수정을 하는 경우
				if(!hasChangedFields)
				{//	변경된 사항이 없을 경우
                    alert('변경된 내용이 없습니다.');
                    replaceInputsWithSpans(originalData); // 변경 없으므로 UI 원상복귀 (입력모드 해제)
                    return; // 변경된 내용이 없으므로 AJAX 요청 보내지 않음
                }
				
				$.ajax
				({
					url: ctxPath+"/emp/updateEmpInfo",
					type:"POST",
					contentType: 'application/json',
					data:JSON.stringify(changedData),
					dataType: "json",
					success: function(json)
					{
						console.log('데이터 업데이트 성공:', json);
						alert(json.message); 
						replaceInputsWithSpans(currentInputData);
						window.location.reload();
					},
					error: function(request, status, error)
					{
						console.error('데이터 업데이트 실패:', request, status, error);
						alert('정보 업데이트에 실패했습니다. 다시 시도해 주세요.');
						replaceInputsWithSpans(originalData);
					}
				});
			}
		}	//	end of function handleExitEditMode()-------------------------------------------------------------------------
		
		toggleEditBtn.on('click', function()
		{//	수정하기 버튼을 클릭했을 경우
			if(!isEditing)
			{//	수정 비활성화 -> 활성화 전환
				handleEnterEditMode(); // 수정 모드 진입 처리 함수 호출
			}
			else
			{//	수정 활성화 -> 비활성화 전환 (수정 완료)
				handleExitEditMode(); // 수정 완료 처리 함수 호출
			}
		});	//	end of toggleEditBtn.on('click', function()------------------------------------------------------------------
	});	//	end of $(function(){})-------------------------------------------------------------------------------------------

</script>

<c:set var="yymmdd" value="${fn:substring(empDto.rr_number,0,6)}"/>
<c:set var="genderCode" value="${fn:substring(empDto.rr_number,7,8)}"/>

<c:choose>
    <c:when test="${genderCode == '1' || genderCode == '2'}">
        <c:set var="yyyy_mm_dd" value="19${fn:substring(yymmdd,0,2)}-${fn:substring(yymmdd,2,4)}-${fn:substring(yymmdd,4,6)}"/>
    </c:when>
    <c:when test="${genderCode == '3' || genderCode == '4'}">
        <c:set var="yyyy_mm_dd" value="20${fn:substring(yymmdd,0,2)}-${fn:substring(yymmdd,2,4)}-${fn:substring(yymmdd,4,6)}"/>
    </c:when>
    <c:otherwise>
        <c:set var="yyyy_mm_dd" value="--"/>
    </c:otherwise>
</c:choose>

<script>const ctxPath = '<%=ctxPath%>';</script>
            
<link rel="stylesheet" href="<%=ctxPath%>/css/emp_info.css">

<div class="emp-info-container">
	<h2 class="page-title text-secondary pl-2">사원 정보</h2>
	
	<div class="emp-card">
	
		<table class="emp-info-table">
			<tr>
				<td rowspan="3" class="profile-cell">
					<img src="${pageContext.request.contextPath}/resources/images/emp_profile/${empDto.emp_save_filename}" 
                     alt="프로필 사진" class="profile-img"/>
				</td>
				<td class="label">사원번호</td>
				<td><span class="display-field" data-name="emp_no" data-editable="false">${empDto.emp_no}</span></td>
				<td class="label">이름</td>
				<td><span class="display-field" data-name="emp_name" data-editable="false">${empDto.emp_name}</span></td>
			</tr>
			<tr>
				<td class="label">주민등록번호</td>
				<td><span class="display-field" data-name="rr_number" data-editable="false">${empDto.rr_number}</span></td>
				<td class="label">성별</td>
				<td>
					<span class="display-field" data-name="gender" data-editable="false">
						<c:choose>
							<c:when test="${genderCode == '1' || genderCode == '3'}">남</c:when>
							<c:when test="${genderCode == '2' || genderCode == '4'}">여</c:when>
						</c:choose>
					</span>
				</td>
			</tr>
			<tr>
				<td class="label">생년월일</td>
				<td><span class="display-field" data-name="birthday" data-editable="false">${yyyy_mm_dd}</span></td>
				<td class="label"></td>
				<td></td>
			</tr>
			<tr>
				<td class="text-center label">
					<input type="file" name="attach" id="profileFileInput" />
					<span class="status-badge 
                    	<c:choose>
                        	<c:when test="${empDto.emp_status == '재직'}">bg-primary</c:when>
                        	<c:when test="${empDto.emp_status == '퇴사'}">bg-light text-secondary</c:when>
                    	</c:choose>
                	">
                    	<c:out value="${empDto.emp_status != null ? empDto.emp_status : ''}"/>
                	</span>
				</td>
				<td class="label">주소</td>
				<td colspan="3" class="address-fields-td"> <%-- 주소 필드들을 담을 td에 클래스 추가 --%>
					<%-- 우편번호 필드는 별도의 span으로 유지 --%>
					<span class="display-field" data-name="postcode" data-editable="false">${empDto.postcode}</span>
                    
					<%-- 주소, 상세주소, 참고항목을 하나의 span으로 묶어 보여주고, 데이터 속성에 각 값을 저장 --%>
					<span class="display-field combined-address-display" data-name="address_group" data-editable="true"
						  data-address-base="${empDto.address}"
						  data-address-detail="${empDto.detail_address}"
						  data-address-extra="${empDto.extra_address}">
						${empDto.address}&nbsp;&nbsp;${empDto.detail_address}&nbsp;${empDto.extra_address}
					</span>
				</td>
			</tr>
			
			<tr>
				<td colspan="5"><br></td>
			</tr>
			
			<tr>
				<td colspan="2" class="label">직급</td>
				<td><span class="display-field" data-name="rank_name" data-editable="false">${empDto.rank_name}</span></td>
				<td class="label">부서</td>
				<td><span class="display-field" data-name="dept_name" data-editable="false">${empDto.dept_name}</span></td>
			</tr>
			<tr>
				<td colspan="2" class="label"></td>
				<td></td>
				<td class="label">소속</td>
				<td><span class="display-field" data-name="team_name" data-editable="false">${empDto.team_name}</span></td>
			</tr>
			
			<tr>
				<td colspan="5"><br></td>
			</tr>
			
			<tr>
				<td colspan="2" class="label">휴대폰 번호</td>
				<td><span class="display-field" data-name="phone_num" data-editable="true">${empDto.phone_num}</span></td>
				<td class="label"></td>
				<td></td>
			</tr>
			<tr>
				<td colspan="2" class="label">사내 이메일</td>
				<td><span class="display-field" data-name="emp_email" data-editable="true">${empDto.emp_email}</span></td>
				<td class="label">외부 이메일</td>
				<td><span class="display-field" data-name="ex_email" data-editable="true">${empDto.ex_email}</span></td>
			</tr>
			<tr>
				<td colspan="2" class="label">은행</td>
				<td><span class="display-field" data-name="emp_bank" data-editable="true">${empDto.emp_bank}</span></td>
				<td class="label">계좌번호</td>
				<td><span class="display-field" data-name="emp_account" data-editable="true">${empDto.emp_account}</span></td>
			</tr>
			
		</table>
	
	</div>

    <div style="text-align: center; margin-top: 20px;">
        <button type="button" id="toggleEditBtn" class="btn btn-primary">정보수정</button>
    </div>

</div>