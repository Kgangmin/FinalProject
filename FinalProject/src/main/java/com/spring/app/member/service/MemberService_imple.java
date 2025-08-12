package com.spring.app.member.service;

import org.springframework.stereotype.Service;

import com.spring.app.member.domain.MemberDTO;
import com.spring.app.member.model.MemberDAO;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Service
public class MemberService_imple implements MemberService {

	 private final MemberDAO memberdao;
	 
	    @Override
	    public MemberDTO getMember(String empNo) {
	        return memberdao.selectMemberByEmpNo(empNo);
	    }
}
