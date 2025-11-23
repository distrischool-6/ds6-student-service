package com.ds6;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
// import org.springframework.test.context.TestPropertySource; // LINHA REMOVIDA

@SpringBootTest
@ActiveProfiles("test") // Esta linha é ótima! Vamos usá-la.
// @TestPropertySource(...)  <-- REMOVA ESTE BLOCO INTEIRO
class Distrischool6ApplicationTests {

	@Test
	void contextLoads() {
		// Este teste agora usará 'application-test.properties'
	}

}