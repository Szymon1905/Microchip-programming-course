
TIME_MS         EQU     50              ; czas w [ms]
CYCLES          EQU     (1000*TIME_MS)  ; czas w cyklach (f = 12 MHz)
LOAD            EQU     (65536-CYCLES+4); wartosc ladowana do TH0|TL0
                                        ; (4-cykle potrzebne do resetu timera)
CNT_VAL         EQU     1              ; wartosc dla licznika CNT_50
;---------------------------------------------------------------------
CNT_50          EQU     30h             ; licznik w ramach sekundy
HOUR            EQU     31h             ; godziny
MIN             EQU     32h             ; minuty
SEC             EQU     33h             ; sekundy
;---------------------------------------------------------------------
ALARM_HOUR      EQU     34h             ; alarm - godziny
ALARM_MIN       EQU     35h             ; alarm - minuty
ALARM_SEC       EQU     36h             ; alarm - sekundy
ALARM_CNT       EQU     37h             ; alarm - licznik
ALARM_DURR      EQU     10              ; alarm - czas trawnia
;---------------------------------------------------------------------
STOS            EQU     39h             ; address stosu
;---------------------------------------------------------------------
SEC_CHANGE      EQU     0               ; flaga zmiany sekund (BIT)
;---------------------------------------------------------------------
LEDS            EQU     P1              ; diody LED na P1 (0=ON)
ALARM           EQU     P1.7            ; sygnalizacja alarmu
;---------------------------------------------------------------------


;---------------------------------------------------------------------
; Poczatek pamieci, maksymalnei 11bytów
;---------------------------------------------------------------------
CSEG AT 0
        sjmp    start                   ; Skok na poczatek pamieci


CSEG AT 0Bh
;---------------------------------------------------------------------
; Obsluga przerwania Timera 0
;---------------------------------------------------------------------
T0_int:
        ;automatycznie:                 ; zerowanie flai przepelnienia TF0
        clr     TR0                     ;- zatrzymanie timer0
        mov     TL0,    #low(load)      ; wartosci poczatkowe timer0
        mov     TH0,    #high(load)
        setb    TR0                     ;- uruchomienie timer0

        push    ACC                     ; odlozenie na stos
        push    PSW                     ;

        djnz    CNT_50, no_change       ;- licznik (co 20)

        mov     CNT_50, #CNT_VAL        ; przywrocenie licznika
        setb    SEC_CHANGE              ; flaga zmiany sekund
        inc     SEC                     ; Aktualizacja sekund
        mov     A,      SEC
        cjne    A,      #60,    no_change

        mov     SEC,    #0              ; Aktualizacja minut
        inc     MIN
        mov     A,      MIN
        cjne    A,      #60,    no_change

        mov     MIN,    #0              ; Aktualizacja godzin
        inc     HOUR
        mov     A,      HOUR
        cjne    A,      #24,    no_change
        mov     HOUR,   #0              ;- Koniec doby

no_change:
        pop     PSW                     ; zdjecie ze stosu
        pop     ACC

        reti


;---------------------------------------------------------------------
; Start programu
;---------------------------------------------------------------------
start:
        mov     SP,     #STOS           ; inicjowanie stosu

        lcall   clock_init              ; inicjowanie zegara
        lcall   timer_init              ; inicjowanie timera

;---------------------------------------------------------------------
main_loop:                              ; <- Petla glowna programu
		lcall T0_int
        jnb     SEC_CHANGE, main_loop   ; Sprawdza zmiane flagi sekund   ,  jnb -  Jump if Bit Not Set
        lcall   clock_display           ; akt wyswietlania zegara
        lcall   clock_alarm             ; sprawdzenie alarmu
        clr     SEC_CHANGE              ; koniec aktualizacji czasu
		
        sjmp    main_loop

delay_100ms:
        mov     R1,     #200            ;                      1
_50ms_loop:
        nop                             ; 1 x 100       =    100
        mov     R2,     #248            ; 1 x 100       =    100
        djnz    R2,     $               ; 2 x 100 x 248 = 49 600
        djnz    R1,     _50ms_loop      ; 2 x 100       =    200
        ret                             ;              + __2__

;---------------------------------------------------------------------
; Inicjowanie Timera 0 w trybie 16-bitowym z przerwaniami
;---------------------------------------------------------------------
timer_init:
        clr     TR0                     ; zatrzymanie timera0

        anl     TMOD,   #0f0h           ; konfiguracja timera0
        orl     TMOD,   #001h           ; ...
        mov     TL0,    #low(load)      ; wartosci poczatkowe
        mov     TH0,    #high(load)     ; ...
        clr     TF0                     ; wyzerowanie flagi przepelnienia T0
        setb    ET0                     ; odblokowanie przerwania dla T0
        setb    EA                      ; ...

        setb    TR0                     ; uruchomienia timera0

        ret


;---------------------------------------------------------------------
; Inicjowanie zmiennych zwiazanych z czasem
;---------------------------------------------------------------------
clock_init:
        mov     CNT_50,         #CNT_VAL ; wartosc poczatkowa licznika
        mov     HOUR,           #9      ; Wartosci poczatkowe czasu
        mov     MIN,            #58
        mov     SEC,            #57
        mov     ALARM_HOUR,     #9       ; Inicjowanie alarmu
        mov     ALARM_MIN,      #59
        mov     ALARM_SEC,      #0
        mov     ALARM_CNT,      #0
        setb    ALARM            ; setb - set a bit to 1

        ret


;---------------------------------------------------------------------
; Wyswietlanie czasu
;---------------------------------------------------------------------
clock_display:
        mov     A,      SEC             ; Wyswietlanie stanu sekund
        cpl     A                       ;; negacja SEC
        orl     LEDS,   #00111111b      ;; zerowanie LEDS
        anl     LEDS,   A               ;; akt LEDS
										;; niedokonczone, ale ledy sie swieca
        ret


;---------------------------------------------------------------------
; Obsluga alarmu
;---------------------------------------------------------------------
clock_alarm:
        mov     A, ALARM_CNT                    ; zgas alarm
        jz      wyloncz_alarm
        dec     A                               ;- jesli alarm wlaczony
        mov     ALARM_CNT, A                    ;
        jnz     koniec_alarm                       ; jeoli 0 omija zgaszenie zegara
        setb    ALARM                           ; zgas alarm
        jmp     koniec_alarm                       ;-

wyloncz_alarm:                                   ;- jesli alarm wylaczony
        mov     A, HOUR                         ; Sprawdzanie alarmu
        cjne    A, ALARM_HOUR, koniec_alarm        ; godzina
        mov     A, MIN                          ;
        cjne    A, ALARM_MIN, koniec_alarm         ; minuta
        mov     A, SEC                          ;
        cjne    A, ALARM_SEC, koniec_alarm         ; sekunda

        clr     ALARM                           ; wyswietla alarm
        mov     ALARM_CNT, ALARM_DURR           ; ustawia czas trawania alarmu

koniec_alarm:
        ret


END