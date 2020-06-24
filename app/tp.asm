.8086
.MODEL SMALL
.STACK 2048

;Trabalho Prático de TAC 2016/2017
;Hugo Silva nº 21240009
;	Jose Oliveira 	- 21240014@isec.pt

DADOS	SEGMENT PARA 'DATA'
;**** Inserir variaveis



DADOS	ENDS


PILHA	SEGMENT PARA STACK 'STACK'
		db 2048 dup(?)
PILHA	ENDS


dseg    segment para public 'data'
		;Ler Ficheiro
        Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
        Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
        Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
        Fich         	db      'menu.txt',0
		Fichd			db		'creditos.txt',0
		Fiche			db		'labi.txt',0
		Ficho			db		'top.txt',0
        HandleFich      dw      0
        car_fich        db      ?
		
		;adicionei do avatar
		string		db	"Teste prático de T.I",0
		Car			db	32	; Guarda um caracter do Ecran 
		Cor			db	7	; Guarda os atributos de cor do caracter
		POSy		db	5	; a linha pode ir de [1 .. 25]
		POSx		db	10	; POSx pode ir [1..80]	
		POSya		db	5	; Posição anterior de y
		POSxa		db	10	; Posição anterior de x
		linha		db	0	;linha onde se encontra o ponteiro
		coluna		db	0 ;coluna onde se encontra o ponteiro
		baixos		db	0	;seta baixo seguinte
		cimas		db	0	;seta cima seguinte
		esquerdas	db	0	;seta esquerda
		direitas	db	0	;seta direita
		
		;Adicionei do hms_dma
		STR12	 	DB 		"            "	; String para 12 digitos	
		STR10	 	DB 		"            "	; String para 12 digitos	
		NUMERO		DB		"                    $", 	; String destinada a guardar o número lido
	
		NUM_SP		db		"                    $" 	; PAra apagar zona de ecran
		Horas		dw		0				; Vai guardar a HORA actual
		Minutos		dw		0				; Vai guardar os minutos actuais
		Segundos	dw		0				; Vai guardar os segundos actuais
		Old_seg		dw		0				; Guarda os últimos segundos que foram lidos
		Hora		dw		0				; Vai guardar a HORA Final
		Minuto		dw		0				; Vai guardar os minutos Final
		Segundo		dw		0				; Vai guardar os segundos final
		tempo		dw		0
		;lerlinha 
		FRASE1					db	'Acabou o jogo demorando ','$'
		
	buffer	db	'segundos',13,10
	contador dw 2
	msgErrorCreate	db	"Ocorreu um erro na criacao do ficheiro!$"
	msgErrorWrite	db	"Ocorreu um erro na escrita para ficheiro!$"
	msgErrorClose	db	"Ocorreu um erro no fecho do ficheiro!$"	
	conf			db	0
		
dseg    ends



CODIGO	SEGMENT PARA 'CODE'
	ASSUME cs:CODIGO, ds:dseg,	SS:PILHA
	

	
INICIO:
	MOV	AX, dseg
	MOV	DS, AX
	
	
;#############################################################################
;             MAIN
;############################################################################
jmp menu
main: 


jmp sai


;########################################################################
;MENU

MENU:
jmp abre_ficheiro
TECLAA:
call LE_TECLA
cmp al,'1'
je jogos_st
cmp al,'2'
je abre_top
cmp al,'3'
je editar_lab
cmp al,'4'
je creditos
cmp al,'5'
je sai
jmp menu


;########################################################################
;ROTINA PARA APAGAR ECRAN NAO CONSIGO UTILIZAR

apaga_ecran	proc
		mov		ax, dseg
		mov		ds,ax
		mov		ax,0B800h
		mov		es,ax
		xor		bx,bx
		mov		cx,25*80
		
		
apaga:			
		mov	byte ptr es:[bx],' '
		mov		byte ptr es:[bx+1],7
		inc		bx
		inc 		bx
		loop		apaga
		ret
apaga_ecran	endp


