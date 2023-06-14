;------------------------------------------------------------------------------
TIME_MS		EQU	10			; czas w [ms]
CYCLES		EQU	(1000 * TIME_MS)	; czas w cyklach (f = 12 MHz)
LOAD		EQU	(65536 - CYCLES)	; wartosc ladowana do TH0|TL0
;------------------------------------------------------------------------------
CNT_100		EQU	30h			; sekundy x 0.01
SEC		EQU	31h			; sekundy
MIN		EQU	32h			; minuty
HOUR		EQU	33h			; godziny

ALARM_SEC	EQU	34h			; alarm - sekundy
ALARM_MIN	EQU	35h			; alarm - minuty
ALARM_HOUR	EQU	36h			; alarm - godziny

SEC_CHANGE	EQU	0			; flaga zmiany sekund (BIT)
;------------------------------------------------------------------------------
LEDS		EQU	P1			; diody LED na P1 (0=ON)
ALARM		EQU	P1.7			; sygnalizacja alarmu
;------------------------------------------------------------------------------

;------------------------------------------------------------------------
WR_CMD		EQU	0FF2Ch		; zapis rejestru komend
WR_DATA		EQU	0FF2Dh		; zapis rejestru danych
RD_STAT		EQU	0FF2Eh		; odczyt rejestru statusu
RD_DATA		EQU	0FF2Fh		; odczyt rejestru danych
;------------------------------------------------------------------------



CSEG AT 0
	sjmp	start
	
CSEG AT 0Bh
;---------------------------------------------------------------------
; Obsluga przerwania Timera 0
;---------------------------------------------------------------------
T0_int:
    ; Przeladowanie timera
    MOV TL0, #LOAD ; zaladuj nizszy bajt wartosci do TL0
    MOV TH0, #LOAD/256 ; zaladuj wyzszy bajt wartosci do TH0
    
    ; Odlozenie na stosie uzywanych rejestrów
    PUSH ACC ; zalózmy, ze uzywamy rejestru ACC
    
    ; PROCEDURA UPDATE TIME Z POPRZEDNCIH LABOW TUTAJ
    
    ; Pobranie ze stosu odlozonych wczesniej rejestrów
    POP ACC
    
    reti ; powrót z przerwania
;---------------------------------------------------------------------
; Start programu
;---------------------------------------------------------------------
start:

;---------------------------------------------------------------------
; Petla glowna programu
;---------------------------------------------------------------------
main_loop:

	sjmp	main_loop

;---------------------------------------------------------------------
; Inicjowanie Timera 0 w trybie 16-bitowym z przerwaniami
;---------------------------------------------------------------------
timer_init:
    ; zatrzymanie timera
    clr TR0

    ; ustawienie trybu 16-bitowego Timera 0, nie zmieniajac trybu Timera 1
    mov TMOD, #01h

    ; wpisanie wartosci LOAD do rejestrów TH0 i TL0
    mov TH0, #HIGH(LOAD)
    mov TL0, #LOW(LOAD)

    ; wyzerowanie flagi przepelnienia timera
    clr TF0

    ; odblokowanie przerwan Timera 0
    setb ET0

    ; uruchomienie timera
    setb TR0

    ret

;---------------------------------------------------------------------
; Inicjowanie zmiennych zwiazanych z czasem
;---------------------------------------------------------------------
clock_init:

	ret

;---------------------------------------------------------------------
; Wyswietlanie czasu
;---------------------------------------------------------------------
clock_display:
	; Ustawienie pozycji wyswietlania na srodku górnej linii
	mov A, #0   ; kolumna 0
	mov B, #7   ; wiersz 0
	call lcd_gotoxy

	; Wyswietlenie godzin
	mov A, HOUR
	call lcd_dec_2

	; Wyswietlenie dwukropka
	mov A, #':'
	call lcd_write_data

	; Wyswietlenie minut
	mov A, MIN
	call lcd_dec_2

	; Wyswietlenie dwukropka
	mov A, #':'
	call lcd_write_data

	; Wyswietlenie sekund
	mov A, SEC
	call lcd_dec_2

	ret
;---------------------------------------------------------------------
; Obsluga alarmu
;---------------------------------------------------------------------
clock_alarm:

	ret
	
; procedury z lab 4
lcd_gotoxy:
	jb ACC.4, gotoxy_kij
	anl A, #00001111b
	add A, #10000000b
	jmp end_
	
gotoxy_kij:
	anl A, #00001111b		;ustawienie bardziej znaczacych bitow A na 0 i pozostawienie dolnych nietknietych
	add A, #11000000b		;dodanie wartosci 64 oraz ustawienie 1 na 7 pozycji aby sie wykonala odpowiednia komenda
	
end_:
	lcall lcd_write_cmd
	ret
	
lcd_dec_2:
	mov B, #10
	div AB
	add A, #'0'
	lcall lcd_write_data
	mov A,B
	add A, #'0'
	lcall lcd_write_data
	
	ret

lcd_write_data:
	push ACC
	mov DPTR,#RD_STAT
	
data_kij:	
	movx A,@DPTR
	jb ACC.7, data_kij
	
	pop ACC
	mov DPTR, #WR_DATA
	movx @DPTR, A
	ret

lcd_write_cmd:
	push ACC
	mov DPTR,#RD_STAT
	
cmd_kij:	
	movx A,@DPTR
	jb ACC.7, cmd_kij
	
	pop ACC
	mov DPTR, #WR_CMD
	movx @DPTR, A
	ret

END