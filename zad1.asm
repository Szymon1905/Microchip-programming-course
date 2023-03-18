
ORG 0

;---------------------------------------------------------------------
; Test procedury - wywolanie jednorazowe
;---------------------------------------------------------------------
;Szymon Borzdynski
;Wiktor Szymczyk


test_dec_iram:
	mov	R0, #30h	; liczba w komorkach IRAM 30h i 31h/   30h - opernad pamieci  #30h - operand wartosci
	lcall	add_xram	; wywolanie procedury
	sjmp	test_dec_iram ;

;---------------------------------------------------------------------
; Test procedury - wywolanie powtarzane
;---------------------------------------------------------------------
;loop:	mov	DPTR, #8000h	; liczba w komorkach XRAM 8000h i 8001h
	;lcall	inc_xram	; wywolanie procedury
	;sjmp	loop		; powtarzanie

;=====================================================================

;---------------------------------------------------------------------
; Dekrementacja liczby dwubajtowej w pamieci wewnetrznej (IRAM)
; R0 - adres mlodszego bajtu (Lo) liczby
;---------------------------------------------------------------------
dec_iram:
    MOV A, @R0
	DEC @R0
    JNZ  brak_pozyczki
    INC R0
    DEC @R0

brak_pozyczki: 
	RET 
	
	; MOV -  kopiuje B do A 
	; DEC - dekrementuje wartosc w akumlatorze
	; CJNE - skok jesli wartosci nie sa rowne
	
	; Akumulator - jednobajtowy rejestr do operacji arytmetycznych i logicznych, 
	

 

	


;---------------------------------------------------------------------
; Inkrementacja liczby dwubajtowej w pamieci zewnetrznej (XRAM)
; DPTR - adres mlodszego bajtu (Lo) liczby
;---------------------------------------------------------------------
inc_xram:
	mov DPTR, #0x0000 ; ustawia adres pamieci zewnetrznej
    movx A, @DPTR ;kopiuje wartosc z pamieci zewnetrznej do akumulatora
	
	CJNE A, #255d, brak_przeniesienia
	
    inc A ;inkrementuje wartosc w akumulatorze
    movx @DPTR, A ;kopiuje zmieniona wartosc z powrotem do pamieci zewnetrznej
    inc DPTR ;zwieksza wskaznik pamieci na kolejny bajt
    movx A, @DPTR ;kopiuje kolejny bajt liczby do akumulatora
    inc A ;inkrementuje wartosc w akumulatorze
    movx @DPTR, A ;zapisuje zmieniona wartosc z powrotem do pamieci zewnetrznej
	
	ret
	
brak_przeniesienia: 
	inc A ;inkrementuje wartosc w akumulatorze
    movx @DPTR, A ;kopiuje zmieniona wartosc z powrotem do pamieci zewnetrznej
	RET
	
	; MOVX -  kopiuje B do A ale w pamieci zewnetrznej
	; DPTR - rejstr który przechowuje 16 bitowy adres pamieci xram lub pamieci programu 
	; INC - zwieksza rejstr o 1

;---------------------------------------------------------------------
; Odjecie liczb dwubajtowych w pamieci wewnetrznej (IRAM)
; R0 - adres mlodszego bajtu (Lo) odjemnej A oraz roznicy (A <- A - B)
; R1 - adres mlodszego bajtu (Lo) odjemnika B
;---------------------------------------------------------------------
sub_iram:  ; NIE DZIALA

	mov R0, #0x30 ;ustaw adres pierwszej liczby w pamieci wewnetrznej
    mov R1, #0x32 ;ustaw adres drugiej liczby w pamieci wewnetrznej
    mov A, @R0 ;zaladuj pierwsza liczbe do akumulatora
    mov B, @R1 ;zaladuj druga liczbe do rejestru B
    clr C ;czyszcze flage przeniesienia
    subb A, B ;odjemuje druga liczbe z pierwszej z pozyczka
    mov @R0, A ;zapisuje wynik odejmowania w miejsce pierwszej liczby
    mov A, R0 ;kopiuje adres pierwszej liczby do akumulatora
    inc A ;zwiekszam akumulator o 1
    mov R0, A ;zapisuje nowy adres pierwszej liczby w R0
    mov A, @R0 ;kopiuje drugi bajt pierwszej liczby do akumulatora
    mov R3, #0x23 ;zapisuje adres drugiego bajtu drugiej liczby w R3
    movx A, @DPTR ;kopiuje drugi bajt drugiej liczby do rejestru B
    subb A, B ;odejmuje drugi bajt drugiej liczby z drugim bajtem pierwszej liczby z pozyczka
    mov @R0, A ;zapisuje wynik odejmowania w miejsce drugiego bajtu pierwszej liczby
    inc A ;zwiekszam akumulator o 1
    mov R0, A ;zapisuje nowy adres pierwszej liczby w R0
    
	ret
	
