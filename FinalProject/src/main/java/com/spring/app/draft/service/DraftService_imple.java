package com.spring.app.draft.service;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.spring.app.common.FileManager;
import com.spring.app.draft.domain.ApprovalLineDTO;
import com.spring.app.draft.domain.DraftDTO;
import com.spring.app.draft.domain.ExpenseDTO;
import com.spring.app.draft.domain.LeaveDTO;
import com.spring.app.draft.domain.ProposalDTO;
import com.spring.app.draft.model.DraftDAO;

import lombok.RequiredArgsConstructor;


@Service
@RequiredArgsConstructor
public class DraftService_imple implements DraftService {
	
	private final DraftDAO Ddao;
	private final FileManager fileManager;
	// 결제목록 가져오기
	@Override
	public List<DraftDTO>getdraftList(Map<String, String> map) {
		
		List<DraftDTO> getdraftList = Ddao.getdraftList(map);
	
		return getdraftList;
	}

	@Override
	public int getdraftcount(Map<String, String> map) {
		int getdraftcount = Ddao.getdraftcount(map);
		return getdraftcount;
	}
	
	
	// 결제 상세 가져오기
	@Override
	public Map<String, String>  getdraftdetail(String draft_no) {
		
		Map<String, String> ddto = Ddao.getdraftdetail(draft_no);
		return ddto;
	}
	// 지출결의서리스트 내용 가져오기
	@Override
	public List<ExpenseDTO> getexpenseList(String draft_no) {
		List<ExpenseDTO> expenseList = Ddao.getexpenseList(draft_no);
		return expenseList;
	}
	// 결제라인 가져오기
	@Override
	public List<Map<String, String>> getapprovalLine(String draft_no) {
		
		List<Map<String, String>> approvalLine = Ddao.getapprovalLine(draft_no);
		return approvalLine;
	}
	// 결제건에 파일첨부 가져오기
	@Override
	public List<Map<String, String>> getfileList(String draft_no) {
		
		List<Map<String, String>> getfileList = Ddao.getfileList(draft_no);
		return getfileList;
	}
	
	// 파일 다운로드
	@Override
	public Map<String, String> getfileOne(String draft_file_no) {
		
		Map<String, String> getfileOne = Ddao.getfileOne(draft_file_no);
		
		return getfileOne;
	}
	
	// 휴가신청 가져오기
	@Override
	public LeaveDTO getLeave(String draft_no) {
		LeaveDTO getLeave = Ddao.getLeave(draft_no);
		return getLeave;
	}
	// 휴가 타입 가져오기
	@Override
	public List<Map<String, String>> getleaveType() {
		List<Map<String, String>> getleaveType = Ddao.getleaveType();
		return getleaveType;
	}
	
	// 업무기안 가져오기
	@Override
	public ProposalDTO getproposal(String draft_no) {
		ProposalDTO getproposal = Ddao.getproposal(draft_no);
		return getproposal;
	}


	@Override
	public List<Map<String, String>> quickSearch(String pattern) {
		 	
		return Ddao.quickSearch(pattern);
	}
	
