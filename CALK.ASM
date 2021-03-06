my_stack	SEGMENT	stack
		dw	256 dup(?)	
my_stack	Ends
;----------------------------------------
DivBCD	macro	mem1,mem2,len
;������� BCD-�ᥫ
;१����:
;��⭮� ����頥��� � ���� ���࠭�,
;���⮪ - �� ��ன ���࠭�
	mov	di,offset mem1
	mov	si,offset mem2
	mov	cx,len
	call	DivBCDp
	endm
;------------------------------
data		SEGMENT
Number1		db	5 dup(-1);������ ��� 1 �᫠
log		db	1 dup(0)
Number2		db	5 dup(-1);           
user		db	12,?,'             '
sum		db	6 dup(-1) ;3
Subs		db	5 dup(-1)
Proizv		db	10 dup(0);-1
Len1		db	1 dup(0)
Len2		db	1 dup(0)
LogCOunt	db	1 dup(0);' '
bbx		db	1 dup(0)
bsi		db	1 dup(0)
bcx		db	1 dup(0)
Buf		db	' $';
buffer		db	512 dup(?)
tabl		db	'0123456789'
numdiv		db	5 dup(-1); �������⥫쭠� ������ ��� �������
tit		db	'                       * ���⥩訩 �������� *'
		db	13,10,'   ��䬥��᪨� ����樨 ��� ��㯠���뭭��� BCD-�᫠��,  (Limit = 5 ���).'
		db	13,10,'                           ��室 <Ctrl+C>!$'
EnterForm	db	13,10,'> ������ ��ࠦ����: $'
OkMes		db	13,10,'۲����Ĵ�⢥� = $'
ErrMes		db	13,10,'*�����������Ď訡�� � ��ࠦ����������������* $'
ErLimit		db	13,10,'(*)��͵���Ď訡��. �ਢ�襭�� ����� (� �᫥ > 5-� ���)! $'
DivOnNil	db	13,10,'(*)��͵���Ď訡��. ������� �� ����!$'
data		Ends
code		segment
		assume	cs:code,ds:data,es:data;ss:my_stack
;===============================================
SubBCDp	proc
;��楤�� ���⠭�� BCD-�ᥫ
	push	ax	;��࠭�� �����塞� ॣ�����
	push	di
	push	si
	push	cx
	std		;��稭��� � ������ ࠧ�冷�
	clc		;���㫨� ���祭�� ��७��
_sub_:
	lodsb		;���쬥� ��।��� ����
	sbb	[di],al	;���⠭�� � ��⮬ ��७��
	mov	al,[di]
	aas		;��஢�塞 � �ଠ� BCD-�ᥫ
	stosb		;��࠭�� १����
	loop	_sub_
	pop	cx	;����⠭���� ॣ�����
	pop	si
	pop	di
	inc	di
	pop	ax
	ret ;������
	endp
SubInvBCDp	proc
;�ᯮ����⥫쭠� ��楤�� ��� ����樨 �������
;�ந������ �맮� ��楤��� ���⠭��
;��� ��砫쭮� ���樠����樨
	push	si
	push	di
	add	si,cx
	dec	si
	add	di,cx
	dec	di
	call	SubBCDp
	pop	di
	pop	si
	ret
	ENDP
CmpBCDp	proc
;��楤�� �ࠢ����� BCD-�ᥫ
;CF=0, �᫨ [si]>[di], ���� CF=1
	push	ax
	push	di
	push	si
	push	cx
	cld
_cmp_:
	lodsb
	cmp	al,[di]
	jl	_less_
	jg	_greater_
	inc	di
	loop	_cmp_
_less_:
	stc
	jc	_cmp_q_
_greater_:
	clc
_cmp_q_:
	pop	cx
	pop	si
	pop	di
	pop	ax
	ret
	endp
PrepareForDiv	proc
;��楤�� ���樠����樨 ����
;��� ����樨 �������
	cld
;0,[di] -> buffer (���� ���࠭� � ����)
	push	di
	push	si
	push	di
	pop	si
	mov	di,offset buffer
	xor	al,al
	push	cx
	stosb
	rep	movsb
;0,[si] -> buffer (��ன ���࠭� � ����)
	pop	cx
	stosb
	pop	si
	push	cx
