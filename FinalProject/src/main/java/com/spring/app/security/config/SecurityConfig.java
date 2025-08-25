package com.spring.app.security.config;

import javax.sql.DataSource;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.provisioning.JdbcUserDetailsManager;
import org.springframework.security.provisioning.UserDetailsManager;
import org.springframework.security.web.SecurityFilterChain;

import jakarta.servlet.DispatcherType;
import lombok.RequiredArgsConstructor;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig
{
/*	private final DataSource dataSource;
	
	//	비밀번호 암호화 및 비교
	@Bean
	public PasswordEncoder passwordEncoder()
	{
		return new BCryptPasswordEncoder();
	}
	
	//	HTTP 요청에 대한 인증/인가/보안 정책 설정
	@Bean
	public SecurityFilterChain filterChain(HttpSecurity http) throws Exception
	{
		http.authorizeHttpRequests(auth -> auth
				.dispatcherTypeMatchers(DispatcherType.FORWARD).permitAll()
				.requestMatchers("/login/loginStart", "/login/loginEnd").permitAll()
				
				.anyRequest().authenticated()
				);
		
		//	폼 로그인 설정
        http.formLogin(form -> form
            .loginPage("/login/loginStart")       // 커스텀 로그인 페이지
            .loginProcessingUrl("/login/loginEnd") // POST 로그인 처리 URL
            .defaultSuccessUrl("/index")           // 로그인 성공 시 이동
            .failureUrl("/login/loginStart?error") // 로그인 실패 시 이동
            .permitAll()
        );

        //	로그아웃 설정
        http.logout(logout -> logout
            .logoutUrl("/login/logout")
            .logoutSuccessUrl("/login/loginStart?logout")
            .invalidateHttpSession(true)
            .deleteCookies("JSESSIONID")
        );
        
		return http.build();
	}
	
	@Bean
	public UserDetailsManager userDetailsService()
	{
		JdbcUserDetailsManager userDetailsManager = new JdbcUserDetailsManager(dataSource);
		
		// 사용자 조회
        userDetailsManager.setUsersByUsernameQuery
        (
            " select	emp_no as username, emp_pwd as password, "+
            " 			case	when	emp_status='재직'"+
            "					then	1	else	0 "+
            " 					end		as enabled "+
            " from 		tbl_employee "+
            " where		emp_no = ? "
        );

        // 권한 조회
        userDetailsManager.setAuthoritiesByUsernameQuery
        (
            " select	e.emp_no as username, per.permission_code as authority "+
            " from		tbl_employee e "+
            " join 		tbl_employee_position ep "+
            " on		e.emp_no = ep.fk_emp_no "+
            " join		tbl_position p "+
            " on		ep.fk_position_no = p.position_no "+
            " join		tbl_position_permission pp "+
            " on		p.position_no = pp.fk_position_no "+
            " join		tbl_permission per "+
            " on		pp.fk_permission_no = per.permission_no "+
            " where		e.emp_no = ? "
        );
        
		return userDetailsManager;
	}*/
}
