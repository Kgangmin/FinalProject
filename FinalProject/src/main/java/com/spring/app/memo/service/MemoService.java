package com.spring.app.memo.service;

import java.util.List;
import com.spring.app.memo.domain.MemoPadDTO;

public interface MemoService {
    List<MemoPadDTO> listMine(String empNo);
    MemoPadDTO createPad(String empNo, String title);
    void savePad(String empNo, Long padId, String title, String content);
    void reorder(String empNo, List<Long> padIdsInOrder);
    void remove(String empNo, Long padId);
}
