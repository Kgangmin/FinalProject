package com.spring.app.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpStatus;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.HttpStatusEntryPoint;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;
import org.springframework.security.web.util.matcher.NegatedRequestMatcher;
import org.springframework.security.web.util.matcher.OrRequestMatcher;
import org.springframework.security.web.util.matcher.RequestMatcher;

import com.spring.app.security.LegacyLoginuserBridgeFilter;
import com.spring.app.security.LoginSuccessHandler;

import lombok.RequiredArgsConstructor;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig
{
	private final LoginSuccessHandler loginSuccessHandler;
	private final LegacyLoginuserBridgeFilter legacyLoginuserBridgeFilter;
	
	@Value("${app.security.csrf:false}")
	private boolean csrfEnabled;
	
	@Bean
	PasswordEncoder passwordEncoder()
	{
		return new BCryptPasswordEncoder();
	}
	
	@Bean
	SecurityFilterChain filterChain(HttpSecurity http) throws Exception
	{
		if (csrfEnabled) {
	           // 두 엔드포인트 묶기
	           RequestMatcher onlyPwdApis = new OrRequestMatcher(
	               new AntPathRequestMatcher("/emp/verifyPassword"),
	               new AntPathRequestMatcher("/emp/changePassword")
	           );
	           // ★ 두 엔드포인트의 "부정(NOT)" = 그 외 전부를 CSRF 무시
	           http.csrf(csrf -> csrf
	               .ignoringRequestMatchers(new NegatedRequestMatcher(onlyPwdApis))
	           );
	       } else {
	           http.csrf(csrf -> csrf.disable());
	       }
			
		http	
			//	URL별 접근권한 설정
			.authorizeHttpRequests(auth -> auth
				.requestMatchers(
						"/login", "/login/**","/loginProc",
				          "/error", "/error/**", "/favicon.ico",
				          "/bootstrap-4.6.2-dist/**", "/js/**", "/css/**", "/images/**", "/img/**", "/webjars/**",
				          "/WEB-INF/views/**",
				          // ✅ 스마트에디터 정적 리소스 허용 (여기가 핵심)
				          "/smarteditor/**",
				          // (구프로젝트 호환용. 실제로 쓰면 유지, 아니면 지워도 됨)
				          "/resources/**"
				         ).permitAll()
				
				// ★ 알림 API는 AJAX로 호출 → 인증 없어도 조회 가능하게
                .requestMatchers("/api/notifications").permitAll()
                
				//	특정 권한이 있어야 접근가능한 URL
                .requestMatchers("/emp/emp_list").hasAuthority("HR_VIEW")
                
                
				//	위에서 지정한 URL 외의 모든 요청은 '인증(로그인)'된 사용자만 접근가능
				.anyRequest().authenticated()
			)
			
            // ★ API로 인증 안 된 접근 시 302 리다이렉트 대신 401을 주도록 설정
            .exceptionHandling(e -> e
                .defaultAuthenticationEntryPointFor(
                    new HttpStatusEntryPoint(HttpStatus.UNAUTHORIZED),
                    new AntPathRequestMatcher("/api/**"))
                )


            // 로그인 폼
            .formLogin(form -> form
                .loginPage("/login")
                .loginProcessingUrl("/loginProc")
                .successHandler(loginSuccessHandler)
                .failureUrl("/login?error=true")
                .permitAll()
            )

            // 로그아웃
            .logout(logout -> logout
                .logoutUrl("/logout")
                .logoutSuccessUrl("/login")
                .invalidateHttpSession(true)
                .deleteCookies("JSESSIONID")
            )

            // ✅ iframe 허용 (같은 도메인만) — SmartEditor 스킨이 iframe으로 뜸
            .headers(headers -> headers
                .frameOptions(frame -> frame.sameOrigin())
                // (선택) CSP 쓰는 경우 프레임 허용
                // .contentSecurityPolicy(csp -> csp
                //     .policyDirectives("default-src 'self'; frame-ancestors 'self';")
                // )
            );

        http.addFilterAfter(
            legacyLoginuserBridgeFilter,
            org.springframework.security.web.context.SecurityContextHolderFilter.class
        );

        return http.build();
    }
}




