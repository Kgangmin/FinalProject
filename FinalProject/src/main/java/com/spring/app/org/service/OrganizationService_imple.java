// src/main/java/com/spring/app/org/service/OrganizationService_imple.java
package com.spring.app.org.service;

import java.util.*;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.spring.app.org.domain.DeptDTO;
import com.spring.app.org.domain.DeptHeadDTO;
import com.spring.app.org.model.OrganizationDAO;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class OrganizationService_imple implements OrganizationService {

    private final OrganizationDAO organizationDAO;

    @Override
    public Map<String, Object> buildOrgChart() {

        // 1) 활성 부서
        List<DeptDTO> depts = organizationDAO.selectActiveDepartments(); // dept_no, dept_name, parent_dept_no

        // 2) 각 부서의 최고직급 재직자(부서장) + 직책들(콤마 구분 문자열)
        List<DeptHeadDTO> heads = organizationDAO.selectDeptHeads(); // fk_dept_no, emp_name, rank_name, positions

        // 부서번호 -> HeadDTO 맵
        Map<String, DeptHeadDTO> headByDept = heads.stream()
                .collect(Collectors.toMap(DeptHeadDTO::getDeptNo, x -> x, (a, b) -> a));

        // 3) root 부서(= parent_dept_no IS NULL) 찾기 (여러개면 첫번째 사용)
        String root = depts.stream()
                .filter(d -> d.getParentDeptNo() == null)
                .map(DeptDTO::getDeptNo)
                .findFirst()
                .orElse(null);

        // 4) edges (from, to) = (parent -> child)
        List<List<String>> edges = new ArrayList<>();
        for (DeptDTO d : depts) {
            if (d.getParentDeptNo() != null) {
                edges.add(Arrays.asList(d.getParentDeptNo(), d.getDeptNo()));
            }
        }

        // 5) nodes
        // Highcharts organization series의 nodes[]에는 최소 id/name/title 정도만 주면 됩니다.
        // name  : 부서명
        // title : "사원명 직급" (없으면 "관리자 미지정")
        // custom.positions : "직책1, 직책2" (없으면 빈 문자열)
        List<Map<String, Object>> nodes = new ArrayList<>();
        for (DeptDTO d : depts) {
            DeptHeadDTO h = headByDept.get(d.getDeptNo());
            String title;
            String positions;
            if (h == null) {
                title = "관리자 미지정";
                positions = "";
            } else {
                title = h.getEmpName() + " " + h.getRankName();
                positions = h.getPositions() == null ? "" : h.getPositions();
            }

            Map<String, Object> node = new LinkedHashMap<>();
            node.put("id", d.getDeptNo());
            node.put("name", d.getDeptName());
            node.put("title", title);
            Map<String, Object> custom = new HashMap<>();
            custom.put("positions", positions);
            node.put("custom", custom);
            nodes.add(node);
        }

        Map<String, Object> out = new LinkedHashMap<>();
        out.put("ok", true);
        out.put("root", root);      // 필요시 사용
        out.put("edges", edges);    // [ ["10000","10100"], ... ]
        out.put("nodes", nodes);    // [{id,name,title,custom:{positions}}...]
        return out;
    }
}
