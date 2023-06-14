;---------------------------------------------------------------------
OFFSET		EQU	('a' - 'A')	; offset w tablicy ASCII
;---------------------------------------------------------------------

ORG 0
	
	lcall test_rotate_xram
	
test_reverse_iram:
	mov	R0, #30h	; adres poczatkowy tablicy
	mov	R2, #8		; dlugosc tablicy
	lcall	fill_iram

	mov	R0, #30h	; adres poczatkowy tablicy
	mov	R2, #8		; dlugosc tablicy
	lcall	reverse_iram
	sjmp	$

test_rotate_xram:
	mov	DPTR, #8000h	; adres poczatkowy tablicy
	mov	R2, #8		; dlugosc tablicy R2
	mov	R3, #0
	lcall	fill_xram

	mov	DPTR, #8000h	; adres poczatkowy tablicy
	mov	R2, #8		; dlugosc tablicy R2
	mov	R3, #0
	lcall	rotate_xram    
	
	


test_string:
	mov	DPTR, #text	; adres poczatkowy stringu (CODE)
	mov	R0, #30h	; adres poczatkowy stringu (IRAM)
	lcall	copy_string

	mov	R0, #30h	; adres poczatkowy stringu (IRAM)
	lcall	reverse_string

	mov	R0, #30h	; adres poczatkowy stringu (IRAM)
	lcall	convert_letters

	sjmp	$

;--------------------------------------------------------------------- DONE
; Wypelnianie tablicy ciagiem liczbowym 1,2,3, ... (IRAM)
; Wejscie:  R0 - adres poczatkowy tablicy
;           R2 - dlugosc tablicy
;---------------------------------------------------------------------
fill_iram:
	MOV A, #1d   ; liczba
pentla:
	MOV @R0, A  
	INC A       
	INC R0       
	DJNZ R2, pentla 

ret

;--------------------------------------------------------------------- DONE 
; Wypelnianie tablicy ciagiem liczbowym 1,2,3, ... (XRAM)
; Wejscie:  DPTR  - adres poczatkowy tablicy
;           R3|R2 - dlugosc tablicy
;---------------------------------------------------------------------
fill_xram:
MOV A, #1d   ; liczba
pentlaxram:
	MOVX @DPTR, A  
	INC A       
	INC DPTR       
	DJNZ R2, pentlaxram

ret

;--------------------------------------------------------------------- DONE
; Odwracanie tablicy w pamieci wewnetrznej (IRAM)
; Wejscie:  R0 - adres poczatkowy tablicy
;           R2 - dlugosc tablicy
;---------------------------------------------------------------------
reverse_iram:
;R0 - adres poczotek
;R1 - adres koniec

;dziele na polowe bo tylko polowa tablicy mnie intersuje

	MOV A, R0
	MOV R1, A 
	MOV A, R2
	ADD A, R1
	MOV R1, A
	DEC R1
; w R0 adres pierwszego elemntu
; w R1 adres ostatniego elemntu

	MOV A, R2
	RR A  ; rotacja aby podzielilo przez 2 dlugosc tablicy elementow
	MOV R2, A
pentlareverse:
	MOV A, @R0
	XCH A, @R1  ;zamienia wartosci
	MOV @R0, A
	INC R0
	DEC R1
	DJNZ R2, pentlareverse

ret

;--------------------------------------------------------------------- DONE
; Rotacja w prawo tablicy w pamieci zewnetrznej (XRAM)
; Wejscie:  DPTR  - adres poczatkowy tablicy
;           R3|R2 - dlugosc tablicy
;---------------------------------------------------------------------
rotate_xram:
MOV B,R2

rotacja:
CJNE R2,#1,do
JMP skip

do:
MOVX A, @DPTR
PUSH ACC
INC DPTR

DJNZ R2, rotacja

skip:
MOVX A, @DPTR
MOV R1,A


MOV R2,B
INC DPTR
DEC R2
rotacja2:
MOV A, DPH
CJNE A, #0x00, pomin

DEC DPH
JC dalej

pomin:
DEC DPL

dalej:
POP ACC
MOVX @DPTR, A
DJNZ R2, rotacja2

;ostatni element
MOV A, DPH
CJNE A, #0x00, pomin2
DEC DPH
JC dalej2
pomin2:
DEC DPL

dalej2:
MOV A,R1
MOVX @DPTR, A
ret

;--------------------------------------------------------------------- DONE
; Kopiowanie stringu z pamieci programu (CODE) do pamieci IRAM
; Wejscie:  DPTR - adres poczatkowy stringu (CODE)
;           R0   - adres poczatkowy stringu (IRAM)
;---------------------------------------------------------------------
copy_string:
	MOV A, #0
	MOVC A, @A+DPTR
	CJNE A, #0,wpisz
	JMP koniec

wpisz:
	MOV @R0, A
	INC R0
	INC DPTR
	MOV A, #0
	MOVC A, @A+DPTR
	CJNE A, #0, wpisz
	JMP koniec
; w R0 adres pierwszego elemntu
; w R1 adres ostatniego elemntu

koniec:
ret

;--------------------------------------------------------------------- DONE
; Odwracanie stringu w pamieci IRAM
; Wejscie:  R0 - adres poczatkowy stringu
;--------------------------------------------------------------------- 
reverse_string:
	MOV A, R0
	MOV R1, A
licznikrev:
	INC R1
	MOV A,@R1
	CJNE A, #0,licznikrev
; w R0 adres pierwszego elementu
; w R1 adres ostatniego elementu
	CLR C
	MOV A, R1
	SUBB A, R0
	RRC A  ; rotacja aby podzielilo przez 2 dlugosc tablicy elementow
	MOV R2, A
	DEC R1
pentlareverse2:
	MOV A, @R0
	XCH A, @R1  ;zamienia wartosci
	MOV @R0, A
	INC R0
	DEC R1
	DJNZ R2, pentlareverse2

ret

;---------------------------------------------------------------------   DONE
; Zamiana malych liter na duze a duzych na male
; w stringu umieszczonym w pamieci IRAM
; Wejscie:  R0 - adres poczatkowy stringu
;---------------------------------------------------------------------
convert_letters:
	MOV R1, #0 

loop:
;sprawdzenie czy jest duza
	MOV A, #0
    MOV A, @R0  
    CJNE A, #0x41, nie_jest_A
	JMP jest_mala
	

nie_jest_A:
	JC nie_jest_duza_ani_mala
	CJNE A, #0x5A, nie_jest_Z
	JMP jest_mala

nie_jest_Z:
	JC jest_duza
	CJNE A, #0x61, nie_jest_male_a
	JMP jest_mala


nie_jest_male_a:
	CJNE A, #0x7A, nie_jest_male_z
	JMP jest_mala

nie_jest_male_z:
	JC jest_mala
	JNC nie_jest_duza_ani_mala

jest_mala:
	PUSH PSW
	CLR C
	SUBB A, #OFFSET   ; flage carry odejmowal i bylo zle
	POP PSW
	JMP nie_jest_duza_ani_mala

jest_duza:
	ADD A, #OFFSET
	JMP nie_jest_duza_ani_mala

nie_jest_duza_ani_mala:
    MOV @R0, A  
    INC R0  
    INC R1  
	INC DPTR
    CJNE R1, #22d, loop  ; Powtarzaj petle dla kazdego znaku

	ret

text:	DB	'ABCDEF world 0123456789', 0

END