;��� ��砫� ������ ����� ������� ����
_find_:
	lodsb
	dec	cx
	cmp	al,0
	je	_find_
	dec	si
	inc	cx
	mov	dx,cx
	rep movsb
	pop	cx
	push	cx
; 0,0..0 -> buffer (������ ���� ��� १���� � ����)
	xor	al,al
	rep	stosb
;��७����祭�� ॣ���஢
	mov	di,offset buffer
	pop	cx
	mov	si,di
	inc	cx
	add	si,cx
	pop	bx
	ret
	endp
DivBCDp	proc
;��楤�� ������� BCD-�ᥫ
	push	ax	;��࠭�� �����塞� ॣ�����
	push	bx
	push	di
	push	si
	push	cx
	push	di
	call	PrepareForDiv	;�����⮢�� ����
	xor	ax,ax	;� al - ��।��� ��� १����
			;� ah - ������⢮ ��� � १����
	call	CmpBCDp
	jnc	_next_1_
_div_:
	call	CmpBCDp
	jnc	_next_
	inc	al
	call	SubInvBCDp
	jmp	_div_
_next_:
	mov	[bx],al	;��࠭�� ��।��� ����
	inc	bx	;㬥��訬 ���冷� ��������
_next_1_:
	inc	di
	dec	cx
	xor	al,al
	inc	ah
	cmp	cx,dx	;�ࠢ��� ���浪� �������� � ����⥫�
	jne	_div_
	dec	ah
	pop	di
	pop	cx
	push	cx
;����뫠�� १���� �� ���� � ���࠭��
	push	bx
	push	si
	push	ax
	push	di
;	mov	bx,0
	mov	si,0
ssn:	mov	number1[bx+si],-1
	inc	si
	mov	ax,si
	add	ax,bx
	cmp	ax,cx
	jb	ssn
	call	addnuldiv
	pop	bx
	pop	si
	pop	di
	pop	ax	
	mov	si,di
	add	di,cx
	push	cx
	mov	cl,ah
	add	si,cx
	dec	si
	dec	di
	std
	rep	movsb
	pop	cx
	sub	cl,ah
	xor	al,al
rep	stosb
	pop	cx
	pop	si
	push	si
	push	cx
	mov	di,si
	mov	si,offset buffer
	inc	si
	cld
rep	movsb
	pop	cx	;����⠭���� ॣ�����
	pop	si
	pop	di
	pop	bx
	pop	ax
	ret
	endp
;-------------------------------------
REsetUSer	proc
;����塞 �� ��ࠬ����
   	 	mov	log,0
		mov	logCount,0
		mov	si,2
		mov	cx,0
		mov	cl,user+1
		mov	user+1,0
		cmp	cl,0
		je	EntFrm
ass:		mov	user+si,' ';-1
		inc	si
		loop	ass
		;cmp	si,cx
		;jb	ass
        	mov	si,0
snova:		mov	number1+si,-1
		mov	number2+si,-1
		inc	si
 		cmp	si,5
		jb	snova
	mov	si,0
	mov	di,0
	mov	bbx,0
	mov	bsi,0
	mov	bcx,0
	call	CleanUp
	jmp	ExitR
EntFrm:	jmp	EnterFrm
Exitr:               ret
REsetUSer	endp
summa	proc
;��楤�� �㬬� BCD -�ᥫ
	len	equ	5; ࠧ�來���� �ᥫ
	xor	bx,bx	;��頥� bx
	mov	cx,len
	xor	ah,ah
	mov	dx,0
m1C:
	mov	al,number1[bx]
	cmp	al,-1
	jne	mn1
	inc	bx
	loop	m1C
mn1:	cmp	al,0
m1:
	mov	al,number1[bx]
CFE:	adc	al,number2[bx]    ;᫮����� � ���⮬ ��७��
	aaa      	;���४��
Mcf:	mov	sum[bx],al
nxt:	inc	bx
	loop	m1
	adc	sum[bx],0
	adc	sum[bx],0
	ret
summa	endp
subtr	proc
;��楤�� ���⠭��
 	xor	ax,ax	
	lenS	equ	5	
	xor	bx,bx
	mov	cx,lenS
MsC:	mov	al,number1[bx]
	cmp	al,-1
	jne	msC1
	inc	bx
	loop	MsC
MsC1:
	cmp	al,0
ms1:
	mov	al,number1[bx]
	sbb	al,number2[bx]
	aas
	mov	subs[bx],al