sub_iram2:    ; NIE DZIALA
	mov R0, #0x04 ;ustaw adres pierwszej liczby w pamieci wewnetrznej
    mov R1, #0x02 ;ustaw adres drugiej liczby w pamieci wewnetrznej
    mov A, @R0
    clr C
    subb A, @R1
    mov @R0, A
    inc R0
    inc R1
    mov A, @R0
    subb A, @R1
    mov @R0, A

    ret
	
	
	

;---------------------------------------------------------------------
; Ustawienie bitow parzystych (0,2, ..., 14) w liczbie dwubajtowej
; Wejscie: R7|R6 - liczba dwubajtowa
; Wyjscie: R7|R6 - liczba po modyfikacji
;---------------------------------------------------------------------
set_bits:
	mov A, R6    ; Wczytaj zawartosc rejestru R6 do akumulatora
    orl A, #55h    ; Ustaw bity parzyste w akumulatorze na 1 // 
    mov R6, A    ; Zapisz wartosc z akumulatora do rejestru R6
    mov A, R7    ; Wczytaj zawartosc rejestru R7 do akumulatora
    orl A, #55h    ; Ustaw bity parzyste w akumulatorze na 1
    mov R7, A    ; Zapisz wartosc z akumulatora do rejestru R7
    ret            ; Powrót z proceduryt
	
	;orl - logiczny OR

;---------------------------------------------------------------------
; Przesuniecie w lewo liczby dwubajtowej (mnozenie przez 2)
; Wejscie: R7|R6 - liczba dwubajtowa
; Wyjscie: R7|R6 - liczba po modyfikacji
;---------------------------------------------------------------------
shift_left:
	clr C
    mov A, R6       ; kopiuje 2 bajtowa wartosc do akumulatora
    rlc A           ; przesuniecie w lewo
    mov R6, A       ; kopiuje przesuniete wartosc to rejstru R0
    mov A, R7      ; kopiuje straszy bajt do rejstru R1 do akumulatora
    rlc A           ; przesuniecie w lewo
    mov R7, A       ; kopiuje zmieniona wartosc to rejstr R1
	
	ret
	

;---------------------------------------------------------------------
; Pobranie liczby dwubajtowej z pamieci kodu
; Wejscie: DPTR  - adres mlodszego bajtu (Lo) liczby w pamieci kodu
; Wyjscie: R7|R6 - pobrane dane
;---------------------------------------------------------------------

; paramter przed funkcja
get_code_const:
	mov DPTR, #code_const
	clr A
	MOVC A, @A+DPTR   
	MOV R7, A         
	clr A
	INC DPTR
	MOVC A, @A+DPTR   
	MOV R6, A         

	ret  
;---------------------------------------------------------------------
; Zamiana wartosci rejestrow DPTR i R7|R6
; Nie niszczy innych rejestrow
;---------------------------------------------------------------------

swap_regs:
	push ACC
	mov A, R6
	XCH A, DPL
	mov R6, A
	mov A, R7
	XCH A, DPH
	mov R7, A
	pop ACC
	
	ret
	
;stackoverflow

;---------------------------------------------------------------------
; Dodanie 10 do danych w obszarze pamieci zewnetrznej (XRAM)
; DPTR - adres poczatku obszaru
; R2   - dlugosc obszaru
;---------------------------------------------------------------------
add_xram:
	MOV A, R2
	CJNE A, #00h, sprawdz	
	ret
	
sprawdz:
	MOVX A, @DPTR
	ADD A, #10
	MOVX @DPTR, A
	INC DPTR
	DEC R2
	MOV A, R2
	CJNE A, #00h, sprawdz	
	ret

;---------------------------------------------------------------------
code_const:
	DB	LOW(1234h)
	DB	HIGH(1234h)

END