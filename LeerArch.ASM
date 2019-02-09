; ------------------------------------------------
; MICROPROCESADORES AVANZADOS
; ------------------------------------------------
; Autor: Daniel Gomez Jaramillo
; ------------------------------------------------
; Programa para leer el archivo CLAVE.TXT donde se
; carga el contenido a memoria y se accede a las 
; posiciones donde se encuentran los caracteres 
; cifrados y se les aplica un XOR para descifrarlos
; y mostrarlos por pantalla. Esta diseñado para
; mostrar 6 caracteres descifrados.
; ------------------------------------------------

;Funcion para imprimir el mensaje del caracter descifradp
imprimeDesc macro cadena
  XOR cadena, 62H
  mov ax,@data
  mov ds,ax
  mov ah,09
  mov dx,offset cadena
  int 21h
endm

.model small
.stack 100h
.data

  ;Mensajes a mostrar por pantalla

  msg db 10,13,7,'Cadena descifrada: ','$'

  ;Caracter descifrado a mostrar por pantalla

  caracter db ?, '$'
.code

Main proc
    
    ; Escribir el mensaje de inicio en la pantalla

    mov	ax, seg @data   
    mov	ds, ax
    mov	ah, 09h 
    lea	dx, msg 
    int	21h
    
    ; Proceso unico para la lectura del archivo, cargar a memoria su
    ; contenido y mostrar en pantalla los caracteres descifrados

    call LeerClaves 
    mov ah, 4ch 
    int 21h

Main endp

LeerClaves proc near

  ;Poner el nombre del archivo en memoria, CLAVE.TXT
                
  MOV ax,4C43H
  mov bx,0300H
  mov [bx],ax
  mov ax,5641H
  mov bx,0302H
  mov [bx],ax
  mov ax,2E45H
  mov bx,0304H
  mov [bx],ax
  mov ax,5854H
  mov bx,0306H
  mov [bx],ax
  mov ax,0054H
  mov bx,0308H
  mov [bx],ax
                
  ;Apertura del archivo

  mov AH,3DH      
  mov AL,0H       
  mov DX,0300H  
  int 21h

  ;Leer el archivo

  mov bx,ax
  mov AH,3FH 
  mov CX,03E8H ; Bytes a leer
  mov DX,0500H ; Poner el contenido desde la direccion 0500H
  int 21h

  ;Cierre del archivo
  mov ah,3EH   
  int 21h                               

  ;(Posicion 22 en cada linea + salto de linea (al principio del archio), caracteres cifrados cada 23 caracteres)
        
  ;Primer caracter

  mov bx,0516H; caracter en la posicion de memoria
  mov al, [bx]
  mov caracter, al
  imprimeDesc caracter

  ;Segundo caracter

  mov bx,052DH; caracter en la posicion de memoria
  mov al, [bx]
  mov caracter, al
  imprimeDesc caracter

  ;Tercer caracter

  mov bx,0544H; caracter en la posicion de memoria
  mov al, [bx]
  mov caracter, al
  imprimeDesc caracter

  ;Cuarto caracter

  mov bx,055BH; caracter en la posicion de memoria
  mov al, [bx]
  mov caracter, al
  imprimeDesc caracter

  ;Quinto caracter

  MOV bx,0572H; caracter en la posicion de memoria
  mov al, [bx]
  mov caracter, al
  imprimeDesc caracter

  ;Sexto caracter

  MOV bx,589H; caracter en la posicion de memoria
  mov al, [bx]
  mov caracter, al
  imprimeDesc caracter

  mov ah,4CH
  int 21H
LeerClaves endp   
end