nxts:	inc	bx
	loop	ms1
	jc	ms2;
	jmp	exits	
ms2:    	;��� ������ ���� ��� ����뢠�騩 ����⥫�� �᫠
ExitS:
	ret
subtr	endp
Len12	proc
;Procedure ����� 㧭��� 䠪����� ����� �ᥫ
        mov	si,0	
	mov	dl,0	;Length	Number1
	mov	dh,0	;Length	N2
ffnn:	mov	al,number1+si
	mov	ah,number2+si
	cmp	al,-1
	jne	ff1
ffn1:	cmp	ah,-1
	jne	ff2
ffn2:	inc	si
	cmp	si,5
	jb	ffnn
	jmp	exitL
ff1:	inc	dl
	jmp	ffn1
ff2:	inc	dh
	jmp	ffn2
ExitL:
	mov	len1,dl
	mov	len2,dh
	ret
Len12	endp
xchg12	proc
;��楤�� ������ number1 with number2
	mov	si,0
ecso:	mov	al,number2+si
	xchg	number1+si,al
	mov	number2+si,al
	inc	si
	cmp	si,5
	jb	ecso
	mov	si,0
	mov	al,0
	ret
xchg12	endp
multi	proc
	lenm	equ	5	;ࠧ��୮��� ᮬ����⥫� 1
	xor	bx,bx
	xor	si,si
	xor	di,di
	xor	dl,dl
	mov	cx,lenm	;� cx ����� �������襣� ᮬ����⥫� 1
	mov	dh,len2
	cmp	len1,dh
        jb	m1m2
m1m:	
	mov	al,Number1[si]
	cmp	al,-1
	jne	mm1c
	inc	si
	loop	m1m
mm1c:	cmp	al,0; c������ 䫠��
	mov	bcx,cl
	mov	cx,si
	mov	di,si
	mov	bsi,cl
	mov	cl,bcx
mm1:    
	cmp	number2[di],-1
	je	n2ffdi
	mov	al,Number1[si]
	mul	number2[di]
	aam		;���४�� 㬭������
	adc	al,dl	;�竨 �।��騩 ��७��
	aaa	;᪮�४�஢��� १���� ᫮����� � ��७�ᮬ
	add	al,proizv[bx]
	aaa
	mov	proizv[bx],al
	mov	dl,ah	; ��������� ��७��
	inc	si
	inc	bx
	loop mm1
	jmp	nextmul
;-------------------------
n2ffdi:	inc	di
	jmp	mm1;n2nfdi
;-------------------------
nextmul:inc	di
	mov	cl,bsi
	mov	si,cx
	mov	proizv[bx],dl	;�竨 ��᫥���� ��७��
	mov	cl,bcx
	mov	bl,bbx
	inc	bx
	mov	bbx,bl
	mov	dl,0
	cmp	di,5
	jb	mm1
	jmp	MExit
;====================================
m1m2:	call	xchg12
        jmp	m1m
Mexit:
	ret
multi	endp
dive	proc
;�������, ����筠� ��楤��
	mov	ax,0
	mov	dx,0
	xor	bx,bx
	DivBCD	number1,number2,5
	ret
dive	endp
Divprint	proc
;��� ����� �뢮��� �� ��࠭ १���� �������
	lea	bx,tabl
	mov	cx,5
	mov	di,0
	mov	ah,9
	lea	dx,OkMes
	int	21h	
agd1:	cmp	number1+di,-1
	je	mxx1 ;�ய�᪠�� �� FF
	mov	al,number1+di
	xlat
	mov	buf,al        ;print
		lea	dx,buf
		int	21h
mxx1:	inc	di	
	loop	agd1
;---------------------------------------
;�஡��� �᫮
	call	Addz2	
	divBCD	number1,numdiv,5 ;��� ࠧ �����, �⮡� 㧭��� ���⮪
	call	delnul
	mov	si,4
go:	cmp	number1+si,0
	je	dddel
	jmp	extt
asss:	dec	si
	cmp	si,0
	jne	go
	jmp	extt
dddel:	mov	number1+si,-1
	jmp	asss
extt:
	mov	si,0
	mov	ah,0;schechik -1
	mov	cx,5
axtr:	cmp	number1+si,-1
	je	est
dali:	inc	si
	loop	axtr
	jmp	exxf
est:	inc	ah
	jmp	dali
exxf:	cmp	ah,5
	jne	quit1
	mov	number1,0	