;########################################################################
				

;########################################################################
; LE UMA TECLA	

LE_TECLA	PROC
		mov		ah,08h
		int		21h
		mov		ah,0
		cmp		al,0
		jne		SAI_TECLA
		mov		ah, 08h
		int		21h
		mov		ah,1
SAI_TECLA:	RET
LE_TECLA	endp


;########################################################################

	;Abre labirinto
		abre_labirinto:
		call apaga_ecran
	    mov     ah,3dh			; vamos abrir ficheiro para leitura 
        mov     al,0			; tipo de ficheiro	
        lea     dx,Fiche		; nome do ficheiro
        int     21h			; abre para leitura 
        jc      erro_abrir		; pode aconter erro a abrir o ficheiro 
        mov     HandleFich,ax		; ax devolve o Handle para o ficheiro 
        jmp     ler_ciclod		; depois de abrir vamos ler o ficheiro
		
		ler_ciclod:
		mov     ah,3fh			; indica que vai ser lido um ficheiro 
        mov     bx,HandleFich		; bx deve conter o Handle do ficheiro previamente aberto 
        mov     cx,1			; numero de bytes a ler 
        lea     dx,car_fich		; vai ler para o local de memoria apontado por dx (car_fich)
        int     21h				; faz efectivamente a leitura
		jc	    erro_lerd		; se carry é porque aconteceu um erro
		cmp	    ax,0			;EOF?	verifica se já estamos no fim do ficheiro 
		je	    fecha_ficheirod	; se EOF fecha o ficheiro 
        mov     ah,02h			; coloca o caracter no ecran
		mov	    dl,car_fich		; este é o caracter a enviar para o ecran
		int	    21h				; imprime no ecran
		jmp	    ler_ciclod		; continua a ler o ficheiro
		
	erro_lerd:
		 mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h
	fecha_ficheirod:					; vamos fechar o ficheiro 
        mov     ah,3eh
        mov     bx,HandleFich
        int     21h
        jnc     jogos ;mudei de sai para mandar para o menu

        mov     ah,09h			; o ficheiro pode não fechar correctamente
        lea     dx,Erro_Close
        Int     21h
	


	;Abre TOp 10
		abre_top:
		call apaga_ecran
	    mov     ah,3dh			; vamos abrir ficheiro para leitura 
        mov     al,0			; tipo de ficheiro	
        lea     dx,Ficho			; nome do ficheiro
        int     21h			; abre para leitura 
        jc      erro_abrir		; pode aconter erro a abrir o ficheiro 
        mov     HandleFich,ax		; ax devolve o Handle para o ficheiro 
        jmp     ler_cicl		; depois de abrir vamos ler o ficheiro 
	

	;CREDITOS
		creditos:
		call apaga_ecran
	    mov     ah,3dh			; vamos abrir ficheiro para leitura 
        mov     al,0			; tipo de ficheiro	
        lea     dx,Fichd		; nome do ficheiro
        int     21h			; abre para leitura 
        jc      erro_abri		; pode aconter erro a abrir o ficheiro 
        mov     HandleFich,ax		; ax devolve o Handle para o ficheiro 
        jmp     ler_cicl		; depois de abrir vamos ler o ficheiro
	
	
		erro_abri:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     sai
		
	ler_cicl:
		mov     ah,3fh			; indica que vai ser lido um ficheiro 
        mov     bx,HandleFich		; bx deve conter o Handle do ficheiro previamente aberto 
        mov     cx,1			; numero de bytes a ler 
        lea     dx,car_fich		; vai ler para o local de memoria apontado por dx (car_fich)
        int     21h				; faz efectivamente a leitura
		jc	    erro_le		; se carry é porque aconteceu um erro
		cmp	    ax,0			;EOF?	verifica se já estamos no fim do ficheiro 
		je	    fecha_ficheir	; se EOF fecha o ficheiro 
        mov     ah,02h			; coloca o caracter no ecran
		mov	    dl,car_fich		; este é o caracter a enviar para o ecran
		int	    21h				; imprime no ecran
		jmp	    ler_ciclo		; continua a ler o ficheiro
		
	erro_le:
		 mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h
	fecha_ficheir:					; vamos fechar o ficheiro 
        mov     ah,3eh
        mov     bx,HandleFich
        int     21h
        jnc     MENU ;mudei de sai para mandar para o menu

        mov     ah,09h			; o ficheiro pode não fechar correctamente
        lea     dx,Erro_Close
        Int     21h
	
	
	
	
	
	
	;Abre menu	
	abre_ficheiro:
		call apaga_ecran
	    mov     ah,3dh			; vamos abrir ficheiro para leitura 
        mov     al,0			; tipo de ficheiro	
        lea     dx,Fich			; nome do ficheiro
        int     21h			; abre para leitura 
        jc      erro_abrir		; pode aconter erro a abrir o ficheiro 
        mov     HandleFich,ax		; ax devolve o Handle para o ficheiro 
        jmp     ler_ciclo		; depois de abrir vamos ler o ficheiro 
	
	erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     sai
		
	ler_ciclo:
		mov     ah,3fh			; indica que vai ser lido um ficheiro 
        mov     bx,HandleFich		; bx deve conter o Handle do ficheiro previamente aberto 
        mov     cx,1			; numero de bytes a ler 
        lea     dx,car_fich		; vai ler para o local de memoria apontado por dx (car_fich)
        int     21h				; faz efectivamente a leitura
		jc	    erro_ler		; se carry é porque aconteceu um erro
		cmp	    ax,0			;EOF?	verifica se já estamos no fim do ficheiro 
		je	    fecha_ficheiro	; se EOF fecha o ficheiro 
        mov     ah,02h			; coloca o caracter no ecran
		mov	    dl,car_fich		; este é o caracter a enviar para o ecran
		int	    21h				; imprime no ecran
		jmp	    ler_ciclo		; continua a ler o ficheiro
		
	erro_ler:
		 mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h
	fecha_ficheiro:					; vamos fechar o ficheiro 
        mov     ah,3eh
        mov     bx,HandleFich
        int     21h
        jnc     TECLAA ;mudei de sai para mandar para o menu

        mov     ah,09h			; o ficheiro pode não fechar correctamente
        lea     dx,Erro_Close
        Int     21h
		

