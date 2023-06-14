WR_CMD		EQU	0FF2Ch		; zapis rejestru komend
WR_DATA		EQU	0FF2Dh		; zapis rejestru danych
RD_STAT		EQU	0FF2Eh		; odczyt rejestru statusu
RD_DATA		EQU	0FF2Fh		; odczyt rejestru danych

ORG 0
	lcall	lcd_init		; inicjowanie wyswietlacza

	mov	A, #04h			; x = 4, y = 0
	lcall	lcd_gotoxy		; przejscie do pozycji (4, 0)

	mov	DPTR, #text_hello	; wyswietlenie tekstu
	lcall	lcd_puts

	mov	A, #14h			; x = 4, y = 1
	lcall	lcd_gotoxy		; przejscie do pozycji (4, 1)

	mov	DPTR, #text_number	; wyswietlenie tekstu
	lcall	lcd_puts

	mov	A, #12			; wyswietlenie liczby
	lcall	lcd_dec_2
	
	
	mov	DPTR, #new_char_1
	mov A, #0
	lcall lcd_def_char

	mov	DPTR, #new_char_2
	mov A, #1
	lcall lcd_def_char

	mov A, #0
	lcall lcd_write_data

	mov A, #1
	lcall lcd_write_data
	
	sjmp	$

;=====================================================================

;---------------------------------------------------------------------
; Zapis komendy
;
; Wejscie: A - kod komendy
;---------------------------------------------------------------------
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

;---------------------------------------------------------------------
; Zapis danych
;
; Wejscie: A - dane do zapisu
;---------------------------------------------------------------------
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

;---------------------------------------------------------------------
; Inicjowanie wyswietlacza
;---------------------------------------------------------------------
lcd_init:
	mov A, #00111000b			;
	lcall lcd_write_cmd
	
	mov A, #00000110b
	lcall lcd_write_cmd
	
	mov A, #00001110b
	lcall lcd_write_cmd
	
	mov A, #00000001b
	lcall lcd_write_cmd
	ret

;---------------------------------------------------------------------
; Ustawienie biezacej pozycji wyswietlania
;
; Wejscie: A - pozycja na wyswietlaczu: ---y | xxxx
;---------------------------------------------------------------------
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

;---------------------------------------------------------------------
; Wyswietlenie tekstu od biezacej pozycji
;
; Wejscie: DPTR - adres pierwszego znaku tekstu w pamieci kodu
;---------------------------------------------------------------------
lcd_puts:

	
	clr A
	movc A,@A +DPTR
	jz puts_end
	mov R1, dph
	mov R2, dpl
	lcall lcd_write_data
	mov dph, R1
	mov dpl, R2
	inc DPTR
	sjmp lcd_puts
	
puts_end:
	ret

;---------------------------------------------------------------------
; Wyswietlenie liczby dziesietnej
;
; Wejscie: A - liczba do wyswietlenia (00 ... 99)
;---------------------------------------------------------------------
lcd_dec_2:
	mov B, #10
	div AB
	add A, #'0'
	lcall lcd_write_data
	mov A,B
	add A, #'0'
	lcall lcd_write_data
	
	ret

;---------------------------------------------------------------------
; Definiowanie wlasnego znaku
;
; Wejscie: A    - kod znaku (0 ... 7)
;          DPTR	- adres tabeli opisu znaku w pamieci kodu
;---------------------------------------------------------------------
lcd_def_char:
	mov B, #8
	mul AB
	add A, #01000000b

	mov R1, dph
	mov R2, dpl
	lcall lcd_write_cmd

	mov dph, R1
	mov dpl, R2

	mov R0, #8
def_kij:
	clr A
	movc A,@A +DPTR
	
	mov R1, dph
	mov R2, dpl
	lcall lcd_write_data
	mov dph, R1
	mov dpl, R2

	inc DPTR
	djnz R0, def_kij
	
	mov A, #10000000b
	lcall lcd_write_cmd
	
	ret

text_hello:
	db	'Hello word', 0
text_number:
	db	'Number = ', 0
new_char_1:
	db  0Eh,15h,15h,0Eh,5h,5h,0Dh,16h
new_char_2:
	db	11h,0Ah,04h,0Ah,1Fh,11h,11h,0Eh
END