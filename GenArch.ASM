; ------------------------------------------------
; MICROPROCESADORES AVANZADOS
; ------------------------------------------------
; Autor: Daniel Gomez Jaramillo
; ------------------------------------------------
; Programa para pedir caracteres por teclado, 
; cifrarlos con XOR y almacenar en un archivo cada 
; caracter cifrado junto con la fecha y hora en la 
; que fueron pulsados en el teclado.
; ------------------------------------------------

;Funcion para imprimir el mensaje de una variable
imprime macro cadena
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

    msg db 10,13,7,'Clave (6 digitos): ','$'
    ast db 10,13,'*','$'    

    ;Nombre del archivo
    
    archivo db 'CLAVE.TXT',0
    
    ;Caracter a ser leido por teclado

    clave db 100 dup(?)
    caracter db ?, '$'
    
    ;Caracteres y formatos para la fecha y archivo

    formato DB ?
    endl db 0dh,0ah
    espacio db 20h
    salto db 0
    handle dw ?

    ;Variables de fecha obtenidas por el sistema (formato original)

    horas db ?, '$'
    minutos db ?, '$'
    segundos db ?, '$'
    dia_semana db ?, '$'
    dia_mes db ?, '$'
    mes db ?, '$'
    anio dw ?, '$'     
    
    ;Variables axiliares para la fecha
    
    anio_dig1 db ?, '$'
    anio_dig2 db ?, '$'
    anio_dig3 db ?, '$'
    anio_dig4 db ?, '$'

    ;Variables de fecha en formato ASCII
    
    dia_mes_conv db ?, ?, 2fh,'$'
    mes_conv db ?, ?, 2fh, '$'
    anio_conv db ?, ?, '$'
    horas_conv db ?, ?, 3ah, '$'
    minutos_conv db ?, ?, 3ah, '$'
    segundos_conv db ?, ?, '$'

.code

Main proc
    
    ;Imprmir el mensaje clave
    mov	ax, seg @data   
    mov	ds, ax
    mov	ah, 09h 
    lea	dx, msg 
    int	21h

    mov	si, offset clave

    ;Formato del archivo:
    ; DD/MM/AAAA HH:MM:SS C
    ; donde C es el caracter cifrado


    ;Proceso unico donde se pide un caracter por teclado y se guarda en el archivo junto a la fecha
    call GuardarClave 
    mov ah, 4ch 
    int 21h

Main endp