quit1:	mov	ah,9
	mov	buf,'.'
	lea	dx,buf
	int	21h
	mov	cx,5
	mov	di,0
agd2:	cmp	number1+di,-1
	je	mxx2
	mov	al,number1+di
	xlat
	mov	buf,al        ;print ���⮪
		lea	dx,buf
		int	21h
mxx2:	inc	di	
	loop	agd2
quit2:
		ret
DivPrint	Endp
print	proc
;�᭮���� ��楤�� ����
	cmp	log,'+'
	je	adding
	cmp	log,'-'
	je	subing
	cmp	log,'*'
	je	muling
	cmp	log,'/'
	je	diving
diving:
call	divPrint
	jmp	exitp
muling:  lea	bx,tabl
	mov	cx,10
	mov	di,9
	mov	si,0
	mov	ah,9
	lea	dx,OkMes
	int	21h
agm:	
	cmp	proizv+di,-1		;check	ff
	je	mxtts
	mov	al,proizv+di
	xlat
	mov	buf,al        ;print
		lea	dx,buf
		int	21h
;____________________________________	

mxtts:	inc	si
	dec	di
	loop	agm
	jmp	ExitP
subing:  lea	bx,tabl
	mov	cx,5
	mov	di,4
	mov	si,0
	mov	ah,9
	lea	dx,OkMes
	int	21h
ags:	
	cmp	subs+di,-1		;check	ff
	je	nxtts
	mov	al,subs+di
	xlat
	mov	buf,al        ;print
		lea	dx,buf
		int	21h
;____________________________________	
nxtts:	inc	si
	dec	di
	loop	ags
	jmp	ExitP
adding:
	lea	bx,tabl
	mov	cx,6
	mov	di,5
	mov	si,0
	mov	ah,9
	lea	dx,OkMes
	int	21h
ag:	
	cmp	sum+di,-1		;check	FF
	je	nxtt
	mov	al,sum+di
	xlat
	mov	buf,al        ;print
		lea	dx,buf
		int	21h
;____________________________________	
nxtt:	inc	si
	dec	di
	loop	ag
ExitP:
	ret
print	endp
Input	proc
;���� ������
	mov	dh,0
	mov	ah,0ah
	lea	dx,user
	int	21h
	ret
Input	endp
Extract	proc
;��楤�� �����祭�� �㦭�� ������
		mov	di,0
again1:		
		call	CheckN
		mov	al,user+2+di
		sub	al,30h
		mov	number1+di,al
		inc	di
;	   	cmp	di,user+1
		jmp	again1
n2:		
	mov	si,0
	cmp	di,6;3
	ja	errLimit
again2:	
		call	CheckN
		cmp	si,5;3
		je	errLimit
		mov	al,user+2+di
		sub	al,30h
		mov	number2+si,al
		inc	di
	inc	si
		mov	bh,0
		mov	bl,user+1
		cmp	di,bx
		jb	again2
		cmp	si,1
		je	sia
sian:		jmp	Minvert

sia:	;	mov	al,number2
	;	mov	number2+1,al
	;	mov	number2,0
		jmp	sian
ErrLimit:	
		mov	ah,9
		lea	dx,erLimit
		int	21h        ;�뢮� ᮮ�饭�� �� �訡��
                jmp	clean
	         	ret
Extract	endp
AddZero	proc
;���������� �㫥�
add122:  mov	si,0
Men:	mov	ah,number1+si
	mov	al,number2+si	
	cmp	ah,al
	jne	nerav
add12:  inc	si
	cmp	si,5
	jb	Men
	jmp	ExitAdd
nerav:  
	cmp	al,-1
	je	n2FF
nnF:	cmp	ah,-1
	je	n1ff
	jmp	add12
N2nf:	jmp	Add122
n2FF:   
	mov	di,0
alk:	cmp	di,4
	je	di4
	mov	bl,number2+di+1
obr:	mov	number2+di, bl
	inc	di
	cmp	di,4
	jna	alk
	jmp	N2nf;nnF
di4:	
	mov	bl,0	
        jmp	obr
n1FF:	mov	di,0
alk1:	cmp	di,4
	je	di41
	mov	bl,number1+di+1
obr1:	mov	number1+di, bl
	inc	di
	cmp	di,4
	jna	alk1
	jmp	n2nF
di41:	mov	bl,0	
        jmp	obr1