;########################################################################	
								;Jogo
;########################################################################
	
	
	
;########################################################################
goto_xy	macro		POSx,POSy
		mov		ah,02h
		mov		bh,0		; numero da página
		mov		dl,POSx
		mov		dh,POSy
		int		10h
endm

;########################################################################
	
	
;funcao do jogo
jogos_st:
jmp abre_labirinto

jogos:
	call Ler_TEMPO
	mov		ax, dseg
	mov		ds,ax
	mov		ax,0B800h
	mov		es,ax
	mov POSx,5
	mov POSy,23
	
goto_xy	POSx,POSy	; Vai para nova possição
	mov 	ah, 08h	; Guarda o Caracter que está na posição do Cursor
	mov		bh,0		; numero da página
	int		10h			
	mov		Car, al	; Guarda o Caracter que está na posição do Cursor
	mov		Cor, ah	; Guarda a cor que está na posição do Cursor	
	
	
CICLO:	goto_xy	POSxa,POSya	; Vai para a posição anterior do cursor
		mov		ah, 02h
		mov		dl, Car	; Repoe Caracter guardado 
		int		21H		
		
		goto_xy	POSx,POSy	; Vai para nova possição
		mov 	ah, 08h
		mov		bh,0		; numero da página
		int		10h		
		mov		Car, al	; Guarda o Caracter que está na posição do Cursor
		mov		Cor, ah	; Guarda a cor que está na posição do Cursor
		
		goto_xy	78,0		; Mostra o caractr que estava na posição do AVATAR
		mov		ah, 02h	; IMPRIME caracter da posição no canto
		mov		dl, Car	
		int		21H			
	
		goto_xy	POSx,POSy	; Vai para posição do cursor