	@Transactional(rollbackFor = Exception.class)
	@Override
	public void insertProposal(DraftDTO draft, ProposalDTO proposal, List<MultipartFile> fileList, String path , List<ApprovalLineDTO> approvalLines) {
		
		Ddao.insertdraft(draft);
		String draft_no = draft.getDraft_no();
		
		proposal.setFk_draft_no(draft_no);
		Ddao.insertProposal(proposal);
		if (approvalLines != null) {
		    for (ApprovalLineDTO line : approvalLines) {
		    	 if (line == null) continue;
		    	 
		    	 String empNo = line.getFk_approval_emp_no();
		         if (empNo == null || empNo.isBlank()) continue;
		         
		    		line.setFk_draft_no(draft_no);
		    		Ddao.insertApprovalLine(line);
		  
		    }
		}
		File baseDir = new File(path);
		 if (!baseDir.exists()) baseDir.mkdirs();
		 File draftDir = new File(baseDir, draft_no);
		 if (!draftDir.exists()) draftDir.mkdirs();
		 
		 
		 int fileCnt = 0;
		 Map<String, Object> fileMap = new HashMap();
		 fileMap.put("draft_no", draft_no);
		
		 if (fileList != null) {
	            for (MultipartFile mf : fileList) {
	                if (mf == null || mf.isEmpty()) continue;
	                
	                try {
	                    byte[] bytes = mf.getBytes();
	                    String origin = mf.getOriginalFilename();
	                    String saveName = fileManager.doFileUpload(bytes, origin, draftDir.getAbsolutePath());
	                    long size = mf.getSize();

	                    fileMap.put("bytes", bytes);
	                    fileMap.put("origin", origin);
	                    fileMap.put("saveName", saveName);
	                    fileMap.put("size", size);
	                    
	                    Ddao.insertfile(fileMap);
	                    fileCnt++;

	                } catch (Exception e) {
	                    throw new RuntimeException("첨부 저장 실패: " + mf.getOriginalFilename(), e);
	                }
	            }
	        }
		 	List<Map<String, String>> getfileList = Ddao.getfileList(draft_no);
			
			if (fileCnt > 0) {
				Ddao.updateattch_Y(draft_no);
			}
		
		
	}

	@Transactional(rollbackFor = Exception.class)
	@Override
	public void insertLeave(DraftDTO draft, LeaveDTO leave, List<MultipartFile> fileList, String path, List<ApprovalLineDTO> approvalLines) {
		
		Ddao.insertdraft(draft);
		String draft_no = draft.getDraft_no();
		
		leave.setFk_draft_no(draft_no);
		Ddao.insertLeave(leave);
		if (approvalLines != null) {
		    for (ApprovalLineDTO line : approvalLines) {
		    	 if (line == null) continue;
		    	 
		    	 String empNo = line.getFk_approval_emp_no();
		         if (empNo == null || empNo.isBlank()) continue;
		         
		    		line.setFk_draft_no(draft_no);
		    		Ddao.insertApprovalLine(line);
		  
		    }
		}
		File baseDir = new File(path);
		 if (!baseDir.exists()) baseDir.mkdirs();
		 File draftDir = new File(baseDir, draft_no);
		 if (!draftDir.exists()) draftDir.mkdirs();
		 
		 
		 int fileCnt = 0;
		 Map<String, Object> fileMap = new HashMap();
		 fileMap.put("draft_no", draft_no);
		
		 if (fileList != null) {
	            for (MultipartFile mf : fileList) {
	                if (mf == null || mf.isEmpty()) continue;
	                
	                try {
	                    byte[] bytes = mf.getBytes();
	                    String origin = mf.getOriginalFilename();
	                    String saveName = fileManager.doFileUpload(bytes, origin, draftDir.getAbsolutePath());
	                    long size = mf.getSize();

	                    fileMap.put("bytes", bytes);
	                    fileMap.put("origin", origin);
	                    fileMap.put("saveName", saveName);
	                    fileMap.put("size", size);
	                    
	                    Ddao.insertfile(fileMap);
	                    fileCnt++;

	                } catch (Exception e) {
	                    throw new RuntimeException("첨부 저장 실패: " + mf.getOriginalFilename(), e);
	                }
	            }
	        }
		 	List<Map<String, String>> getfileList = Ddao.getfileList(draft_no);
			
			if (fileCnt > 0) {
				Ddao.updateattch_Y(draft_no);
			}
	}
	
