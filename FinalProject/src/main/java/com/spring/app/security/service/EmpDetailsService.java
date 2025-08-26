package com.spring.app.security.service;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.security.authentication.DisabledException;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.spring.app.emp.domain.EmpDTO;
import com.spring.app.emp.model.EmpDAO;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class EmpDetailsService implements UserDetailsService
{
	private final EmpDAO empDao;
	
	@Override
	public UserDetails loadUserByUsername(String empNo) throws UsernameNotFoundException
	{
		//	1. 사원정보 조회
		EmpDTO empDto = (EmpDTO) empDao.findByEmpNo(empNo);
		
		if(empDto == null)
		{
			throw new UsernameNotFoundException("존재하지 않는 사원번호 입니다 : " + empNo);
		}
		
		//	2.	재직 상태가 아닐 경우 로그인 거부
		if(!"재직".equals(empDto.getEmp_status()))
		{
			throw new DisabledException("로그인이 비활성화 된 계정입니다 (상태 : "+empDto.getEmp_status()+")");
		}
		
		//	3. 사원권한 목록 조회
		List<String> permission = empDao.findPermissionByEmpNo(empNo);
		
		//	4. 조회된 정보를 바탕으로 Spring Securit가 사용할 UserDetails 객체 생성
		return User.builder()
				.username(empDto.getEmp_no())
				.password(empDto.getEmp_pwd())
				.authorities(permission.stream()
									.map(SimpleGrantedAuthority::new)
									.collect(Collectors.toList()))
				.build();
	}
}
