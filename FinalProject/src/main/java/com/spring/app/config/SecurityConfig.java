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
public class SecurityConfig {

    private final LoginSuccessHandler loginSuccessHandler;
    private final LegacyLoginuserBridgeFilter legacyLoginuserBridgeFilter;

    @Bean
    PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            // 개발 중 CSRF 비활성 (필요시 다시 켜기)
            .csrf(csrf -> csrf.disable())

            // URL별 접근권한
            .authorizeHttpRequests(auth -> auth
                .requestMatchers(
                    "/login", "/login/**", "/loginProc",
                    "/error", "/error/**", "/favicon.ico",
                    "/bootstrap-4.6.2-dist/**", "/js/**", "/css/**", "/images/**", "/img/**", "/webjars/**",
                    "/WEB-INF/views/**",
                    // ✅ 스마트에디터 정적 리소스 허용 (여기가 핵심)
                    "/smarteditor/**",
                    // (구프로젝트 호환용. 실제로 쓰면 유지, 아니면 지워도 됨)
                    "/resources/**"
                ).permitAll()
                .anyRequest().authenticated()
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




