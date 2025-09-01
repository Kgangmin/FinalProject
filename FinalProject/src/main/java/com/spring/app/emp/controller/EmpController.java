package com.spring.app.emp.controller;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import com.spring.app.common.FileManager;
import com.spring.app.emp.domain.EmpDTO;
import com.spring.app.emp.service.EmpService;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor	//	@RequiredArgsConstructor는 Lombok 라이브러리에서 제공하는 애너테이션으로, final 필드 또는 @NonNull이 붙은 필드에 대해 생성자를 자동으로 생성해준다.
@RequestMapping(value="/emp/")
public class EmpController
{
	private final EmpService empservice;
	private final FileManager fileManager;
	private final PasswordEncoder passwordEncoder;
	
	@GetMapping(value="emp_layout")
	public String emp_layout(@RequestParam(value="page", required=false) String page, Model model)
	{
		if (page == null || page.isEmpty())
		{
            page = "emp_info"; // 기본 페이지
        }
        model.addAttribute("subPage", page); 
        return "emp/emp_layout"; // emp_layout.jsp
	}
	
	@ResponseBody
	@PostMapping("/updateEmpInfo")
	public Map<String, String> updateEmpInfo(@RequestBody EmpDTO empDto, @AuthenticationPrincipal UserDetails empDetails)
	{
		Map<String, String> map = new HashMap<>();
		
	//	HttpSession session = request.getSession();
	//	EmpDTO loginuser = (EmpDTO) session.getAttribute("loginuser");
		
		String empNo = empDetails.getUsername();
		empDto.setEmp_no(empNo);
		
		try
		{
			int n = empservice.updateEmpInfo(empDto);
			
			if(n == 1)
			{
				map.put("message", "사원정보가 성공적으로 업데이트 되었습니다.");
				map.put("status", "success");
			}
			else
			{
				map.put("message", "사원정보  업데이트에 실패했습니다.");
				map.put("status", "fail");
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
			map.put("message", "오류 : 사원정보 업데이트 중 예외 발생");
			map.put("status", "error");
		}
		
		return map;
	}
	
	@ResponseBody
	@PostMapping("updateEmpInfoWithFile")
	public Map<String, String> updateEmpInfoWithFile(EmpDTO empDto
													,@AuthenticationPrincipal UserDetails empDetails
													,HttpServletRequest request
													,@RequestParam(value="attach", required=false) MultipartFile attach)
	{
		Map<String, String> map = new HashMap<>();
		
		String empNo = empDetails.getUsername();
		empDto.setEmp_no(empNo);
		
		HttpSession session = request.getSession();
		
		String oldEmpSaveFilename = empservice.getEmpProfileFileName(empDto.getEmp_no());
		final String default_profile_image = "default_profile.jpg";	//	기본 이미지 파일명 고정
		
		if(attach != null && !attach.isEmpty())
		{//	사용자가 파일을 선택한 경우(프로필 사진 변경 수요가 있는 경우)
			String root = session.getServletContext().getRealPath("/");
			String path = root + "resources" + File.separator + "images" + File.separator + "emp_profile";
			
			try
			{
				String newFileName = fileManager.doFileUpload(attach.getBytes(), attach.getOriginalFilename(), path);
				
				empDto.setEmp_save_filename(newFileName);
                empDto.setEmp_origin_filename(attach.getOriginalFilename());
                empDto.setEmp_filesize(String.valueOf(attach.getSize()));
                
                if(!oldEmpSaveFilename.equals(default_profile_image))
                {//	사원프로필이 기본이미지가 아닌경우(프로필 사진 업데이트 전적이 있는 경우)
                	File oldFile = new File(path + File.separator + oldEmpSaveFilename);
                	if(oldFile.exists())
                	{
                		fileManager.doFileDelete(oldEmpSaveFilename, path);
                	}
                }
			}
			catch(Exception e)
			{
				e.printStackTrace();
				map.put("message", "프로필 사진 파일 업로드 중 오류가 발생하였습니다.");
				map.put("status", "error");
				
				return map;
			}
		}
		
		try
		{
			int n = empservice.updateEmployeeInfoWithFile(empDto);

			if(n == 1)
			{
				map.put("message", "정보 및 프로필 사진이 성공적으로 업데이트되었습니다.");
				map.put("status", "success");
			}
			else
			{
				map.put("message", "정보 및 프로필 사진 업데이트에 실패했습니다.");
				map.put("status", "fail");
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
			map.put("message", "서버 오류: 데이터베이스 업데이트 중 예외 발생.");
			map.put("status", "error");
		}
		
		return map;
	}
	
	//	현재 비밀번호 확인
	@PostMapping("verifyPassword")
	@ResponseBody
    public Map<String,Object> verifyPassword(@RequestBody Map<String,String> body
    										,@AuthenticationPrincipal UserDetails empDetails)
	{
		String curr = body.getOrDefault("currentPassword", "").trim();
		if (empDetails == null || empDetails.getUsername() == null)
		{
            return Map.of("valid", false, "message", "인증 정보가 없습니다. 다시 로그인해 주세요.");
        }
        if (curr.isEmpty())
        {
            return Map.of("valid", false, "message", "현재 비밀번호를 입력하세요.");
        }

        String empNo = empDetails.getUsername();
        String storedHash = empservice.findPasswordHashByEmpNo(empNo);

        boolean ok = (storedHash != null) && passwordEncoder.matches(curr, storedHash);
        return Map.of("valid", ok, "message", ok ? "OK" : "현재 비밀번호가 일치하지 않습니다.");
	}

	//	새 비밀번호 변경
	@PostMapping("changePassword")
	@ResponseBody
	public Map<String,Object> changePassword(@RequestBody Map<String,String> body
											,@AuthenticationPrincipal UserDetails empDetails)
	{
		if (empDetails == null || empDetails.getUsername() == null)
		{
			return Map.of("success", false, "message", "인증 정보가 없습니다. 다시 로그인해 주세요.");
		}

		String newPwd = body.getOrDefault("newPassword", "").trim();
		String empNo = empDetails.getUsername();
		String oldHash = empservice.findPasswordHashByEmpNo(empNo);
		
		if (oldHash != null && passwordEncoder.matches(newPwd, oldHash))
		{
			return Map.of("success", false, "message", "이전 비밀번호와 동일합니다. 다른 비밀번호를 사용하세요.");
		}

		empservice.updatePassword(empNo, passwordEncoder.encode(newPwd));
		return Map.of("success", true, "message", "비밀번호가 변경되었습니다.");
	}

	@GetMapping("emp_list")
    public String emp_attendance(Model model)
	{
        model.addAttribute("subPage", "emp_list");
        return "emp/emp_layout";
    }

    @GetMapping("emp_leave")
    public String emp_leave(Model model)
    {
        model.addAttribute("subPage", "emp_leave");
        return "emp/emp_layout";
    }

    @GetMapping("emp_certificate")
    public String emp_certificate(Model model)
    {
        model.addAttribute("subPage", "emp_certificate");
        return "emp/emp_layout";
    }

}