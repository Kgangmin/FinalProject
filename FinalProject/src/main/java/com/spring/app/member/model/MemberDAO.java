package com.spring.app.member.model;

import org.apache.ibatis.annotations.Mapper;

import com.spring.app.member.domain.MemberDTO;

@Mapper
public interface MemberDAO {

	MemberDTO selectMemberByEmpNo(String empNo);
	
}
