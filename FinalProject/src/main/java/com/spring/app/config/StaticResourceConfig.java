package com.spring.app.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class StaticResourceConfig implements WebMvcConfigurer {

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // 정적 리소스를 처리하는 경로 설정
        registry.addResourceHandler("/static/**")
                .addResourceLocations("classpath:/static/");  // /static/ 경로에 있는 리소스를 처리
    }
}
