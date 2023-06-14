;---------------------------------------------------------------------
P5		EQU	0F8h		; adres P5 w obszarze SFR
P7		EQU	0DBh		; adres P7 w obszarze SFR
;---------------------------------------------------------------------
ROWS		EQU	P5		; wiersze na P5.7-4
COLS		EQU	P7		; kolumny na P7.3-0
;---------------------------------------------------------------------
LEDS		EQU	P1		; diody LED na P1 (0=ON)
;---------------------------------------------------------------------

ORG 0

	
main_loop:
	lcall	kbd_read
	lcall	kbd_display
	sjmp	main_loop

;---------------------------------------------------------------------
; Uaktywnienie wybranego wiersza klawiatury
;
; Wejscie: A - numer wiersza (0 .. 3)
;---------------------------------------------------------------------
kbd_select_row:
	clr c
	subb A, #4 ; sprawdza czy numer wiersza jest wiekszy niz 3 
	jc ok
	anl P5, #00001111b ;jezeli jest numer wiersza wiekszy niz 3 to zeruje HB, LB nie tykamy
	sjmp koniec
ok:
    orl P5, #11110000b ;ustawia P5 na max, zero na pozcyji to wiersz który sprawdzamy
	add A, #4   ;dodaje 4 odjete wczesniej
	jz zero        
	cjne A, #1, nie_jeden
	anl P5, #10111111b		;jeden
	sjmp koniec	
nie_jeden:
	cjne A, #2, nie_dwa
	anl P5, #11011111b		;dwa
	sjmp koniec	
nie_dwa:	
	anl P5, #11101111b		;trzy
	sjmp koniec						
zero:
	anl P5, #01111111b		;zero
	
koniec:
	ret

;---------------------------------------------------------------------
; Odczyt wybranego wiersza klawiatury
;
; Wejscie: A  - numer wiersza (0 .. 3)
; Wyjscie: CY - stan wiersza (0 - brak klawisza, 1 - wcisniety klawisz)
;	   A  - kod klawisza (0 .. 3)
;---------------------------------------------------------------------
kbd_read_row:
	lcall kbd_select_row
	mov A, P7            ; w p7 jest numer kolumny, wiersz juz jest w p5
	setb C                ; carry = 1 gdy przycisk nacisniety
	jnb ACC.0, klawisz0     ; który bit jest ustawiony na ACC akumulator
	jnb ACC.1, klawisz1		
	jnb ACC.2, klawisz2					
	jnb ACC.3, klawisz3
	clr C							;brak wcisnientgo klawisza
	sjmp koniec_czytania
klawisz0:
	mov A, #0
	sjmp koniec_czytania
klawisz1:
	mov A, #1
	sjmp koniec_czytania
klawisz2:
	mov A, #2
	sjmp koniec_czytania
klawisz3:
	mov A, #3

koniec_czytania:	
	ret

;---------------------------------------------------------------------
; Odczyt calej klawiatury
;
; Wyjscie: CY - stan klawiatury (0 - brak klawisza, 1 - wcisniety klawisz)
; 	   A - kod klawisza (0 .. 15)
;---------------------------------------------------------------------
kbd_read:
	clr C
	mov A, #0             ; wybieram wiersz zerowy
	lcall kbd_read_row    ;czytam kolumny klawiatury
	jnc next			  ; jezeli nie bylo nacisnitego przycisku to leci dalej , jak byl to carry=1
	sjmp kbd_end
next:
	mov A, #1              ; to samo tutaj
	lcall kbd_read_row		; psw - rejestr na flagi
	jnc next1
	push psw ; push i pop aby add nie zerowal flagi carry
	add A, #4               ; dodaj 4 - ustawia kod klawisza
	pop psw
	sjmp kbd_end	
next1:
	mov A, #2
	lcall kbd_read_row
	jnc next2
	push psw
	add A, #8
	pop psw
	sjmp kbd_end
next2:
	mov A, #3
	lcall kbd_read_row
	jnc kbd_end
	push psw
	add A, #12
	pop psw

kbd_end:	
	ret

;---------------------------------------------------------------------
; Wyswietlenie stanu klawiatury
;
; Wejscie: CY - stanu klawiatury (0 - brak klawisza, 1 - wcisniety klawisz)
; 	   A  - kod klawisza (0 .. 15)
;---------------------------------------------------------------------
kbd_display:   ; wyswietla stan na diodach
	jc klawisz    ; czy jest ustawiony klawisz
	mov P1, #11111111b      ; jak nie to zeruje diody
	sjmp display_end
klawisz:
	xrl A,#11111111b         ;neguje A, w A jest kod przycisku
	anl A,#01111111b         ;jezeli jest nacisniety to pierwsza ma sie swiecic
	mov P1, A

display_end:
	ret

END




;test:
;	clr C
;	mov A, #1
;	lcall kbd_read_row
;	jnc next1
;	push psw
;	add A, #4
;	pop psw
;	lcall	kbd_display
;	sjmp test