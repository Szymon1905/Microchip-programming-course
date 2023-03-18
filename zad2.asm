ORG 0

	sjmp	test_count_even_gt10	; przyklad testu wybranej procedury

test_sum_iram:
	mov	R0, #30h	; adres poczatkowy obszaru
	mov	R2, #4		; dlugosc obszaru
	lcall	sum_iram
	sjmp	$

test_copy_iram_iram_inv:
	mov	R0, #30h	; adres poczatkowy obszaru zrodlowego
	mov	R1, #40h	; adres poczatkowy obszaru docelowego
	mov	R2, #4		; dlugosc obszaru
	lcall	copy_iram_iram_inv
	sjmp	$

test_copy_xram_iram_z:
	mov	DPTR, #8000h	; adres poczatkowy obszaru zrodlowego
	mov	R0, #30h	; adres poczatkowy obszaru docelowego
	mov	R2, #4		; dlugosc obszaru
	lcall	copy_xram_iram_z
	sjmp	$

test_copy_xram_xram:
	mov	DPTR, #8000h	; adres poczatkowy obszaru zrodlowego
	mov	R0, #LOW(8010h)	; adres poczatkowy obszaru docelowego
	mov	R1, #HIGH(8010h)
	mov	R2, #4		; dlugosc obszaru
	lcall	copy_xram_xram
	sjmp	$

test_count_even_gt10:
	mov	R0, #30h	; adres poczatkowy obszaru
	mov	R2, #4		; dlugosc obszaru
	lcall	count_even_gt10
	sjmp	$

;---------------------------------------------------------------------
; Sumowanie bloku danych w pamieci wewnetrznej (IRAM)
;
; Wejscie: R0    - adres poczatkowy bloku danych
;          R2    - dlugosc bloku danych
; Wyjscie: R7|R6 - 16-bit suma elementow bloku (Hi|Lo)
;---------------------------------------------------------------------
	
sum_iram:  ; DZIALA
    CLR C
	MOV R7, #0   
    MOV R6, #0   
	
pentla1:
	; czytanie dancyh z IRAM
    MOV A, @R0 
	
	;Dodanie i wpisanie wyniku do R6
    ADD A, R6     
    MOV R6, A
	CLR A   
    ADDC A, R7    
    MOV R7, A     
	
	; przesuniecie adresu 
    INC R0
	CLR C	
    DJNZ R2, pentla1

    ret
	
	;DJNZ zmniejsza o jeden i skacze jesli nie jest zero

;---------------------------------------------------------------------
; Kopiowanie bloku danych w pamieci wewnetrznej (IRAM) z odwroceniem
;
; Wejscie: R0 - adres poczatkowy obszaru zrodlowego
;          R1 - adres poczatkowy obszaru docelowego
;          R2 - dlugosc kopiowanego obszaru
;---------------------------------------------------------------------
copy_iram_iram_inv: ; DZIALA
	pentla2:
		MOV A, @R0      ; Wczytaj dane ze zródla do akumulatora
		MOV @R1, A      ; Zapisz dane do celu
		INC R0          ; Zwieksz wskaznik zródla
		JMP odwrot
		DJNZ R2, pentla2   ; Powtarzaj az do konca bloku

	odwrot:
		DEC R1          ; Zmiejsz wskaznik celu
		MOV A, @R0      ; Wczytaj dane ze zródla do akumulatora
		MOV @R1, A      ; Zapisz dane do celu
		DJNZ R2, pentla2 ; Powtarzaj az do konca bloku

	ret

;---------------------------------------------------------------------
; Kopiowanie bloku z pamieci zewnetrznej (XRAM) do wewnetrznej (IRAM)
; Przy kopiowaniu powinny byc pominiete elementy zerowe
;
; Wejscie: DPTR - adres poczatkowy obszaru zrodlowego
;          R0   - adres poczatkowy obszaru docelowego
;          R2   - dlugosc kopiowanego obszaru
;---------------------------------------------------------------------
copy_xram_iram_z: ; DZIALA
	pentla3:
		MOVX A, @DPTR   ; Wczytaj dane ze zródla do akumulatora
		INC DPTR        ; Zwieksz wskaznik zródla
		JZ pomin_krok         ; Jesli dane w akumulatorze sa zerowe, przejdz do Skip
		MOV @R0, A      ; Zapisz dane do celu
		INC R0          ; Zwieksz wskaznik celu
	pomin_krok:
		DJNZ R2, pentla3   ; Powtarzaj az do konca bloku
	ret

;---------------------------------------------------------------------
; Kopiowanie bloku danych w pamieci zewnetrznej (XRAM -> XRAM)
;
; Wejscie: DPTR  - adres poczatkowy obszaru zrodlowego
;          R1|R0 - adres poczatkowy obszaru docelowego
;          R2    - dlugosc kopiowanego obszaru
;---------------------------------------------------------------------
copy_xram_xram: ;DZIALA
	pentla4:
		MOVX A, @DPTR   ; Wczytaj dane ze zródla do akumulatora
		
		; kopia adresu zródla 
		MOV R3, DPL   
		MOV R4, DPH
		; wpisanie adresu docelowego do DPTR
		MOV DPL, R0
		MOV DPH, R1
		; Zapisanie danych do celu
		MOVX @DPTR, A
		
		; Przesuniecie adresow o jedno dalej
		INC R0
		INC R3
		; wpsianie przesunietego adresu zrodlwego do DPTR
		MOV DPL, R3   
		MOV DPH, R4
		
		DJNZ R2, pentla4   ; Powtarzaj az do konca bloku
	ret

;---------------------------------------------------------------------
; Zliczanie w bloku danych w pamieci wewnetrznej (IRAM)
; liczb parzystych wiekszych niz 10
;
; Wejscie: R0 - adres poczatkowy bloku danych
;          R2 - dlugosc bloku danych
; Wyjscie: A  - liczba elementow spelniajacych warunek
;---------------------------------------------------------------------
count_even_gt10:
	MOV R7, #0    
	pentla5:
		MOV A, @R0     
		JB ACC.0, pomin2  ; Pomijaj liczby nieparzyste
		CJNE A, #10h, flaga_C ; Pomija liczby mniejsze lub równe 10
		JMP pomin2
	flaga_C:
		CPL C
		JNC pomin2
		CLR C
		INC R0
		INC R7
		DJNZ R2, pentla5
	pomin2:
		CLR C
		INC R0
		DJNZ R2, pentla5   ; pentla do konca bloku danych
		
	; wpisuje wynik koncowy do akumulatora
	MOV A,R7

	ret
	
	;JB - skok jesli bit ustawiony na 1
	;ACC.0 - najmniej znaczacy bit
	;CJNE - porównuje i skacze jesli akumulator nie jest rowny lub mniejszy niz podane dane
	;DJNZ zmniejsza o jden i skacze jesli nie jest zero

END