ExitAdd:
        ret
AddZero	endp
CheckN	proc
;�஢�ઠ �� �訡��
		cmp	user+2+di,'0'
		jb	nless
	 	cmp	user+2+di,'9'
		ja	nless
		jmp	exCheck	
nless:         	
		cmp	user+2+di,'+'
		je	dIO
		cmp	user+2+di,'-'
		je	dIO
		cmp	user+2+di,'*'
		je	dIO
		cmp	user+2+di,'/'
		je	dIO
Errr:		mov	ah,9
		lea	dx,errMEs
		int	21h
clean:		call	resetUSer
		jmp	EnterFrm
diO:	
		cmp	di,0
		je	Errr
		cmp	logCount,1
		je	Errr
          	mov	logCount,1
		mov	dl,user+2+di
		mov	log,dl
		inc	di
		jmp	n2
ExCheck:      	ret
checkN	endp
Invert	proc
;������� number1,2
	mov	si,0
	mov	di,4
sas:	mov	dh,number1+si
	mov	dl,number1+di
	mov	number1+si,dl
	mov	number1+di,dh	
	inc	si
	dec	di	
	cmp	si,di
	jne	sas
	mov	si,0
	mov	di,4
sas2:	mov	dh,number2+si
	mov	dl,number2+di
	mov	number2+si,dl
	mov	number2+di,dh	
	inc	si
	dec	di	
	cmp	si,di
	jne	sas2
	ret
Invert	endp
DelNul	proc
;�������� �㫥� ��� ����
	cmp	log,'-'
	je	dsubb
	cmp	log,'*'
	je	dmul
	cmp	log,'/'
	je	ddiv
        jmp	exitDel
dsubb:
	mov	si,4
nexts:	cmp	subs+si,0
        je	dels
	jmp     ExitDels
dels:	mov	subs+si,-1
	dec	si
	jmp	nexts
;---
exitdels:	cmp	subs+4,-1
	je	asas
	jmp	nxts1
asas:	cmp	subs+3,-1
	jne	nxts1
	mov	subs+4,0
nxts1:   jmp	exitdel
;---

dmul:
	mov	si,9
nextm:	cmp	proizv+si,0
        je	delm
	jmp     ExitDelm
delm:	mov	proizv+si,-1
	dec	si
	jmp	nextm
exitdelm:;	cmp	proizv+9,-1
;	je	asas1
;	jmp	nxts2
;asas1:	cmp	proizv+8,-1
;	jne	nxts1
;	mov	proizv+9,0
nxts2:   jmp	exitdel

;-------------------------------
ddiv:
	mov	si,0
n1del:	cmp	number1+si,0
	je	d1nul
	jmp	n2del	
d1nul:	mov	number1+si,-1
        inc	si
	cmp	si,5
	jb	n1del
;	jmp	n1del
	
n2del:	
	cmp	number1+4,-1
	je	rn1d
vzv1:	mov	si,0
n2dn:	cmp	number2+si,0
	je	d2nul
	jmp	ExitDel
d2nul:	mov	number2+si,-1
	inc	si
	cmp	si,5
	jb	n2dn
	cmp	number2+4,-1
	jne	ExitDel
	mov	number2+4,0
	jmp	ExitDel
rn1d:	mov	number1+4,0
	jmp	vzv1
ExitDEl:
	ret
DelNul	endp
AddNulDiv	proc
;���������� �㫥� ��� �������
		mov	bx,0
		mov	di,0		;index ff
		mov	si,0    	;schetchik
agadd:		cmp	number1+si,-1
		je	rvnFF
rvnnff:
		inc	si
		cmp	si,5
		jb	agadd
		jmp	nrvn
rvnFF:		inc	di
		jmp	rvnnff
nrvn:		;inc 	di
		cmp	di,0
		je	exit1
		mov	si,4
		mov	cx,5
kkadd:		cmp	number1+si,-1
		jne	nervn
		mov	number1+si,0
NaddNul:	dec	si

		loop	kkadd
		jmp	Exit1
nervn:		
		mov	al,number1+si
		mov  	bx,di
		add	bx,si
		mov	number1[bx],al
		mov     number1+si,0
		jmp	Naddnul
Exit1:
		mov	bx,0
		mov	di,0		;index ff
		mov	si,0    	;schetchik
		mov	ax,0
agadd2:		cmp	number2+si,-1
		je	rvnFF2