IMPRIME:	
		mov		ah, 02h
		mov		dl, 190	; Coloca AVATAR
		int		21H	
		goto_xy	POSx,POSy	; Vai para posição do cursor
		
		mov		al, POSx	; Guarda a posição do cursor
		mov		POSxa, al
		mov		al, POSy	; Guarda a posição do cursor
		mov 	POSya, al
		
LER_SETA:	
		call 	LE_TECLA
		cmp		ah, 1
		je		ESTEND
		CMP 	AL, 27	; ESCAPE
		JE		sai
		jmp		LER_SETA
		
ESTEND:	
		cmp 	al,48h
		jne		BAIXO
		;jmp 	verifica_seta ; acrescentei isto para verificar a posicao seguinte
		jmp 	verifica_cima
		;dec		POSy		;cima
		;jmp		CICLO

BAIXO:	
		cmp		al,50h
		jne		ESQUERDA
		;jmp 	verifica_setab
		jmp 	verifica_baixo
		;inc 	POSy		;Baixo
		;jmp		CICLO

ESQUERDA:
		cmp		al,4Bh
		jne		DIREITA
		jmp		verifica_esquerda
		;dec		POSx		;Esquerda
		;jmp		CICLO

DIREITA:
		cmp		al,4Dh
		jne		LER_SETA 
		jmp 	verifica_direita
		;inc		POSx		;Direita
		;jmp		CICLO

		
;########################################################################		
;########################################################################	

;Verifica baixo
flag:
				cmp 	al, 'F'
				je 		fim_jogo
				cmp  	al, 20h ; O al ja vem com a letra
				jne   	CICLO
				inc 	POSy		;Baixo
				jmp		CICLO


verifica_baixo:
			 inc 		POSy
			 goto_xy	POSx,POSy	; Vai para nova possicao
			 mov 		ah, 08h	; Guarda o Caracter que esta na posicao do Cursor
			 mov		bh,0		; numero da pagina
			 int		10h
			 mov		baixos, al	; Guarda o Caracter que esta na posicao do Cursor
			 dec    	POSy
			 goto_xy	POSx,POSy
			 jmp flag

			
;verifica cima
flagc:
				cmp 	al, 'F'
				je 		fim_jogo
				cmp  	al, 20h ; O al ja vem com a letra
				jne   	CICLO
				dec 	POSy		;cima
				jmp		CICLO


verifica_cima:
			 dec 		POSy
			 goto_xy	POSx,POSy	; Vai para nova possicao
			 mov 		ah, 08h	; Guarda o Caracter que esta na posicao do Cursor
			 mov		bh,0		; numero da pagina
			 int		10h
			 mov		cimas, al	; Guarda o Caracter que esta na posicao do Cursor
			 inc    	POSy
			 goto_xy	POSx,POSy
			 jmp flagc
			 
			
;verifica Esquerda
flage:
				cmp 	al, 'F'
				je 		fim_jogo
				cmp  	al, 20h ; O al ja vem com a letra
				jne   	CICLO
				dec 	POSx		;esquerda
				jmp		CICLO


verifica_esquerda:
			 dec 		POSx
			 goto_xy	POSx,POSy	; Vai para nova possicao
			 mov 		ah, 08h	; Guarda o Caracter que esta na posicao do Cursor
			 mov		bh,0		; numero da pagina
			 int		10h
			 mov		esquerdas, al	; Guarda o Caracter que esta na posicao do Cursor
			 inc    	POSx
			 goto_xy	POSx,POSy
			 jmp flage

			
;verifica DIREITA
flagd:
				cmp 	al, 'F'
				je 		fim_jogo ; Mudei de menu para fim de jogo
				cmp  	al, 20h ; O al ja vem com a letra ' ' comparar com o espaco
				jne   	CICLO
				inc 	POSx		;direita
				jmp		CICLO


