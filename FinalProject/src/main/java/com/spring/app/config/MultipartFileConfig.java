package com.spring.app.config;
import jakarta.annotation.PostConstruct;
import jakarta.servlet.MultipartConfigElement;

import org.springframework.boot.web.servlet.MultipartConfigFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.util.unit.DataSize;

@Configuration
public class MultipartFileConfig {
	
	@PostConstruct
    public void bumpTomcatFileCountLimit() {
        // 예) 10,000개로 상향 (필요 값으로 조정)
        System.setProperty(
            "org.apache.tomcat.util.http.fileupload.FileUploadBase.fileCountMax",
            "10000"
        );
    }
	
}

