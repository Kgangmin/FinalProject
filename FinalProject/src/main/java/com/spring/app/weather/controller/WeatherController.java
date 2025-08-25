package com.spring.app.weather.controller;

import com.spring.app.weather.dto.WeatherSummary;
import com.spring.app.weather.service.KmaWeatherService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@Controller
@RequiredArgsConstructor
public class WeatherController {

    private final KmaWeatherService service;

    /** 화면 */
    @GetMapping("/weather")
    public String weatherPage(HttpServletRequest req){
        // 단순 화면 반환 (JSP에서 fetch로 데이터 요청)
        return "weather/weather";
    }

    /** 데이터: /api/weather/summary?lat=37.5665&lon=126.9780  (lat/lon 없으면 서울시청) */
    @GetMapping("/api/weather/summary")
    @ResponseBody
    public ResponseEntity<?> apiSummary(
            @RequestParam(required = false) Double lat,
            @RequestParam(required = false) Double lon){
    	double la = (lat==null ? 37.5665 : lat);
        double lo = (lon==null ? 126.9780 : lon);
        try{
            WeatherSummary s = service.getSummaryByLatLon(la, lo);
            return ResponseEntity.ok(s);
        }catch(Exception e){
            log.warn("[WEATHER] summary failed lat={},lon={} : {}", la, lo, e.getMessage());
            return ResponseEntity.status(502).body(
                    java.util.Map.of("error", true, "message", "KMA 호출 실패")
                    );
        }
    }
}
