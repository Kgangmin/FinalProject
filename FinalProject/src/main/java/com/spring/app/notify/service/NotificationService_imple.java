package com.spring.app.notify.service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

import org.springframework.stereotype.Service;

import com.spring.app.notify.domain.NotificationDTO;
import com.spring.app.notify.model.NotificationDAO;
import com.spring.app.notify.domain.source.*;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class NotificationService_imple implements NotificationService {
	
	private final NotificationDAO DAO;
	
	@Override
	public List<NotificationDTO> getNotifications(String empNo, String deptNo, String ctx) {
		List<NotificationDTO> out = new ArrayList<>();

        // 1) 메일
        for (MailRow r : DAO.selectUnreadMails(empNo)) {
        	NotificationDTO n = new NotificationDTO();
            n.setType("MAIL");
            n.setId(r.getEmailNo());
            n.setTitle("새 메일");
            n.setMessage(r.getEmailTitle());
            n.setTime(nullSafe(r.getSentAt()));
            n.setTargetUrl(ctx + "/mail/detail?emailNo=" + r.getEmailNo()); // 필요 시 라우팅 맞게 수정
            out.add(n);
        }

        // 2) 개인 일정 (오늘)
        for (ScheduleRow r : DAO.selectTodayPersonalSchedules(empNo)) {
        	NotificationDTO n = new NotificationDTO();
            n.setType("SCHEDULE");
            n.setId(r.getScheduleNo());
            n.setTitle("오늘 일정");
            n.setMessage(r.getScheduleTitle());
            n.setTime(nullSafe(r.getStartDate()));
            n.setTargetUrl(ctx + "/schedule/scheduleManagement");
            out.add(n);
        }

        // 3) 회사/부서 일정 (오늘, 접근제어 반영)
        for (TaskRow r : DAO.selectTodayTasksForUser(empNo, deptNo)) {
            NotificationDTO n = new NotificationDTO();
            n.setType("TASK");
            n.setId(r.getTaskNo());
            n.setTitle("오늘 일정(회사/부서)");
            n.setMessage(r.getTaskTitle());
            n.setTime(nullSafe(r.getStartDate()));
            n.setTargetUrl(ctx + "/schedule/scheduleManagement");
            out.add(n);
        }

        // 4) 참여 가능 설문
        for (SurveyRow r : DAO.selectAvailableSurveys(empNo, deptNo)) {
        	NotificationDTO n = new NotificationDTO();
            n.setType("SURVEY");
            n.setId(r.getSurveyId());
            n.setTitle("설문 참여 요청");
            n.setMessage("오늘 참여 가능한 설문이 있습니다.");
            n.setTime(nullSafe(r.getStartDate()));
            n.setTargetUrl(ctx + "/survey/detail?sid=" + r.getSurveyId());
            out.add(n);
        }

        // 5) 공지사항 미열람
        for (NoticeRow r : DAO.selectUnreadNotices(empNo)) {
            NotificationDTO n = new NotificationDTO();
            n.setType("NOTICE");
            n.setId(r.getBoardNo());
            n.setTitle("새 공지사항");
            n.setMessage(r.getBoardTitle());
            n.setTime(nullSafe(r.getRegisterDate()));
            n.setTargetUrl(ctx + "/board/view/" + r.getBoardNo());
            out.add(n);
        }

        // 시간 내림차순 정렬
        out.sort(Comparator.comparing(
            (NotificationDTO n) -> n.getTime() == null ? LocalDateTime.MIN : n.getTime()
        ).reversed());

        return out;
    }

    private LocalDateTime nullSafe(LocalDateTime t) {
        return t == null ? LocalDateTime.MIN : t;
    }

	
}
