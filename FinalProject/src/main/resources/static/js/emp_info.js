$(function()
{
	const toggleEditBtn = $('#toggleEditBtn');	//	jQuery 선택자로 버튼 선택
	let isEditing = false;						//	default 는 수정 비활성화 상태로

    toggleEditBtn.on('click', function()
	{//	jQuery의 on() 메서드를 사용하여 이벤트 리스너 연결
		if(!isEditing)
		{//	수정 비활성화 -> 활성화 전환
            const displayFields = $('.display-field');				//	jQuery 선택자로 모든 display-field 선택
			
            displayFields.each(function()
			{//	jQuery의 each() 메서드로 각 요소 순회
				const field = $(this);								//	현재 span 요소를 jQuery 객체로 감싸기
				const value = field.text().trim();					//	jQuery의 text() 메서드 사용
				const isEditable = field.data('editable') === true;	//	jQuery의 data() 메서드 사용

				const input = $('<input>');							//	jQuery로 input 요소 생성
				input.attr('type', 'text');							//	jQuery의 attr() 메서드로 속성 설정
				input.val(value);									//	jQuery의 val() 메서드로 값 설정
                input.attr('name', field.data('name'));				//	name 속성 설정
                input.addClass('dynamic-input');					//	jQuery의 addClass() 메서드로 클래스 추가
                
				if(!isEditable)
				{//	수정 불가능한 필드
					input.prop('readonly', true);			//	jQuery의 prop() 메서드로 readonly 설정
					input.addClass('readonly-input-style');	//	readonly 스타일을 위한 클래스 추가
                }
				else
				{//	수정 가능한 필드
					input.addClass('editable-input-style');	//	editable 스타일을 위한 클래스 추가
                }
                
                field.replaceWith(input);					//	jQuery의 replaceWith() 메서드로 요소 교체
			});	//	end of displayFields.each(function()-------------------------------------------------------------

			toggleEditBtn.text('수정 완료');	//	jQuery의 text() 메서드로 텍스트 변경
			isEditing = true;
		}
		else
		{//	수정 활성화 -> 비활성화 전환 (수정 완료)
			const dynamicInputs = $('.dynamic-input');	// jQuery 선택자로 모든 dynamic-input 선택
			const updatedData = {};						// 서버로 보낼 데이터 객체

            dynamicInputs.each(function()
			{//	jQuery의 each() 메서드로 각 요소 순회
				const input = $(this);				//	현재 input 요소를 jQuery 객체로 감싸기
				const value = input.val().trim();	//	jQuery의 val() 메서드로 값 가져오기
				const name = input.attr('name');	//	jQuery의 attr() 메서드로 name 가져오기

                const span = $('<span>');			//	jQuery로 span 요소 생성
                span.text(value);					//	jQuery의 text() 메서드로 텍스트 설정
                span.addClass('display-field');		//	다시 display-field 클래스 추가
                span.data('name', name);			//	data-name 속성 복원

                //	input이 원래 editable이었는지 여부를 data-editable 속성으로 복원
                if(input.hasClass('editable-input-style'))
				{//	jQuery의 hasClass() 메서드 사용
					span.data('editable', true);
					updatedData[name] = value;		//	수정 가능한 필드만 데이터 수집
				}
				else
				{
					span.data('editable', false);
                }
                
                input.replaceWith(span);			//	jQuery의 replaceWith() 메서드로 요소 교체
            });

			$.ajax
			({
				url: ctxPath+"/emp/updateEmpInfo.do",
				type:"POST",
				data:JSON.stringify(updatedData),
				dataType: "json", // 전송할 데이터의 타입 (JSON 형식)
				success: function(json)
				{//	서버로부터 성공적으로 응답을 받았을 때 실행될 코드
					console.log('데이터 업데이트 성공:', response);
					alert('정보가 성공적으로 업데이트되었습니다.'); // 사용자에게 알림
					// 필요에 따라 UI 업데이트 또는 페이지 새로고침
				},
				error: function(request, status, error)
				{//	서버 통신 중 오류가 발생했을 때 실행될 코드
					alert('정보 업데이트에 실패했습니다. 다시 시도해 주세요.'); // 사용자에게 알림
				}
			});

			toggleEditBtn.text('정보수정'); // 버튼 텍스트 변경
			isEditing = false;
		}
    });	//	end of toggleEditBtn.on('click', function()--------------------------------------------------------------
});	//	end of $(function(){})---------------------------------------------------------------------------------------