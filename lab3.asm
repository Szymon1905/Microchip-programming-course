;------------------------------------------------------------------------------
LEDS		EQU	P1			; diody LED na P1 (0 = ON)
;------------------------------------------------------------------------------
TIME_MS		EQU	10			; czas w [ms]
CYCLES		EQU	(1000 * TIME_MS)	; czas w cyklach (f = 12 MHz)
LOAD		EQU	(65536 - CYCLES)	; wartosc ladowana do TH0|TL0
;------------------------------------------------------------------------------
SEC_100		EQU	30h			; sekundy x 0.01
SEC		EQU	31h			; sekundy
MIN		EQU	32h			; minuty
HOUR		EQU	33h			; godziny
;------------------------------------------------------------------------------

ORG 0
	lcall	delay_10ms
	sjmp $
	
	
	
	
	lcall	init_time		; inicjowanie czasu
time_loop:
	lcall	delay_10ms		; opoznienie 10 ms
	lcall	update_time		; aktualizacja czasu
	jnc	time_loop		; nie bylo zmiany sekund
					; tutaj zmiana sekund
	sjmp	time_loop

leds_loop:
	mov	R7, #50			; opoznienie 500 ms
	lcall	delay_nx10ms
	lcall	leds_change_1		; zmiana stanu diod
	sjmp	leds_loop

;---------------------------------------------------------------------
; Opoznienie 10 ms (zegar 12 MHz)
;---------------------------------------------------------------------

delay_10ms:
	mov R2, #120
zewnetrzna_pentla:
	mov R1, #40
wewnetrzna_pentla:
	djnz R1, wewnetrzna_pentla
	djnz R2, zewnetrzna_pentla
	ret


;---------------------------------------------------------------------
; Opoznienie n * 10 ms (zegar 12 MHz)
; R7 - czas x 10 ms
;---------------------------------------------------------------------

delay_nx10ms:
    mov R7, SEC_100  ; ładuje ilosć opóźnień do rejestru R7
outer_loop2:
    lcall delay_10ms  ;  opóźnienie 10 ms
    djnz R7, outer_loop2  ; powtarzam opóźnienie n razy
    ret

;---------------------------------------------------------------------
; Opoznienie 10 ms z uzyciem Timera 0 (zegar 12 MHz)
;---------------------------------------------------------------------
delay_timer_10ms:
  
  clr TR0 ; Zatrzymuje Timer 0

  
  anl TMOD, #0xF0 ; Ustawia tryb 16-bitowy Timera 0
  orl TMOD, #0x01 

  
  mov TH0, #0x78 
  mov TL0, #0x88

  clr TF0 ; TF0 - flaga przepełnienia timera

  
  setb TR0 ; Uruchmia Timer 0

wait:
  jnb TF0, wait ; czeka aż sie timer przepelni

  ret

;---------------------------------------------------------------------
; Inicjowanie czasu w zmiennych: HOUR, MIN, SEC, SEC_100
;---------------------------------------------------------------------
init_time:
mov SEC_100, #0 ;licznik setnych części sekundy
mov SEC, #0 ; sekundy
mov MIN, #0 ; minuty
mov HOUR, #0 ; godziny

;---------------------------------------------------------------------
; Aktualizacja czasu w postaci (HOUR : MIN : SEC) | SEC_100
; Przy wywolywaniu procedury co 10 ms
; wykonywana jest aktualizacja czasu rzeczywistego
;
; Wyjście: CY - sygnalizacja zmiany sekund (0 - nie, 1 - tak)
;---------------------------------------------------------------------
update_time:
    mov a, SEC_100
    add a, #1
    cjne a, #100, sec_100_done ; jeśli setne części sekundy = 100, to sie zerujom i idziemy do sekund
    clr a
    mov SEC_100, a
    
sekundy1:
    mov a, SEC
    add a, #1
    cjne a, #60, minuty1 ; jeśli sekundy = 60, idziemy do minut
    clr a ; zerujemy sekudny
    mov SEC, a
    ; obsługa minut
minuty1:
    mov a, MIN
    add a, #1
    cjne a, #60, godziny1 ; jeśli minuty = 60, to idziemy do godzin
    clr a
    mov MIN, a
    ; obsługa godzin
godziny1:
    mov a, HOUR
    add a, #1
    cjne a, #24, koniec ; jeśli godziny = 24, to koniec
    clr a
koniec:
    mov HOUR, a
    ret
sec_100_done:
    mov SEC_100, a
    sjmp sekundy1


;---------------------------------------------------------------------
; Zmiana stanu LEDS - wedrujaca w lewo dioda
;---------------------------------------------------------------------

leds_change_1:
	mov	A, LEDS		; przeniesienie wartości LEDS do akumulatora
	rr	A			; rotacja w prawo wartości akumulatora
	mov	LEDS, A		; przeniesienie wartości akumulatora do LEDS
	ret




leds_change_1_test:
opoznienie EQU 1000 ; czas opóźnienia w pętli

; program główny
start_led1:
    mov LEDS, #0x01 ; zapala diode nr 1
    call czekaj_led1 ; opoznienie
    mov LEDS, #0x03 ; zapala diode nr 1 i 2
    call czekaj_led1 
    mov LEDS, #0x07 ; zapala diode nr 1 i 2 i 3
    call czekaj_led1 
    mov LEDS, #0x0E ; zapala diode nr 2 i 3
    call czekaj_led1 
    mov LEDS, #0x0C ; zapala diode nr 2
    call czekaj_led1 
    mov LEDS, #0x08 ; zapala nr 1
    call czekaj_led1 
    sjmp start_led1 ; penta

; procedura opóźnienia
czekaj_led1:
    mov R0, #opoznienie/8
    czekaj1:
        mov R1, #100
        czekaj2:
            djnz R1, czekaj2
        djnz R0, czekaj1
    ret

;---------------------------------------------------------------------
; Zmiana stanu LEDS - narastajacy pasek od prawej
;---------------------------------------------------------------------


leds_change_2:
	mov	A, LEDS		; przeniesienie wartości LEDS do akumulatora
	orl	A, #1		; ustawienie najmłodszego bitu na 1
	rr	A			; rotacja w prawo wartości akumulatora
	mov	LEDS, A		; przeniesienie wartości akumulatora do LEDS
	ret
	
	
leds_change_2_test:
; inicjalizacja portu P1
mov P1, #0x00

; pętla 
pentla_led2:
    ; zapala kolejną diodę od prawej strony
    mov A, #0x80
    orl A, P1
    mov P1, A

    ;lcall opoznienie_led2
    ; przesuwa wszystkie diody w lewo o 1 pole
    mov A, P1
    rlc A
    mov P1, A
    sjmp pentla_led2


opoznienie_led2:
    mov R7, #200d 
	
	ret

END