rvnnff2:
		inc	si
		cmp	si,5
		jb	agadd2
		jmp	nrvn2
rvnFF2:		inc	di
		jmp	rvnnff2
nrvn2:		cmp	di,0 	;�⮡� �� 㤮�� ��譨� ����
		je	exit2

		mov	si,4
		mov	cx,5
kkadd2:		cmp	number2+si,-1
		jne	nervn2
		mov	number2+si,0
NaddNul2:	dec	si
		loop	kkadd2
		jmp	Exit2
nervn2:		
		mov	al,number2+si
		mov  	bx,di
		add	bx,si
		mov	number2[bx],al
		mov     number2+si,0
		jmp	Naddnul2
Exit2:
                ret
AddNulDiv	endp
CLeanUp	proc
;���⪠
	mov	ax,0
	mov	bx,0
	mov	dx,0
	mov	cx,0
	mov	bp,0
	mov	si,0
scler:	mov	sum+si,-1
	inc	si
	cmp	si,7
	jb	scler
	mov	si,0
subc:	mov	subs+si,-1
	inc	si
	cmp	si,6
	jb	subc
	mov	si,0
mu:	mov	proizv+si,0
	inc	si
	cmp	si,11
	jb	mu
	mov	si,0
	mov	di,0
	mov	bbx,0
	mov	bsi,0
	mov	bcx,0
	ret
CleanUp	endp
copynum2	proc
;���. ��࠭�� number2 in numdiv
	mov	cx,5
	mov	si,0
sii:	mov	al,number2+si
	mov	numdiv+si,al
	inc	si
	loop	sii
	ret
copynum2	endp
AddZ2	proc
	mov	si,0
nn:	cmp	[number2+si],-1
	je	sinul
	jmp	exitdd
sinul:	mov	al,[number2+si+1]
	mov	[number2+si],al
	inc	si
	cmp	si,4
	jne	sinul
	mov	number2+4,0
	mov	si,0
	jmp	nn
exitdd:
	mov	si,0
	mov	cx,5
qqq:	mov	al,[number2+si]
	mov	number1+si,al
	inc	si
	loop	qqq
	mov	si,0
	mov	cx,0
	ret
AddZ2	endp
;************************************************
;����
begin:		mov	ax,Data
		mov	ds,ax
		mov	es, ax
	;Title
		mov	ah,9
        	lea	dx,tit
		int	21h
	;=========================
;����� �� ����
EnterFrm:	mov	ah,9
		lea	dx,EnterForm
		int	21h
		call	input
	              call	Extract
Minvert:	cmp	log,'/'
		je	divent
		call 	invert
		cmp	log,'*'
		je	asd
		call	AddZero
		cmp	log,'+'
		je	Msumma
		cmp	log,'-'
		je	Msubtr
		cmp	log,'*'
		je	Mmul
divent:		cmp	log,'/'
		je	Mdiv
msumma:		call	summa
		jmp	exit
Msubtr:		call	subtr
		jmp	exit
Mmul:		call	Multi
		jmp	exit
Mdiv:		cmp	number2,0
		je	DivNiL
Nextdiv:	call	AddNulDiv
		call	copynum2
		call	Dive
exit:		
		call	delNul
		call	print
		mov	ah,07h;������� ������ ������
		int	21h
	call	resetUser
	call	CleanUp
	jmp	EnterFrm
		mov	ah,4ch ;��室
		int	21h
asd:		call	Len12
		jmp	mmul
	;�஢�ઠ ������� �� ����
DivNil:		mov	si,0
		mov	cx,5
		mov	al,0; ����稪 0
		mov	ah,0; ���� <> 0
gocmp1:		cmp	number2+si,0
		je	rvnNil
		cmp	number2+si,-1
enff:		je	eff
		jmp	gocmp
eFF:		inc	ah
	        jmp	enff
gocmp:		inc	si
		loop	gocmp1
		jmp	errrr
rvnNil:		inc	al
		jmp	gocmp
errrr:		add	al,ah
		cmp	al,5
		je	ErrDiv
		jmp	NextDiv
ErrDiv:		
		mov	ah,9
		lea	dx,DivOnNil
		int	21h      ;�뢮� ᮮ�饭�� �� �訡�� �������
		call	resetuser
		call	CleanUp
		jmp	EnterFrm
code		ENDS
		END	begin