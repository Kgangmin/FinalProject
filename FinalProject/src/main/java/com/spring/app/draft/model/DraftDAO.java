package com.spring.app.draft.model;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Repository;

import com.spring.app.draft.domain.DraftDTO;


@Mapper
public interface DraftDAO {

	List<DraftDTO> getdraftList(Map<String, String> map);

	int getdraftcount(Map<String, String> map);

	
	

}
