package com.spring.app.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import com.spring.app.interceptor.LoginCheckInterceptor;

import lombok.RequiredArgsConstructor;

@Configuration  // Spring 컨테이너가 처리해주는 클래스로서, 클래스내에 하나 이상의 @Bean 메소드를 선언만 해주면 런타임시 해당 빈에 대해 정의되어진 대로 요청을 처리해준다. 
@RequiredArgsConstructor  // @RequiredArgsConstructor는 Lombok 라이브러리에서 제공하는 애너테이션으로, final 필드 또는 @NonNull이 붙은 필드에 대해 생성자를 자동으로 생성해준다. 
public class Interceptor_Configuration implements WebMvcConfigurer {

	// 로그인 Interceptor 설정하기
	private final LoginCheckInterceptor loginCheckInterceptor;
	
	@Override
    public void addInterceptors(InterceptorRegistry registry) {
		
        //  addInterceptor() : 인터셉터를 등록해준다.
        //  addPathPatterns() : 인터셉터를 호출하는 주소와 경로를 추가한다. 
        //  excludePathPatterns() : 인터셉터 호출에서 제외하는 주소와 경로를 추가한다. 
        
		registry.addInterceptor(loginCheckInterceptor)
		        .addPathPatterns("/**/*") // 해당 경로에 접근하기 전에 인터셉터가 가로챈다.
		        .excludePathPatterns("/login/loginStart"
		        		            ,"/login/loginEnd"  // 해당 경로는 인터셉터가 가로채지 않는다.
		        		            
		        		            // Interceptor 가 /css/*, /js/**, /images/** 등의 정적 자원까지 가로채고, 로그인하지 않은 사용자는 이들 리소스에 접근할 수 없게 되었기 때문에 excludePathPatterns 에 반드시 정적 리소스 경로를 포함시켜야 한다.!!!
		        		            ,"/bootstrap-4.6.2-dist/**"
		        		            ,"/js/**");
		        		            
	}

}