	@Transactional(rollbackFor = Exception.class)
	@Override
	public void insertExpense(DraftDTO draft, List<ExpenseDTO> expenseList, List<MultipartFile> fileList, String path,
			List<ApprovalLineDTO> approvalLines) {
		
		Ddao.insertdraft(draft);
		String draft_no = draft.getDraft_no();
		
		
		for(ExpenseDTO e :expenseList) {
			e.setFk_draft_no(draft_no);
			
			Ddao.expenseInsert(e);
			
		}
		
		if (approvalLines != null) {
		    for (ApprovalLineDTO line : approvalLines) {
		    	 if (line == null) continue;
		    	 
		    	 String empNo = line.getFk_approval_emp_no();
		         if (empNo == null || empNo.isBlank()) continue;
		         
		    		line.setFk_draft_no(draft_no);
		    		Ddao.insertApprovalLine(line);
		  
		    }
		}
		File baseDir = new File(path);
		 if (!baseDir.exists()) baseDir.mkdirs();
		 File draftDir = new File(baseDir, draft_no);
		 if (!draftDir.exists()) draftDir.mkdirs();
		 
		 
		 int fileCnt = 0;
		 Map<String, Object> fileMap = new HashMap();
		 fileMap.put("draft_no", draft_no);
		
		 if (fileList != null) {
	            for (MultipartFile mf : fileList) {
	                if (mf == null || mf.isEmpty()) continue;
	                
	                try {
	                    byte[] bytes = mf.getBytes();
	                    String origin = mf.getOriginalFilename();
	                    String saveName = fileManager.doFileUpload(bytes, origin, draftDir.getAbsolutePath());
	                    long size = mf.getSize();

	                    fileMap.put("bytes", bytes);
	                    fileMap.put("origin", origin);
	                    fileMap.put("saveName", saveName);
	                    fileMap.put("size", size);
	                    
	                    Ddao.insertfile(fileMap);
	                    fileCnt++;

	                } catch (Exception e) {
	                    throw new RuntimeException("첨부 저장 실패: " + mf.getOriginalFilename(), e);
	                }
	            }
	        }
		 	List<Map<String, String>> getfileList = Ddao.getfileList(draft_no);
			
			if (fileCnt > 0) {
				Ddao.updateattch_Y(draft_no);
			}
		
	}
	
	@Transactional(rollbackFor = Exception.class)
	@Override
	public void updateExpense(DraftDTO draft, List<ExpenseDTO> expenseList, String draft_no,
							  List<MultipartFile> fileList, String path, List<String> del_draft_file_no) {
		
		Ddao.draftupdate(draft);
		Map<String, String> draft_map = new HashMap<>();
		
		if("반려".equals(draft.getApproval_status())) {
			draft_map.put("approval_status", "대기");
			draft_map.put("draft_no", draft.getDraft_no());
			
			String cntReject = String.valueOf(Ddao.getapproveReject(draft_map));
			
			draft_map.put("cntReject",cntReject);
			
			Ddao.approveReset(draft_map);
			
			Ddao.draftStatusUpdate(draft_map);
		}
		
		List<String> DB_expense_no = Ddao.selectExpense_no(draft_no);
		Set<String> form_expens_no = new HashSet<>();
		
		
		String exNo ;
		if (expenseList != null && !expenseList.isEmpty()) {
			for(ExpenseDTO e :expenseList) {
				e.setFk_draft_no(draft_no);
				exNo = e.getExpense_no() ;
				
				if (exNo == null) { 
					//System.out.println(" INSERT: " + e);
					Ddao.expenseInsert(e);
				}
				else {
					//System.out.println(" UPDATE: " + e);
		            Ddao.expenseUpdate(e);
		            form_expens_no.add(exNo);
				}
			}
			List<String> toDelete = new ArrayList<>();
			for (String no : DB_expense_no) {
				 if (!form_expens_no.contains(no)) {
				        toDelete.add(no);
				 }
			}
			
			if (!toDelete.isEmpty()) {
				 //System.out.println(" DELETE: " + toDelete);
				 Ddao.expenseDelete(toDelete);
			}
		}
		
		 File baseDir = new File(path);
		 if (!baseDir.exists()) baseDir.mkdirs();
		 File draftDir = new File(baseDir, draft_no);
		 if (!draftDir.exists()) draftDir.mkdirs();
		 
		 
		 int fileCnt = 0;
		 Map<String, Object> fileMap = new HashMap();
		 fileMap.put("draft_no", draft_no);
		
		 if (fileList != null) {
	            for (MultipartFile mf : fileList) {
	                if (mf == null || mf.isEmpty()) continue;
	                
	                try {
	                    byte[] bytes = mf.getBytes();
	                    String origin = mf.getOriginalFilename();
	                    String saveName = fileManager.doFileUpload(bytes, origin, draftDir.getAbsolutePath());
	                    long size = mf.getSize();

	                    fileMap.put("bytes", bytes);
	                    fileMap.put("origin", origin);
	                    fileMap.put("saveName", saveName);
	                    fileMap.put("size", size);
	                    
	                    Ddao.insertfile(fileMap);
	                    fileCnt++;

	                } catch (Exception e) {
	                    throw new RuntimeException("첨부 저장 실패: " + mf.getOriginalFilename(), e);
	                }
	            }
	        }
		 	List<Map<String, String>> getfileList = Ddao.getfileList(draft_no);
			
			if (getfileList != null || !getfileList.isEmpty()) {
				Ddao.updateattch_Y(draft_no);
			}
			
			if(del_draft_file_no == null || del_draft_file_no.isEmpty()) {
				return;
			}
			
			List<String> del_file_name = Ddao.getdel_fileList(del_draft_file_no , draft_no);
			
			Ddao.file_delete(draft_no, del_draft_file_no);
			
			getfileList = Ddao.getfileList(draft_no);
			
			if (getfileList == null || getfileList.isEmpty()) {
				Ddao.updateattch_N(draft_no);
			}
			
			for(String name : del_file_name) {
				try {
					
				    fileManager.doFileDelete(name, path + "/" +draft_no);
					
				} catch (Exception e) {
					e.printStackTrace();
				}
			}	
	}
	
