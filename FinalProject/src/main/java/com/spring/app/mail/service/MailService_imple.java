package com.spring.app.mail.service;

import org.springframework.stereotype.Service;

import com.spring.app.mail.model.MailDAO;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class MailService_imple implements MailService {

	private final MailDAO dao;
	
}