verifica_direita:
			 inc 		POSx
			 goto_xy	POSx,POSy	; Vai para nova possicao
			 mov 		ah, 08h	; Guarda o Caracter que esta na posicao do Cursor
			 mov		bh,0		; numero da pagina
			 int		10h
			 mov		cimas, al	; Guarda o Caracter que esta na posicao do Curso
			 dec    	POSx
			 goto_xy	POSx,POSy
			 jmp flagd
			 
			 
			 
			 
;########################################################################			 
;########################################################################	

;Fucao fim de jogo
fim_jogo:

	
	
	call Ler_TEMPOd

	call apaga_ecran

	mov bx,3600
	mov cx,60
	mov ax,Horas
	
	mul bx
	mov Horas,ax
	mov ax,Minutos
	mul cx
	mov Minutos,ax
	
	mov ax,Segundos
	add ax,Horas
	add ax,Minutos
	mov segundos,ax
	
	mov ax,Hora
	
	mul bx
	mov Hora,ax
	mov ax,Minuto
	mul cx
	mov Minuto,ax
	
	mov ax,Segundo
	add ax,Horas
	add ax,Minuto
	mov segundo,ax
	
	mov bx,segundos
	
	sub ax,bx
	
	mov tempo,ax
	


	
	xor si,si
	mov bx,10
	
	
	
divisao:
	xor dx,dx
	div bx
	add dl,30h
	mov STR12[si],dl
	inc si
	
	cmp ax,0
	jne divisao

	mov contador,si
	add contador,1
	xor di,di
	
	mov al,STR12[si]
	mov STR10[di],al
	copia:
	inc di
	dec si
	mov al,STR12[si]
	mov STR10[di],al
	cmp si,0
	jne copia
	
	
	
	mov AH,09H
	lea DX,FRASE1
	int 21H
	
	mov AH,09H
	lea DX,STR10
	int 21H
	
	jmp Cria_ficheiro
	
			

	;jmp Cria_ficheiro
	

jmp menu

;########################################################################			 
;########################################################################	

;********************************************************************************
;********************************************************************************
; HORAS  - LE Hora DO SISTEMA E COLOCA em tres variaveis (Horas, Minutos, Segundos)
; CH - Horas, CL - Minutos, DH - Segundos
;********************************************************************************	

Ler_TEMPO PROC	
 
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
	
		PUSHF
		
		MOV AH, 2CH             ; Buscar a hORAS
		INT 21H                 
		
		XOR AX,AX
		MOV AL, DH              ; segundos para al
		mov Segundos, AX		; guarda segundos na variavel correspondente
		
		XOR AX,AX
		MOV AL, CL              ; Minutos para al
		mov Minutos, AX         ; guarda MINUTOS na variavel correspondente
		
		XOR AX,AX
		MOV AL, CH              ; Horas para al
		mov Horas,AX			; guarda HORAS na variavel correspondente
 
		POPF
		POP DX
		POP CX
		POP BX
		POP AX
 		RET 
Ler_TEMPO   ENDP 


;########################################################################			 
;########################################################################		

;********************************************************************************
; HORAS  - LE Hora DO SISTEMA E COLOCA em tres variaveis (Horas, Minutos, Segundos)
; CH - Horas, CL - Minutos, DH - Segundos
;********************************************************************************	

Ler_TEMPOd PROC	
 
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
	
		PUSHF
		
		MOV AH, 2CH             ; Buscar a hORAS
		INT 21H                 
		
		XOR AX,AX
		MOV AL, DH              ; segundos para al
		mov Segundo, AX		; guarda segundos na variavel correspondente
		
		XOR AX,AX
		MOV AL, CL              ; Minutos para al
		mov Minuto, AX         ; guarda MINUTOS na variavel correspondente
		
		XOR AX,AX
		MOV AL, CH              ; Horas para al
		mov Hora,AX			; guarda HORAS na variavel correspondente

		POPF
		POP DX
		POP CX
		POP BX
		POP AX
 		RET 