	@Transactional(rollbackFor = Exception.class)
	@Override
	public void updateLeave(DraftDTO draft, LeaveDTO leave, List<MultipartFile> fileList, String path, String draft_no,
							List<String> del_draft_file_no) {
		
		Ddao.draftupdate(draft);
		Map<String, String> draft_map = new HashMap<>();
		
		if("반려".equals(draft.getApproval_status())) {
			draft_map.put("approval_status", "대기");
			draft_map.put("draft_no", draft.getDraft_no());
			
			String cntReject = String.valueOf(Ddao.getapproveReject(draft_map));
			
			draft_map.put("cntReject",cntReject);
			
			Ddao.approveReset(draft_map);
			
			Ddao.draftStatusUpdate(draft_map);
		}
		
		Ddao.leaveUpdate(leave);
		
		File baseDir = new File(path);
		 if (!baseDir.exists()) baseDir.mkdirs();
		 File draftDir = new File(baseDir, draft_no);
		 if (!draftDir.exists()) draftDir.mkdirs();
		 
		 
		 int fileCnt = 0;
		 Map<String, Object> fileMap = new HashMap();
		 fileMap.put("draft_no", draft_no);
		
		 if (fileList != null) {
	            for (MultipartFile mf : fileList) {
	                if (mf == null || mf.isEmpty()) continue;
	                
	                try {
	                    byte[] bytes = mf.getBytes();
	                    String origin = mf.getOriginalFilename();
	                    String saveName = fileManager.doFileUpload(bytes, origin, draftDir.getAbsolutePath());
	                    long size = mf.getSize();

	                    fileMap.put("bytes", bytes);
	                    fileMap.put("origin", origin);
	                    fileMap.put("saveName", saveName);
	                    fileMap.put("size", size);
	                    
	                    Ddao.insertfile(fileMap);
	                    fileCnt++;

	                } catch (Exception e) {
	                    throw new RuntimeException("첨부 저장 실패: " + mf.getOriginalFilename(), e);
	                }
	            }
	        }
		 	List<Map<String, String>> getfileList = Ddao.getfileList(draft_no);
			
			if (getfileList != null || !getfileList.isEmpty()) {
				Ddao.updateattch_Y(draft_no);
			}
			
			if(del_draft_file_no == null || del_draft_file_no.isEmpty()) {
				return;
			}
			
			List<String> del_file_name = Ddao.getdel_fileList(del_draft_file_no , draft_no);
			
			Ddao.file_delete(draft_no, del_draft_file_no);
			
			getfileList = Ddao.getfileList(draft_no);
			
			if (getfileList == null || getfileList.isEmpty()) {
				Ddao.updateattch_N(draft_no);
			}
			
			for(String name : del_file_name) {
				try {
					
				    fileManager.doFileDelete(name, path + "/" +draft_no);
					
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
	}
	
	@Transactional(rollbackFor = Exception.class)
	@Override
	public void updateProposal(DraftDTO draft, ProposalDTO proposal, List<MultipartFile> fileList, String path,
								String draft_no, List<String> del_draft_file_no) {
		
		Ddao.draftupdate(draft);
		
		Map<String, String> draft_map = new HashMap<>();
		
		if("반려".equals(draft.getApproval_status())) {
			draft_map.put("approval_status", "대기");
			draft_map.put("draft_no", draft.getDraft_no());
			
			String cntReject = String.valueOf(Ddao.getapproveReject(draft_map));
			
			draft_map.put("cntReject",cntReject);
			
			Ddao.approveReset(draft_map);
			
			Ddao.draftStatusUpdate(draft_map);
		}
		
		
		Ddao.proposalUpdate(proposal);
		
		 File baseDir = new File(path);
		 if (!baseDir.exists()) baseDir.mkdirs();
		 File draftDir = new File(baseDir, draft_no);
		 if (!draftDir.exists()) draftDir.mkdirs();
		 
		 
		 int fileCnt = 0;
		 Map<String, Object> fileMap = new HashMap();
		 fileMap.put("draft_no", draft_no);
		
		 if (fileList != null) {
	            for (MultipartFile mf : fileList) {
	                if (mf == null || mf.isEmpty()) continue;
	                
	                try {
	                    byte[] bytes = mf.getBytes();
	                    String origin = mf.getOriginalFilename();
	                    String saveName = fileManager.doFileUpload(bytes, origin, draftDir.getAbsolutePath());
	                    long size = mf.getSize();

	                    fileMap.put("bytes", bytes);
	                    fileMap.put("origin", origin);
	                    fileMap.put("saveName", saveName);
	                    fileMap.put("size", size);
	                    
	                    Ddao.insertfile(fileMap);
	                    fileCnt++;

	                } catch (Exception e) {
	                    throw new RuntimeException("첨부 저장 실패: " + mf.getOriginalFilename(), e);
	                }
	            }
	        }
		 	List<Map<String, String>> getfileList = Ddao.getfileList(draft_no);
			
			if (getfileList != null || !getfileList.isEmpty()) {
				Ddao.updateattch_Y(draft_no);
			}

			if(del_draft_file_no == null || del_draft_file_no.isEmpty()) {
				return;
			}
			
			List<String> del_file_name = Ddao.getdel_fileList(del_draft_file_no , draft_no);
			
			Ddao.file_delete(draft_no, del_draft_file_no);
			
			getfileList = Ddao.getfileList(draft_no);
			
			if (getfileList == null || getfileList.isEmpty()) {
				Ddao.updateattch_N(draft_no);
			}
			
			for(String name : del_file_name) {
				try {
					
				    fileManager.doFileDelete(name, path + "/" +draft_no);
					
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
	}

	@Override
	public int getapprovecount(Map<String, String> map) {
			
		int getapprovecount = Ddao.getapprovecount(map);
		
		return getapprovecount;
	}

	@Override
	public List<DraftDTO> getapproveList(Map<String, String> map) {
		
		List<DraftDTO> getapproveList = Ddao.getapproveList(map);
		return getapproveList;
	}

	@Override
	public int getNextOrder(String draft_no) {
		int getNextOrder = Ddao.getNextOrder(draft_no);
		return getNextOrder;
	}
	
	@Transactional(rollbackFor = Exception.class)
	@Override
	public void updateApproval(Map<String, String> apprmap) {
		
		Ddao.approveLineUpdate(apprmap);
		
		Ddao.approveInsert(apprmap);
		
		if("반려".equals(apprmap.get("approval_status"))) {
			Ddao.draftStatusUpdate(apprmap);
			
			return;
		}
		
		int approve_lineCNT = Ddao.countLine(apprmap);	
		int approveCNT = Ddao.countApprove(apprmap);
		
		if(approve_lineCNT == approveCNT) {
			Ddao.draftStatusUpdate(apprmap);
		}
		
		
	}

	@Override
	public List<Map<String, String>> deptquickSearch(String pattern) {
		
		return Ddao.deptquickSearch(pattern);
	}
	


}