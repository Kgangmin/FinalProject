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

        // 1) 재직자가 1명 이상 있는 '활성' 부서만
        final List<DeptDTO> depts = organizationDAO.selectDepartmentsHavingEmployees();
        final Map<String, DeptDTO> deptMap = depts.stream()
                .collect(Collectors.toMap(DeptDTO::getDeptNo, d -> d, (a,b)->a, LinkedHashMap::new));
        final Set<String> deptSet = deptMap.keySet();
        
        // 최상위 부서 목록
        final List<DeptDTO> topDepts = depts.stream()
                .filter(d -> d.getParentDeptNo() == null)
                .collect(Collectors.toList());

        // 2) 각 부서의 모든 재직 사원(+rankLevel/직책)
        final List<EmpNodeDTO> emps = organizationDAO.selectDepartmentEmployeesWithPositions()
                .stream()
                .filter(e -> e.getDeptNo() != null && deptSet.contains(e.getDeptNo()))
                .collect(Collectors.toList());

        // 3) 부서별 그룹 & 대표자(최고직급) 선정
        final Map<String, List<EmpNodeDTO>> byDept = emps.stream()
                .collect(Collectors.groupingBy(EmpNodeDTO::getDeptNo, LinkedHashMap::new, Collectors.toList()));

        final Map<String, EmpNodeDTO> repByDept = new LinkedHashMap<>();
        byDept.forEach((deptNo, list) -> {
            list.sort(Comparator
                .comparing((EmpNodeDTO x) -> Optional.ofNullable(x.getRankLevel()).orElse(Integer.MAX_VALUE))
                .thenComparing(EmpNodeDTO::getEmpNo));
            repByDept.put(deptNo, list.get(0));
        });

        // 4) 노드: 사원 노드만 생성 (부서명/사원명/직책 라벨)
        final List<Map<String, Object>> nodes = new ArrayList<>();
        for (EmpNodeDTO e : emps) {
            DeptDTO d = deptMap.get(e.getDeptNo());
            String deptName = (d != null ? d.getDeptName() : "");

            Map<String, Object> node = new LinkedHashMap<>();
            node.put("id", "E" + e.getEmpNo());
            node.put("name", deptName); // 부서명
            node.put("title", e.getEmpName() + " " + (e.getRankName() == null ? "" : e.getRankName())); // 사원명 직급
            node.put("custom", Map.of("positions", Optional.ofNullable(e.getPositions()).orElse("")));   // 직책들
            nodes.add(node);
        }

        for (EmpNodeDTO e : emps) {
            DeptDTO d = deptMap.get(e.getDeptNo());
            String deptName = (d != null ? d.getDeptName() : "");

            Map<String, Object> node = new LinkedHashMap<>();
            node.put("id", "E" + e.getEmpNo());
            // 라벨 포맷: name=부서명, title="사원명 직급", custom.positions=직책 문자열
            node.put("name", deptName);
            node.put("title", e.getEmpName() + " " + (e.getRankName() == null ? "" : e.getRankName()));
            node.put("custom", Map.of("positions", Optional.ofNullable(e.getPositions()).orElse("")));
            nodes.add(node);
        }
        
        String rootId = null;
        
        // (선택) 최상위 부서 중 이름이 '회사전체'인 부서가 있으면 그 대표자를 루트로 사용
        Optional<DeptDTO> companyTop = topDepts.stream()
                .filter(d -> "회사전체".equals(d.getDeptName()))
                .findFirst();
        
        if (companyTop.isPresent()) {
            EmpNodeDTO rep = repByDept.get(companyTop.get().getDeptNo());
            if (rep != null) rootId = "E" + rep.getEmpNo();
        } else if (topDepts.size() > 1) {
            // 최상위 부서가 여러 개면 가상 ROOT 추가
            rootId = "ROOT";
            nodes.add(Map.of("id", rootId, "name", "회사전체"));
        }
        // 최상위 부서가 1개면 rootId는 아래 edges에서 대표자 기준으로 설정됨

     // 5) 엣지
        final List<List<String>> edges = new ArrayList<>();

        // 5-1) ROOT → 최상위 부서 대표자(들)
        if ("ROOT".equals(rootId)) {
            for (DeptDTO td : topDepts) {
                EmpNodeDTO rep = repByDept.get(td.getDeptNo());
                if (rep != null) edges.add(Arrays.asList(rootId, "E" + rep.getEmpNo()));
            }
        } else if (rootId == null && topDepts.size() == 1) {
            // 최상위 부서가 1개이고 '회사전체' 이름도 아니면 그 대표자를 루트로 사용
            EmpNodeDTO rep = repByDept.get(topDepts.get(0).getDeptNo());
            if (rep != null) rootId = "E" + rep.getEmpNo();
        }

        // 5-2) (부모부서 대표자) → (자식부서 대표자)
        for (DeptDTO child : depts) {
            String p = child.getParentDeptNo();
            if (p == null) continue;
            EmpNodeDTO parentRep = repByDept.get(p);
            EmpNodeDTO childRep  = repByDept.get(child.getDeptNo());
            if (parentRep != null && childRep != null) {
                edges.add(Arrays.asList("E" + parentRep.getEmpNo(), "E" + childRep.getEmpNo()));
            }
        }

        // 5-3) (부서 대표자) → (해당 부서의 나머지 사원)
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
}
