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

	sjmp	$

;=====================================================================

;---------------------------------------------------------------------
; Zapis komendy
;
; Wejscie: A - kod komendy
;---------------------------------------------------------------------
lcd_write_cmd:

	ret

;---------------------------------------------------------------------
; Zapis danych
;
; Wejscie: A - dane do zapisu
;---------------------------------------------------------------------
lcd_write_data:

	ret

;---------------------------------------------------------------------
; Inicjowanie wyswietlacza
;---------------------------------------------------------------------
lcd_init:

	ret

;---------------------------------------------------------------------
; Ustawienie biezacej pozycji wyswietlania
;
; Wejscie: A - pozycja na wyswietlaczu: ---y | xxxx
;---------------------------------------------------------------------
lcd_gotoxy:

	ret

;---------------------------------------------------------------------
; Wyswietlenie tekstu od biezacej pozycji
;
; Wejscie: DPTR - adres pierwszego znaku tekstu w pamieci kodu
;---------------------------------------------------------------------
lcd_puts:

	ret

;---------------------------------------------------------------------
; Wyswietlenie liczby dziesietnej
;
; Wejscie: A - liczba do wyswietlenia (00 ... 99)
;---------------------------------------------------------------------
lcd_dec_2:

	ret

;---------------------------------------------------------------------
; Definiowanie wlasnego znaku
;
; Wejscie: A    - kod znaku (0 ... 7)
;          DPTR	- adres tabeli opisu znaku w pamieci kodu
;---------------------------------------------------------------------
lcd_def_char:

	ret

text_hello:
	db	'Hello word', 0
text_number:
	db	'Number = ', 0

END