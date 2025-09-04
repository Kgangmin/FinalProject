// src/main/java/com/spring/app/org/service/OrganizationService_imple.java
package com.spring.app.org.service;

import java.util.*;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.spring.app.org.domain.DeptDTO;
import com.spring.app.org.domain.EmpNodeDTO;
import com.spring.app.org.model.OrganizationDAO;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class OrganizationService_imple implements OrganizationService {

    private final OrganizationDAO organizationDAO;

    @Override
    public Map<String, Object> buildOrgChart() {

        final List<DeptDTO> deptDto = organizationDAO.selectDepartmentsHavingEmployees();
        
        final Map<String, DeptDTO> deptMap = deptDto.stream()
                .collect(Collectors.toMap(DeptDTO::getDeptNo, d -> d, (a,b)->a, LinkedHashMap::new));
        
        final Set<String> deptSet = deptMap.keySet();

        final List<DeptDTO> topDepts = deptDto.stream()
                .filter(d -> d.getParentDeptNo() == null)
                .collect(Collectors.toList());

        final List<EmpNodeDTO> empDto = organizationDAO.selectDepartmentEmployeesWithPositions()
                .stream()
                .filter(e -> e.getDeptNo() != null && deptSet.contains(e.getDeptNo()))
                .collect(Collectors.toList());

        final Map<String, List<EmpNodeDTO>> byDept = empDto.stream()
                .collect(Collectors.groupingBy(EmpNodeDTO::getDeptNo, LinkedHashMap::new, Collectors.toList()));

        final Map<String, EmpNodeDTO> repByDept = new LinkedHashMap<>();
        byDept.forEach((deptNo, list) -> {
            list.sort(Comparator
                .comparing((EmpNodeDTO empNodeDto) -> Optional.ofNullable(empNodeDto.getRankLevel()).orElse(Integer.MAX_VALUE))
                .thenComparing(EmpNodeDTO::getEmpNo));
            repByDept.put(deptNo, list.get(0));
        });

        final List<Map<String, Object>> nodes = new ArrayList<>();
        for (EmpNodeDTO e : empDto) {
            DeptDTO d = deptMap.get(e.getDeptNo());
            String deptName = (d != null ? d.getDeptName() : "");

            Map<String, Object> node = new LinkedHashMap<>();
            node.put("id", "E" + e.getEmpNo());
            node.put("name", deptName);
            node.put("title", e.getEmpName() + " " + (e.getRankName() == null ? "" : e.getRankName()));
            node.put("custom", Map.of(
                "positions", Optional.ofNullable(e.getPositions()).orElse(""),
                "empName", e.getEmpName(),
                "photo", Optional.ofNullable(e.getEmpSaveFilename()).orElse("default_profile.jpg")
            ));
            nodes.add(node);
        }


        for (EmpNodeDTO empNodeDto : empDto) {
            DeptDTO d = deptMap.get(empNodeDto.getDeptNo());
            String deptName = (d != null ? d.getDeptName() : "");

            Map<String, Object> node = new LinkedHashMap<>();
            node.put("id", "E" + empNodeDto.getEmpNo());
            node.put("name", deptName);
            node.put("title", empNodeDto.getEmpName() + " " + (empNodeDto.getRankName() == null ? "" : empNodeDto.getRankName()));
            node.put("custom", Map.of(
                "positions", Optional.ofNullable(empNodeDto.getPositions()).orElse(""),
                "empName", empNodeDto.getEmpName(),
                "photo", Optional.ofNullable(empNodeDto.getEmpSaveFilename()).orElse("default_profile.jpg")
            ));
            nodes.add(node);
        }

        String rootId = null;

        Optional<DeptDTO> companyTop = topDepts.stream()
                .filter(d -> "회사전체".equals(d.getDeptName()))
                .findFirst();

        if (companyTop.isPresent()) {
            EmpNodeDTO rep = repByDept.get(companyTop.get().getDeptNo());
            if (rep != null) rootId = "E" + rep.getEmpNo();
        } else if (topDepts.size() > 1) {
            rootId = "ROOT";
            nodes.add(Map.of("id", rootId, "name", "회사전체"));
        }

        final List<List<String>> edges = new ArrayList<>();

        if ("ROOT".equals(rootId)) {
            for (DeptDTO td : topDepts) {
                EmpNodeDTO rep = repByDept.get(td.getDeptNo());
                if (rep != null) edges.add(Arrays.asList(rootId, "E" + rep.getEmpNo()));
            }
        } else if (rootId == null && topDepts.size() == 1) {
            EmpNodeDTO rep = repByDept.get(topDepts.get(0).getDeptNo());
            if (rep != null) rootId = "E" + rep.getEmpNo();
        }

        for (DeptDTO child : deptDto) {
            String p = child.getParentDeptNo();
            if (p == null) continue;
            EmpNodeDTO parentRep = repByDept.get(p);
            EmpNodeDTO childRep  = repByDept.get(child.getDeptNo());
            if (parentRep != null && childRep != null) {
                edges.add(Arrays.asList("E" + parentRep.getEmpNo(), "E" + childRep.getEmpNo()));
            }
        }

        byDept.forEach((deptNo, list) -> {
            EmpNodeDTO rep = repByDept.get(deptNo);
            if (rep == null) return;
            String repId = "E" + rep.getEmpNo();
            for (EmpNodeDTO e : list) {
                if (e.getEmpNo().equals(rep.getEmpNo())) continue;
                edges.add(Arrays.asList(repId, "E" + e.getEmpNo()));
            }
        });

        Map<String, Object> out = new LinkedHashMap<>();
        out.put("ok", true);
        if (rootId != null) out.put("root", rootId);
        out.put("edges", edges);
        out.put("nodes", nodes);
        return out;
    }

    // 특정 부서(rootDeptNo)를 루트로 하는 서브트리 조직도 생성 
    @Override
    public Map<String, Object> buildOrgChartByDept(String rootDeptNo) {
        // 1) 기본 데이터 로드
        final List<DeptDTO> depts = organizationDAO.selectDepartmentsHavingEmployees();
        final Map<String, DeptDTO> deptMap = depts.stream()
                .collect(Collectors.toMap(DeptDTO::getDeptNo, d -> d, (a,b)->a, LinkedHashMap::new));
        if (!deptMap.containsKey(rootDeptNo)) {
            // 유효하지 않은 부서번호
            return Map.of("ok", false, "msg", "invalid rootDept");
        }

        // 2) 서브트리(루트 부서 + 하위 부서들) 수집
        final Set<String> subtree = collectSubtreeDeptNos(depts, rootDeptNo);

        // 3) 사원 조회(서브트리 필터)
        final List<EmpNodeDTO> allEmps = organizationDAO.selectDepartmentEmployeesWithPositions();
        final List<EmpNodeDTO> emps = allEmps.stream()
                .filter(e -> e.getDeptNo() != null && subtree.contains(e.getDeptNo()))
                .collect(Collectors.toList());

        if (emps.isEmpty()) {
            return Map.of("ok", false, "msg", "no employees in subtree");
        }

        // 4) 부서별 그룹 & 대표자(최상위 직급) 선정
        final Map<String, List<EmpNodeDTO>> byDept = emps.stream()
                .collect(Collectors.groupingBy(EmpNodeDTO::getDeptNo, LinkedHashMap::new, Collectors.toList()));

        final Map<String, EmpNodeDTO> repByDept = new LinkedHashMap<>();
        byDept.forEach((deptNo, list) -> {
            list.sort(Comparator
                    .comparing((EmpNodeDTO x) -> Optional.ofNullable(x.getRankLevel()).orElse(Integer.MAX_VALUE))
                    .thenComparing(EmpNodeDTO::getEmpNo));
            repByDept.put(deptNo, list.get(0));
        });

        // 5) 루트 대표자
        EmpNodeDTO rootRep = repByDept.get(rootDeptNo);
        if (rootRep == null) {
            return Map.of("ok", false, "msg", "no representative at root");
        }
        final String rootId = "E" + rootRep.getEmpNo();

        // 6) 노드(회사전체 포맷 유지 + 사진/이름용 custom 포함)
        final List<Map<String, Object>> nodes = new ArrayList<>();
        for (EmpNodeDTO e : emps) {
            DeptDTO d = deptMap.get(e.getDeptNo());
            String deptName = (d != null ? d.getDeptName() : "");
            Map<String, Object> custom = new LinkedHashMap<>();
            custom.put("positions", Optional.ofNullable(e.getPositions()).orElse(""));
            custom.put("empName", e.getEmpName());
            custom.put("photo", Optional.ofNullable(e.getEmpSaveFilename()).orElse("default_profile.jpg"));

            Map<String, Object> node = new LinkedHashMap<>();
            node.put("id", "E" + e.getEmpNo());
            node.put("name", deptName);
            node.put("title", e.getEmpName() + " " + (e.getRankName() == null ? "" : e.getRankName()));
            node.put("custom", custom);
            nodes.add(node);
        }

        // 7) 엣지 (부모부서 대표자 -> 자식부서 대표자), (대표자 -> 같은 부서의 나머지 사원)
        final List<List<String>> edges = new ArrayList<>();
        for (DeptDTO child : depts) {
            if (!subtree.contains(child.getDeptNo())) continue;
            String p = child.getParentDeptNo();
            if (p == null || !subtree.contains(p)) continue;

            EmpNodeDTO parentRep = repByDept.get(p);
            EmpNodeDTO childRep  = repByDept.get(child.getDeptNo());
            if (parentRep != null && childRep != null) {
                edges.add(Arrays.asList("E" + parentRep.getEmpNo(), "E" + childRep.getEmpNo()));
            }
        }

        byDept.forEach((deptNo, list) -> {
            EmpNodeDTO rep = repByDept.get(deptNo);
            if (rep == null) return;
            String repId = "E" + rep.getEmpNo();
            for (EmpNodeDTO e : list) {
                if (e.getEmpNo().equals(rep.getEmpNo())) continue;
                edges.add(Arrays.asList(repId, "E" + e.getEmpNo()));
            }
        });

        Map<String, Object> out = new LinkedHashMap<>();
        out.put("ok", true);
        out.put("root", rootId);
        out.put("edges", edges);
        out.put("nodes", nodes);
        return out;
    }

    // 주어진 루트 부서로부터 하위 모든 부서 포함한 집합 반환 
    private Set<String> collectSubtreeDeptNos(List<DeptDTO> depts, String root) {
        Map<String, List<String>> children = new HashMap<>();
        for (DeptDTO d : depts) {
            String p = d.getParentDeptNo();
            if (p == null) continue;
            children.computeIfAbsent(p, k -> new ArrayList<>()).add(d.getDeptNo());
        }
        Set<String> out = new LinkedHashSet<>();
        Deque<String> q = new ArrayDeque<>();
        out.add(root);
        q.add(root);
        while (!q.isEmpty()) {
            String cur = q.poll();
            List<String> ch = children.getOrDefault(cur, Collections.emptyList());
            for (String c : ch) {
                if (out.add(c)) q.add(c);
            }
        }
        return out;
    }
}
