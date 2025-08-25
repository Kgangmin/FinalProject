package com.spring.app.weather.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.spring.app.weather.dto.WeatherSummary;
import com.spring.app.weather.kma.KmaClient;
import com.spring.app.weather.kma.KmaGridConverter;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;

import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class KmaWeatherService {

    private final KmaClient kmaClient;
    private final ObjectMapper om = new ObjectMapper();
    private static final ZoneId KST = ZoneId.of("Asia/Seoul");

    public WeatherSummary getSummaryByLatLon(double lat, double lon){
        KmaGridConverter.Grid g = KmaGridConverter.toGrid(lat, lon);

        // 1) 초단기 실황(현재)
        Base baseNcst = latestUltraNcstBase();
        JsonNode ncst = call("/VilageFcstInfoService_2.0/getUltraSrtNcst", baseNcst, g);

        // 2) 초단기 예보(1시간 간격)
        Base baseUfc = latestUltraFcstBase();
        JsonNode ufc = call("/VilageFcstInfoService_2.0/getUltraSrtFcst", baseUfc, g);

        // 3) 단기 예보(3시간 간격, TMN/TMX 포함)
        Base baseVfc = latestVilageBase();
        JsonNode vfc = call("/VilageFcstInfoService_2.0/getVilageFcst", baseVfc, g);

        if (isEmpty(ncst) && isEmpty(ufc) && isEmpty(vfc)) {
            throw new IllegalStateException("KMA 응답이 비어있습니다.");
        }

        WeatherSummary.Location loc = WeatherSummary.Location.builder()
                .lat(lat).lon(lon).nx(g.nx()).ny(g.ny()).build();

        WeatherSummary.Current current = buildCurrent(ncst, ufc);
        List<WeatherSummary.Hourly> hourly = buildHourly(ufc, vfc);
        List<WeatherSummary.Daily>  daily  = buildDaily(vfc); // TMX/TMN fallback 포함

        if (current.getTemperature()!=null) current.setFeelsLike(current.getTemperature());

        return WeatherSummary.builder()
                .location(loc)
                .current(current)
                .hourly(hourly)
                .daily(daily)
                .build();
    }

    /* ------------ builders ------------- */

    private WeatherSummary.Current buildCurrent(JsonNode ncstItems, JsonNode ultraFcstItems){
        Map<String, String> obs = toCategoryMap(ncstItems);
        if (log.isDebugEnabled()) log.debug("[KMA] NCST keys={}", obs.keySet());

        Double t1h = parseD(obs.get("T1H"));
        Double reh = parseD(obs.get("REH"));
        Double wsd = parseD(obs.get("WSD"));
        Double vec = parseD(obs.get("VEC"));
        Double rn1 = parseRain(obs.get("RN1"));
        Integer sky = parseI(obs.get("SKY")); // 실황에는 보통 없음
        Integer pty = parseI(obs.get("PTY"));

        // SKY/PTY 보강: 초단기예보에서 현재와 가장 가까운 슬롯 사용
        if (sky == null || pty == null) {
            Map<String, Map<LocalDateTime, String>> uMap = toTimeCategoryMap(ultraFcstItems);
            LocalDateTime slot = nearestForecastSlot(uMap);
            if (slot != null) {
                if (sky == null) sky = parseI(get(uMap, "SKY", slot));
                if (pty == null) pty = parseI(get(uMap, "PTY", slot));
            }
        }

        String summary = skyPtyToText(sky, pty);

        return WeatherSummary.Current.builder()
                .time(LocalDateTime.now(KST).withSecond(0).withNano(0))
                .temperature(t1h)
                .humidity(reh)
                .windSpeed(wsd)
                .windDir(vec)
                .rain1h(rn1)
                .sky(sky)
                .pty(pty)
                .summary(summary)
                .build();
    }

    private LocalDateTime nearestForecastSlot(Map<String, Map<LocalDateTime, String>> cat){
        if (cat.isEmpty()) return null;
        Set<LocalDateTime> times = new HashSet<>();
        cat.values().forEach(m -> times.addAll(m.keySet()));
        if (times.isEmpty()) return null;

        LocalDateTime now = LocalDateTime.now(KST).withMinute(0).withSecond(0).withNano(0);
        return times.stream().min(Comparator.comparingLong(t -> Math.abs(Duration.between(now, t).toMinutes()))).orElse(null);
    }

    private List<WeatherSummary.Hourly> buildHourly(JsonNode ultraFcst, JsonNode vilageFcst){
        List<WeatherSummary.Hourly> list = new ArrayList<>();

        Map<String, Map<LocalDateTime, String>> uMap = toTimeCategoryMap(ultraFcst);
        list.addAll(mergeHourlyFromCategory(uMap));

        Map<String, Map<LocalDateTime, String>> vMap = toTimeCategoryMap(vilageFcst);
        List<WeatherSummary.Hourly> vList = mergeHourlyFromCategory(vMap);

        Set<LocalDateTime> exists = list.stream().map(WeatherSummary.Hourly::getTime).collect(Collectors.toSet());
        for (WeatherSummary.Hourly h : vList){
            if (exists.add(h.getTime())) list.add(h);
        }

        list.sort(Comparator.comparing(WeatherSummary.Hourly::getTime));
        LocalDateTime now = LocalDateTime.now(KST).withMinute(0).withSecond(0).withNano(0);
        return list.stream().filter(h -> !h.getTime().isBefore(now)).limit(30).collect(Collectors.toList());
    }

    private List<WeatherSummary.Hourly> mergeHourlyFromCategory(Map<String, Map<LocalDateTime, String>> catMap){
        List<WeatherSummary.Hourly> out = new ArrayList<>();
        Set<LocalDateTime> times = new HashSet<>();
        catMap.values().forEach(m -> times.addAll(m.keySet()));
        List<LocalDateTime> sorted = new ArrayList<>(times);
        Collections.sort(sorted);

        for (LocalDateTime t : sorted){
            WeatherSummary.Hourly h = new WeatherSummary.Hourly();
            h.setTime(t);
            h.setTemperature(parseD(get(catMap,"T1H",t))); // 초단기예보 기준
            if (h.getTemperature() == null) {
                h.setTemperature(parseD(get(catMap,"TMP",t))); // 단기예보 보강
            }
            h.setPty(parseI(get(catMap,"PTY",t)));
            h.setSky(parseI(get(catMap,"SKY",t)));
            h.setRainProb(parseD(get(catMap,"POP",t)));
            out.add(h);
        }
        return out;
    }

    private List<WeatherSummary.Daily> buildDaily(JsonNode root){
        Map<String, Map<LocalDateTime, String>> map = toTimeCategoryMap(root);

        // 날짜별 누적 버킷
        Map<LocalDate, WeatherSummary.Daily> acc = new HashMap<>();
        Map<LocalDate, List<Double>> tmpByDay = new HashMap<>(); // TMP로 대체 계산용

        Set<LocalDateTime> times = new HashSet<>();
        map.values().forEach(m -> times.addAll(m.keySet()));

        for (LocalDateTime t : times){
            LocalDate d = t.toLocalDate();
            WeatherSummary.Daily day = acc.computeIfAbsent(d, k ->
                    WeatherSummary.Daily.builder().date(d.atStartOfDay()).build());

            // 정오 근처의 하늘/강수형태 사용
            if (t.getHour() == 12){
                Integer sky = parseI(get(map,"SKY",t));
                Integer pty = parseI(get(map,"PTY",t));
                day.setSkyNoon(sky);
                day.setPtyNoon(pty);
            }

            // 일 강수확률 최대치
            Double pop = parseD(get(map,"POP",t));
            if (pop != null){
                day.setPopDay(day.getPopDay()==null ? pop : Math.max(day.getPopDay(), pop));
            }

            // 시간별 TMP 수집(최고/최저 대체 계산용)
            Double tmp = parseD(get(map, "TMP", t));
            if (tmp != null){
                tmpByDay.computeIfAbsent(d, k -> new ArrayList<>()).add(tmp);
            }
        }

        // TMX/TMN 우선 세팅 (있으면 쓰고)
        for (Map.Entry<LocalDate, WeatherSummary.Daily> e : acc.entrySet()){
            LocalDate d = e.getKey();
            WeatherSummary.Daily day = e.getValue();

            Double tmx = pickForDate(map, "TMX", d, true);
            Double tmn = pickForDate(map, "TMN", d, false);

            // 없으면 TMP에서 대체 계산
            List<Double> tmps = tmpByDay.getOrDefault(d, Collections.emptyList());
            if ((tmx == null || tmn == null) && !tmps.isEmpty()){
                double calcMax = tmps.stream().mapToDouble(v->v).max().orElse(Double.NaN);
                double calcMin = tmps.stream().mapToDouble(v->v).min().orElse(Double.NaN);
                if (tmx == null && !Double.isNaN(calcMax)) tmx = calcMax;
                if (tmn == null && !Double.isNaN(calcMin)) tmn = calcMin;
            }

            day.setTmax(tmx);
            day.setTmin(tmn);
        }

        List<WeatherSummary.Daily> list = new ArrayList<>(acc.values());
        list.sort(Comparator.comparing(WeatherSummary.Daily::getDate));
        return list.stream().limit(7).collect(Collectors.toList());
    }

    private Double pickForDate(Map<String, Map<LocalDateTime, String>> catMap, String cat, LocalDate date, boolean pickMax){
        Map<LocalDateTime, String> m = catMap.get(cat);
        if (m == null || m.isEmpty()) return null;
        Double out = null;
        for (Map.Entry<LocalDateTime, String> e : m.entrySet()){
            if (!e.getKey().toLocalDate().equals(date)) continue;
            Double v = parseD(e.getValue());
            if (v == null) continue;
            if (out == null) out = v;
            else out = pickMax ? Math.max(out, v) : Math.min(out, v);
        }
        return out;
    }

    /* ---------- KMA 호출 공통 ---------- */

    private JsonNode call(String path, Base base, KmaGridConverter.Grid g){
        var q = new LinkedMultiValueMap<String,String>();
        q.add("pageNo","1");
        q.add("numOfRows","1000");
        q.add("base_date", base.date);
        q.add("base_time", base.time);
        q.add("nx", String.valueOf(g.nx()));
        q.add("ny", String.valueOf(g.ny()));

        try{
            String body = kmaClient.call(path, q);
            if (body != null && body.startsWith("<?xml")) {
                throw new IllegalStateException("KMA returned XML fault");
            }
            JsonNode root = om.readTree(body);
            JsonNode items = root.path("response").path("body").path("items").path("item");
            if (log.isDebugEnabled()) {
                int sz = items.isArray() ? items.size() : 0;
                log.debug("[KMA] {} {}{} size={}", path, base.date, base.time, sz);
            }
            return items;
        }catch(Exception e){
            log.warn("KMA call parse error: {}", e.getMessage());
            return null;
        }
    }

    private static boolean isEmpty(JsonNode n){
        return n == null || !n.isArray() || n.size()==0;
    }

    private record Base(String date, String time){}

    private Base latestUltraNcstBase(){
        ZonedDateTime now = ZonedDateTime.now(KST);
        ZonedDateTime t = (now.getMinute() < 40) ? now.minusHours(1) : now;
        return new Base(t.format(DateTimeFormatter.ofPattern("yyyyMMdd")),
                        t.format(DateTimeFormatter.ofPattern("HH")) + "00");
    }

    private Base latestUltraFcstBase(){
        ZonedDateTime now = ZonedDateTime.now(KST);
        ZonedDateTime t = (now.getMinute() < 45) ? now.minusHours(1) : now;
        return new Base(t.format(DateTimeFormatter.ofPattern("yyyyMMdd")),
                        t.format(DateTimeFormatter.ofPattern("HH")) + "00");
    }

    private Base latestVilageBase(){
        int[] slots = {23,20,17,14,11,8,5,2};
        ZonedDateTime now = ZonedDateTime.now(KST);
        int hour = now.getHour();
        int baseHour = 2;
        for (int h : slots){
            if (hour >= h){ baseHour = h; break; }
        }
        if (hour < 2){
            now = now.minusDays(1);
            baseHour = 23;
        }
        return new Base(now.format(DateTimeFormatter.ofPattern("yyyyMMdd")),
                        String.format("%02d00", baseHour));
    }

    /* ---------- JSON 편의 ---------- */

    private Map<String,String> toCategoryMap(JsonNode items){
        Map<String,String> m = new HashMap<>();
        if (items == null) return m;
        for (JsonNode it : items){
            String cat = it.path("category").asText(null);
            String val = it.path("obsrValue").asText(null);
            if (cat != null && val != null) m.put(cat, val);
        }
        return m;
    }

    private Map<String, Map<LocalDateTime,String>> toTimeCategoryMap(JsonNode items){
        Map<String, Map<LocalDateTime,String>> cat = new HashMap<>();
        if (items == null) return cat;
        DateTimeFormatter D = DateTimeFormatter.ofPattern("yyyyMMdd");
        DateTimeFormatter T = DateTimeFormatter.ofPattern("HHmm");

        for (JsonNode it : items){
            String category = it.path("category").asText(null);
            String fcstDate = it.path("fcstDate").asText(null);
            String fcstTime = it.path("fcstTime").asText(null);
            String value    = it.path("fcstValue").asText(null);
            if (category==null || fcstDate==null || fcstTime==null) continue;
            LocalDate d = LocalDate.parse(fcstDate, D);
            LocalTime t = LocalTime.parse(fcstTime, T);
            LocalDateTime dt = LocalDateTime.of(d, t);

            cat.computeIfAbsent(category,k->new HashMap<>()).put(dt, value);
        }
        return cat;
    }

    private String get(Map<String, Map<LocalDateTime,String>> map, String cat, LocalDateTime t){
        Map<LocalDateTime,String> m = map.get(cat);
        return (m==null) ? null : m.get(t);
    }

    private Integer parseI(String s){
        try{ return (s==null||s.isBlank()) ? null : Integer.valueOf(s.trim()); }
        catch(Exception e){ return null; }
    }
    private Double parseD(String s){
        try{ return (s==null||s.isBlank()) ? null : Double.valueOf(s.trim()); }
        catch(Exception e){ return null; }
    }
    private Double parseRain(String s){
        if (s==null) return null;
        if ("-".equals(s)) return 0d;
        return parseD(s);
    }

    private String skyPtyToText(Integer sky, Integer pty){
        if (pty != null && pty != 0){
            return switch (pty){
                case 1 -> "비";
                case 2 -> "비/눈";
                case 3 -> "눈";
                case 5 -> "빗방울";
                case 6 -> "빗방울눈날림";
                case 7 -> "눈날림";
                default -> "강수";
            };
        }
        if (sky == null) return "알 수 없음";
        return switch (sky){
            case 1 -> "맑음";
            case 3 -> "구름많음";
            case 4 -> "흐림";
            default -> "맑음";
        };
    }
}