GuardarClave proc near

    CrearArchivo:

        mov ax,@data  ;Carga del segmento para obtener el nombre del archivo
        mov ds,ax
        mov ah,3ch ;Creacion del archivo
        mov cx,0 
        mov dx,offset archivo ; Se crea el archivo con el nombre CLAVE.TXT 
        int 21h
        jc Finalizar ;Si no se pudo crear el archivo arroja un error, se captura con jc.
        mov bx,ax
        mov ah,3eh ;Cierre del archivo
        int 21h

    LeerCaracter:

        mov ah, 07H
        int 21H ; Leer 1 caracter
        cmp al, 13 ; En el caso de que se precione enter, finalizamos la lectura de la clave
        je      Finalizar
        mov     [caracter], al ;Caso contrario, guardar en la variable caracter lo leido             
        cmp al, 08h ; En caso de retroceso, seguir con la lectura
        je      LeerCaracter       
        
        mov ah, 0eh ; Mostrar el asterisco en la pantalla
        mov al, 2ah
        int 10h
    
    CalcularFecha:
       
        ;Calculo de la fecha
    
        ;Hora del sistema

        mov ah, 2Ch
        int 21h
        
        mov     [horas], ch
        mov     [minutos], cl
        mov     [segundos], dh
        
        ;Fecha del sistema

        mov ah, 2Ah
        int 21h
        
        mov     [dia_semana], al
        mov     [anio], cx
        mov     [mes], dh
        mov     [dia_mes], dl
        
        ;Conversion del dia a ASCII
        mov al, [dia_mes]
        mov cl, 10
        mov ah, 0
        div cl
        or ax, 3030h
        mov bx, offset dia_mes_conv
        mov     [bx], al
        inc bx
        mov     [bx], ah

        ;Mes
        mov al, [mes]
        mov cl, 10
        mov ah, 0
        div cl
        or ax, 3030h
        mov bx, offset mes_conv
        mov     [bx], al
        inc bx
        mov     [bx], ah
        
        ;Anio
        mov bx, offset anio
        mov ax, [bx]
        mov cl, 10
        div cl
        mov     anio_dig1, ah
        mov ah, 0
        mov cl, 10
        div cl
        mov     anio_dig2, ah
        mov ah, 0
        mov cl, 10
        div cl
        mov     anio_dig3, ah
        mov ah, 0
        mov cl, 10
        div cl
        mov     anio_dig4, ah
        or      anio_dig4, 30h
        or      anio_dig3, 30h
        or      anio_dig2, 30h
        or      anio_dig1, 30h

        ;Hora
        mov al, [horas]
        mov cl, 10
        mov ah, 0
        div cl
        or ax, 3030h
        mov bx, offset horas_conv
        mov     [bx], al
        inc bx
        mov     [bx], ah
        
        ;Minutos
        mov al, [minutos]
        mov cl, 10
        mov ah, 0
        div cl
        or ax, 3030h
        mov bx, offset minutos_conv
        mov     [bx], al
        inc bx
        mov     [bx], ah
        
        ;Segundos
        mov al, [segundos]
        mov cl, 10
        mov ah, 0
        div cl
        or ax, 3030h
        mov bx, offset segundos_conv
        mov     [bx], al
        inc bx
        mov     [bx], ah
        
        ;Apertura del archivo

        mov ah, 3dh
        mov al, 02h
        mov dx, offset archivo
        int 21h
        
        mov     handle, ax

        
    ;Escritura de los datos en el archivo
    Escribir:

        ;Indicar que se va a escribir al final del contenido del archivo

        mov bx, ax
        mov ah, 42h
        mov al, 2
        mov cx, 0
        mov dx, 0
        int 21h

        mov bx, handle 
        mov ah, 40h
        mov cx, 2
        mov dx, offset endl 
        int 21h

        ;Guardar el dia del mes en el archivo

        mov bx, handle 
        mov ah, 40h
        mov cx, 3
        mov dx, offset dia_mes_conv
        int 21h
        
        ;Guardar el mes en el archivo

        mov bx, handle 
        mov ah, 40h
        mov cx, 3
        mov dx, offset mes_conv
        int 21h
        mov bx, handle 
        mov ah, 40h
        mov cx, 1
        mov dx, offset anio_dig4
        int 21h

        ;Guardar el anio en el archivo

        mov bx, handle 
        mov ah, 40h
        mov cx, 1
        mov dx, offset anio_dig3
        int 21h
        mov bx, handle 
        mov ah, 40h
        mov cx, 1
        mov dx, offset anio_dig2
        int 21h
        mov bx, handle 
        mov ah, 40h
        mov cx, 1
        mov dx, offset anio_dig1
        int 21h

        ;Poner un espacio en el archivo

        mov bx, handle 
        mov ah, 40h
        mov cx, 1
        mov dx, offset espacio
        int 21h

        ;Guardar la hora en el archivo

        mov bx, handle 
        mov ah, 40h
        mov cx, 3
        mov dx, offset horas_conv
        int 21h

        ;Guardar los minutos en el archivo

        mov bx, handle 
        mov ah, 40h
        mov cx, 3
        mov dx, offset minutos_conv
        int 21h

        ;Guardar los segundos en el archivo

        mov bx, handle 
        mov ah, 40h
        mov cx, 2
        mov dx, offset segundos_conv
        int 21h
        
        ;Poner un espacio en el archivo

        mov bx, handle 
        mov ah, 40h
        mov cx, 1
        mov dx, offset espacio
        int 21h

        ;Cifrado del caracter a traves de XOR
        
        XOR [caracter], 62H
        ;imprime caracter

        ;Guardar el caracter cifrado en el archivo

        mov bx, handle 
        mov ah, 40h
        mov cx, 1
        mov dx, offset caracter
        int 21h

        ;Cerrar el archivo

        mov bx, handle
        mov ah, 3eh
        int 21h    

        ;-----

        ;Proceso para descifrar el caracrer cifrado (Se aplica nuevamente XOR):

        ;XOR [caracter], 62H
        ;imprime caracter        
        
        ;Se continua pidiendo caracteres por teclado:

        jmp     LeerCaracter
    
    Finalizar: 
        ret

GuardarClave endp   
end