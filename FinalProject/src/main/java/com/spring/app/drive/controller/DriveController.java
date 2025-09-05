// DriveController.java
package com.spring.app.drive.controller;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import com.spring.app.drive.domain.DriveDTO;
import com.spring.app.drive.domain.DrivePageDTO;
import com.spring.app.drive.service.DriveService;
import com.spring.app.emp.domain.EmpDTO;

import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/drive")
@RequiredArgsConstructor
public class DriveController {

    private final DriveService driveService;

    // =========================
    // 세션 헬퍼
    // =========================
    private String sesEmp(HttpSession s) {
        Object o = s.getAttribute("loginuser");
        if (o instanceof EmpDTO) {
            EmpDTO u = (EmpDTO) o;
            if (u.getEmp_no() != null && !u.getEmp_no().isBlank()) return u.getEmp_no();
        }
        Object o2 = s.getAttribute("loginEmp");
        if (o2 != null) {
            try {
                var m = o2.getClass().getMethod("getEmpNo");
                Object v = m.invoke(o2);
                if (v != null) return String.valueOf(v);
            } catch (Exception ignore) {}
        }
        return null;
    }

    private String sesDept(HttpSession s) {
        Object o = s.getAttribute("loginuser");
        if (o instanceof EmpDTO) {
            EmpDTO u = (EmpDTO) o;
            if (u.getFk_dept_no() != null && !u.getFk_dept_no().isBlank()) return u.getFk_dept_no();
        }
        Object o2 = s.getAttribute("loginEmp");
        if (o2 != null) {
            try {
                var m = o2.getClass().getMethod("getFkDeptNo");
                Object v = m.invoke(o2);
                if (v != null) return String.valueOf(v);
            } catch (Exception ignore) {}
        }
        return null;
    }

    private String mapScopeToPath(String scope) {
        if ("EMP".equalsIgnoreCase(scope))  return "me";
        if ("DEPT".equalsIgnoreCase(scope)) return "dept";
        return "corp"; // default CORP
    }

    // =========================
    // 공통 리스트
    // =========================
    private String listCommon(String scope, DrivePageDTO p, HttpSession session, Model model) {
        p.setScope(scope);
        p.setEmpNo(sesEmp(session));
        p.setDeptNo(sesDept(session));
        if (p.getPage() == null) p.setPage("1");
        if (p.getSize() == null) p.setSize("10");
        if (p.getBlockSize() == null) p.setBlockSize("10");

        List<DriveDTO> files = driveService.list(p);
        Map<String, Long> cap = driveService.capacity(scope, p.getEmpNo(), p.getDeptNo());

        model.addAttribute("files", files);
        model.addAttribute("page", p);
        model.addAttribute("cap", cap);
        model.addAttribute("scope", scope);
        return "drive/driveList";
    }

    /** 기본 진입 → 전사자료실 */
    @GetMapping({"", "/", "/list"})
    public String list(@RequestParam(name="scope", value = "scope", required = false) String scope,
                       DrivePageDTO p, HttpSession session, Model model) {

        String s = (scope == null ? "CORP" : scope.trim().toUpperCase());
        switch (s) {
            case "DEPT":
                if (sesDept(session) == null || sesDept(session).isBlank()) s = "CORP";
                break;
            case "EMP":
                if (sesEmp(session) == null || sesEmp(session).isBlank()) s = "CORP";
                break;
            case "CORP":
            default:
                s = "CORP";
        }
        return listCommon(s, p, session, model);
    }

    @GetMapping("/corp")
    public String corp(DrivePageDTO p, HttpSession s, Model m) {
        return listCommon("CORP", p, s, m);
    }

    @GetMapping("/dept")
    public String dept(DrivePageDTO p, HttpSession s, Model m) {
        return listCommon("DEPT", p, s, m);
    }

    @GetMapping("/me")
    public String me(DrivePageDTO p, HttpSession s, Model m) {
        return listCommon("EMP", p, s, m);
    }

    // =========================
    // 업로드
    // =========================
    @PostMapping("/upload")
    public String upload(@RequestParam(name="file", value="file") MultipartFile file,
                         @RequestParam(name="scope", value="scope") String scope,
                         HttpSession session) throws Exception {

        String empNo  = sesEmp(session);
        String deptNo = sesDept(session);

        if (empNo == null || empNo.isBlank()) {
            throw new IllegalStateException("세션 만료 또는 로그인 정보(empNo) 없음. 다시 로그인 해주세요.");
        }

        scope = (scope == null ? "CORP" : scope.trim().toUpperCase());
        if ("DEPT".equals(scope) && (deptNo == null || deptNo.isBlank())) {
            throw new IllegalStateException("부서 자료실 업로드에는 부서번호가 필요합니다.");
        }

        System.out.println("[CTRL] scope=" + scope + ", empNo=" + empNo + ", deptNo=" + deptNo);
        driveService.upload(file, scope, empNo, deptNo);

        return "redirect:/drive/" + mapScopeToPath(scope);
    }

    // =========================
    // 단일 다운로드 (권한 인자 포함 오버로드 호출)
    // =========================
    @GetMapping("/download")
    public void download(@RequestParam(name="id", value="id") String boardFileNo,
                         @RequestParam(name="scope", value = "scope", required = false) String scope,
                         HttpSession session,
                         HttpServletResponse resp) throws Exception {

        String empNo  = sesEmp(session);
        String deptNo = sesDept(session);
        String s = (scope == null || scope.isBlank()) ? "CORP" : scope.trim().toUpperCase();

        driveService.downloadSingle(boardFileNo, s, empNo, deptNo, resp);
    }

    // =========================
    // 다건 다운로드 (ids=a,b,c + scope)
    // =========================
    @PostMapping("/download")
    public void downloadMulti(@RequestParam(name="ids", value="ids") String ids,
                              @RequestParam(name="scope", value = "scope", required = false) String scope,
                              HttpSession session,
                              HttpServletResponse resp) throws Exception {

        List<String> list = Arrays.stream(ids.split(","))
                                  .map(String::trim)
                                  .filter(s -> !s.isEmpty())
                                  .collect(Collectors.toList());

        String empNo  = sesEmp(session);
        String deptNo = sesDept(session);
        String s = (scope == null || scope.isBlank()) ? "CORP" : scope.trim().toUpperCase();

        driveService.downloadMulti(list, s, empNo, deptNo, resp);
    }

    // =========================
    // 삭제
    // =========================
    @PostMapping("/delete")
    public String delete(@RequestParam(name="ids", value="ids") String ids,
                         @RequestParam(name="scope", value="scope") String scope,
                         HttpSession session) {

        List<String> list = Arrays.stream(ids.split(","))
                                  .map(String::trim)
                                  .filter(s -> !s.isEmpty())
                                  .collect(Collectors.toList());

        driveService.deleteByIds(list, scope, sesEmp(session), sesDept(session));
        return "redirect:/drive/" + mapScopeToPath(scope);
    }
}
