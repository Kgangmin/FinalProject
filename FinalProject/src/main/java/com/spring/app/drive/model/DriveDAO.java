package com.spring.app.drive.model;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.spring.app.drive.domain.DriveDTO;
import com.spring.app.drive.domain.DriveUploadDTO;

@Mapper
public interface DriveDAO {

    int countFiles(
        @Param("categoryNo") String categoryNo,
        @Param("scope") String scope,
        @Param("empNo") String empNo,
        @Param("keyword") String keyword
    );

    List<DriveDTO> selectFiles(
        @Param("categoryNo") String categoryNo,
        @Param("scope") String scope,
        @Param("empNo") String empNo,
        @Param("keyword") String keyword,
        @Param("startRow") int startRow,
        @Param("endRow") int endRow
    );

    Long sumFilesize(
        @Param("categoryNo") String categoryNo,
        @Param("scope") String scope,
        @Param("empNo") String empNo
    );

    int insertBoard(DriveUploadDTO dto);

    int insertBoardFile(DriveUploadDTO dto);

    DriveDTO selectFileByFileNo(
        @Param("boardFileNo") String boardFileNo,
        @Param("scope") String scope,
        @Param("empNo") String empNo
    );

    List<DriveDTO> selectFilesByFileNos(
        @Param("ids") List<String> ids,
        @Param("scope") String scope,
        @Param("empNo") String empNo
    );

    int deleteFilesByFileNos(
        @Param("ids") List<String> ids,
        @Param("scope") String scope,
        @Param("empNo") String empNo
    );

    int deleteBoardsByBoardNos(
        @Param("boardNos") List<String> boardNos,
        @Param("scope") String scope,
        @Param("empNo") String empNo
    );
}
