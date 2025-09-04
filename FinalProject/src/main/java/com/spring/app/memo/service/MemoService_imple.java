package com.spring.app.memo.service;

import java.util.*;
import org.springframework.stereotype.Service;
import lombok.RequiredArgsConstructor;
import com.spring.app.memo.domain.MemoPadDTO;
import com.spring.app.memo.model.MemoDAO;

@Service
@RequiredArgsConstructor
public class MemoService_imple implements MemoService {

    private final MemoDAO memoDAO;

    @Override
    public List<MemoPadDTO> listMine(String empNo) {
        if (empNo == null || empNo.isEmpty()) return Collections.emptyList();
        return memoDAO.findByEmpNo(empNo);
    }

    @Override
    public MemoPadDTO createPad(String empNo, String title) {
        MemoPadDTO dto = new MemoPadDTO();
        dto.setFkEmpNo(empNo);
        dto.setTitle((title == null || title.isEmpty()) ? "메모" : title);
        // sort_order = 현재 보유 수의 맨 뒤로
        List<MemoPadDTO> now = memoDAO.findByEmpNo(empNo);
        dto.setSortOrder(now.size());
        dto.setContent("");
        memoDAO.insert(dto);
        return dto;
    }

    @Override
    public void savePad(String empNo, Long padId, String title, String content) {
        memoDAO.updateTitleContent(padId, empNo, title, content);
    }

    @Override
    public void reorder(String empNo, List<Long> padIdsInOrder) {
        if (padIdsInOrder == null) return;
        for (int i=0; i<padIdsInOrder.size(); i++) {
            memoDAO.updateOrder(empNo, padIdsInOrder.get(i), i);
        }
    }

    @Override
    public void remove(String empNo, Long padId) {
        memoDAO.delete(padId, empNo);
        // 필요 시 sort_order 재정렬은 클라이언트가 /order 호출로 맞추도록 단순화
    }
}
