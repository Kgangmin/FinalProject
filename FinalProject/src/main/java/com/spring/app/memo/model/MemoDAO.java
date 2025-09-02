package com.spring.app.memo.model;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import com.spring.app.memo.domain.MemoPadDTO;

@Mapper
public interface MemoDAO {
    List<MemoPadDTO> findByEmpNo(@Param("empNo") String empNo);
    int insert(MemoPadDTO dto);
    int updateTitleContent(@Param("padId") Long padId, @Param("empNo") String empNo,
                           @Param("title") String title, @Param("content") String content);
    int updateOrder(@Param("empNo") String empNo, @Param("padId") Long padId, @Param("order") int order);
    int delete(@Param("padId") Long padId, @Param("empNo") String empNo);
}
