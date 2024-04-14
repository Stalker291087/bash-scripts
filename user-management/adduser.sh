#!/bin/bash
## Codificacion UTF-8
## Autor: Jean Carlo Espinoza
## Contacto: jeancarloe01@hotmail.com
## Version: 0.1.0 
## **Instrucciones**

##Limpia la terminal
clear
##Verifica que el archivo "usuarios.txt" existe

if [ -f /home/cool_coding/Scripts/usuarios.txt ]
 then
  echo "Leyendo usuarios del archivo "usuarios.txt""
  
  usuarios=$(cat /home/cool_coding/Scripts/usuarios.txt)
  
  echo "Valor de la variable usuarios ($usuarios)"
 # for i in $usuarios
  # do
    # nombre_usuario=`echo $i | cut -f1`
     
    # useradd -s $nombre_usuario
 # done

  #echo "Usuarios agregados exitosamente"

else
 "No se encuentra el archivo "usuarios.txt", favor verifique que el archivo existe"

fi

#fin script
