package com.spring.app.weather.kma;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.net.URI;

@Slf4j
@Component
@RequiredArgsConstructor
public class KmaClient {

    @Value("${kma.base-url}")
    private String baseUrl;

    @Value("${kma.service-key}")
    private String serviceKey;

    private final RestTemplate restTemplate = new RestTemplate();

    public String call(String path, MultiValueMap<String,String> query) {
        // fromHttpUrl() 대신 fromUriString() 사용 (Spring 6.2 권장)
        UriComponentsBuilder b = UriComponentsBuilder
                .fromUriString(baseUrl + path)
                .queryParam("serviceKey", serviceKey)   // 인코딩 여부 무관하게 동작
                .queryParam("dataType", "JSON")
                .queryParams(query);

        URI uri = b.build(true).toUri(); // true: 개별 파라미터 인코딩 보존
        log.info("[KMA] GET {}", mask(uri.toString()));

        HttpHeaders headers = new HttpHeaders();
        headers.set(HttpHeaders.ACCEPT, MediaType.APPLICATION_JSON_VALUE);

        ResponseEntity<String> res =
                restTemplate.exchange(uri, HttpMethod.GET, new HttpEntity<>(headers), String.class);

        // getStatusCodeValue() 폐기 → value() 사용
        log.info("[KMA] status={} length={}",
                res.getStatusCode().value(),
                res.getBody()!=null ? res.getBody().length() : 0);

        return res.getBody();
    }

    private String mask(String url) {
        return url.replaceAll("(serviceKey=)([^&]+)","$1********");
    }
}
