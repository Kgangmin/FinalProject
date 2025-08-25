package com.spring.app.weather.dto;

import lombok.*;

import java.time.LocalDateTime;
import java.util.List;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class WeatherSummary {
    private Location location;
    private Current current;
    private List<Hourly> hourly;  // 최대 24~48개
    private List<Daily>  daily;   // 3~7일

    @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
    public static class Location {
        private double lat;
        private double lon;
        private int nx;
        private int ny;
        private String name; // 선택 사항(검색 등 확장용)
    }

    @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
    public static class Current {
        private LocalDateTime time;
        private Double temperature; // T1H
        private Double feelsLike;   // 체감(간단계산)
        private Integer sky;        // SKY(1~4)
        private Integer pty;        // 강수형태(0,1,2,3,5,6,7)
        private Double humidity;    // REH
        private Double windSpeed;   // WSD
        private Double windDir;     // VEC
        private Double rain1h;      // RN1 (mm)
        private String   summary;   // 간단 날씨문구
    }

    @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
    public static class Hourly {
        private LocalDateTime time;
        private Double temperature;
        private Integer sky;
        private Integer pty;
        private Double rainProb; // POP (단기)
    }

    @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
    public static class Daily {
        private LocalDateTime date; // 00:00로 맞춤
        private Double tmin;        // TMN
        private Double tmax;        // TMX
        private Integer skyNoon;    // 하늘상태(정오 기준)
        private Integer ptyNoon;
        private Double popDay;      // 강수확률(하루 최대)
    }
}