Ler_TEMPOd   ENDP 


; ############################################################
				;editar Labirinto
; ############################################################
editar_lab:
		mov		ax, dseg
		mov		ds,ax
		mov		ax,0B800h
		mov		es,ax
		
		call		apaga_ecran
		
	dec		POSy		; linha = linha -1
	dec		POSx		; POSx = POSx -1

CICL:	goto_xy	POSx,POSy
IMPRIM:	mov		ah, 02h
		mov		dl, Car
		int		21H		
	
		
	goto_xy	POSx,POSy
		
		
		call 	LE_TECLA
		cmp		ah, 1
		je		ESTEN
		CMP 	AL, 27		; ESCAPE
		JE		menu

ZERO:	CMP 	AL, 48		; Tecla 0
		JNE		UM
	lala:mov	Car, 32		;ESPAÇO
		jmp		CICL					
		
UM:		CMP 	AL, 49		; Tecla 1
		JNE		DOIS
		mov		Car, '#'		;Caracter CHEIO
		jmp		CICL		
	
DOIS:	CMP 		AL, 50		; Tecla 2
		JNE		TRES
		mov		Car, 'F' ;CINZA 177
		jmp		CICL	
		
TRES:	CMP 		AL, 51		; Tecla 3
		JNE		QUATRO
		cmp 	conf,1
		je		lala
		mov		Car, 'I'		
		inc 	conf
		jmp		CICL
		
QUATRO:	CMP 	AL, 52		; Tecla 4
		JNE		NOVE
		mov		Car, 176		;CINZA 176
		jmp		CICL
		
NOVE:		jmp		CICL
	
ESTEN:		
		cmp 	al,48h
		jne		BAIX
		cmp		POSy,1
		je 		cicl
		dec		POSy ;cima
		jmp		CICL

BAIX:	cmp		al,50h
		jne		ESQUERD
		cmp		POSy,20
		je 		cicl
		inc 	POSy		;Baixo
		jmp		CICL

ESQUERD:
		cmp		al,4Bh
		jne		DIREIT
		cmp		POSx,1
		je 		cicl
		dec		POSx		;Esquerda
		jmp		CICL

DIREIT:
		cmp		al,4Dh
		jne		CICL 
		cmp		POSx,40
		je 		cicl
		inc		POSx		;Direita
		jmp		CICL






; ############################################################
; ############################################################


; ############################################################
					;Funcao para escrever top 10
; ############################################################

; ############################################################
; ############################################################

Cria_ficheiro:	
	mov		ah, 3ch		; Abrir o ficheiro para escrita
	mov		cx, 00H		; Define o tipo de ficheiro ??
	lea		dx, Ficho	; DX aponta para o nome do ficheiro 
	int		21h			; Abre efectivamente o ficheiro (AX fica com o Handle do ficheiro)
	jnc		escreve		; Se não existir erro escreve no ficheiro
	
	mov		ah, 09h
	lea		dx, msgErrorCreate
	int		21h
	jmp		sai
	
	
escreve:
	mov		bx, ax		; Coloca em BX o Handle
	mov		ah, 40h		; indica que é para escrever
	lea		dx, STR10
	mov		cx, contador; CX fica com o numero de bytes a escrever
	int		21h
	jnc close
	
	;cmp si,0
	;jne caa
	;lea 	dx,buffer
	;mov 	cx,13
	;int 	21h
	;jnc		close	; Se não existir erro na escrita fecha o ficheiro

	
	
	mov		ah, 09h
	lea		dx, msgErrorWrite
	int		21h
	
close:
	mov		ah,3eh		; fecha o ficheiro(indica que vai fechar)
	int		21h			;fecha mesmo
	cmp si,0
	jnc		menu
	
	mov		ah, 09h
	lea		dx, msgErrorClose
	int		21h

;########################################################################			 
;########################################################################	



		
sai:
        mov     ah,4ch
        int     21h	


	
	
	
CODIGO	ENDS
END	INICIO




