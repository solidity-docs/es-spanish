.. index: variable cleanup

*********************
Cleaning Up Variables
*********************

Cuando un valor es inferior que a 256 bits, en algunos casos se deben limpiar los
bits restantes.
El compilador Solidity está diseñado para limpiar los bits restantes antes de cualquier operacion
que pueda verse afectada negativamente por la basura potencial es los bits restantes.
Por ejemplo, antes de escribir un valor en la memoria, los bits restantes deben borrarse 
porque el contenido de la memoria se puede usar para calcular hashes o enviarse como datos de 
una llamada de mensaje. Del mismo modo, antes de almacenar un valor en el almacenamiento, 
es necesario limpiar los bits restantes porque de lo contrario se puede observar el valor ilegible.

Tenga en cuenta que el acceso a través del ensamblado en línea no se considera una operación de este tipo: 
Si utiliza un ensamblado en línea para acceder a variables de solidez inferiores a 256 bits, 
el compilador no garantiza que el valor se limpie correctamente.

Además, no limpiamos los bits si la operación inmediatamente siguiente no se ve afectada.  
Por ejemplo, dado que cualquier valor distinto de cero se considera ``true`` por la instruccion ``JUMPI``, 
no limpiamos los valores booleanos antes de que se usen como condición para ``JUMPI``.

Además del principio de diseño anterior, el compilador Solidity limpia los datos de entrada cuando se cargan en la pila.

Los diferentes tipos tienen diferentes reglas para limpiar valores no válidos:

+---------------+------------------+-----------------------------+
|Tipo           |Valores Validos   |Valores no Válidos Significan|
+===============+==================+=============================+
|enum of n      |0 until n - 1     |exception                    |
|miembros       |                  |                             |
+---------------+------------------+-----------------------------+
|bool           |0 or 1            |1                            |
+---------------+------------------+-----------------------------+
|enteros con    |firmar palabras   |actualmente se envuelve      |       
|signo          |extendidas        |silenciosamente; en el futuro|
|               |                  |se producirán excepciones    |
|               |                  |                             |
|               |                  |                             |
|               |                  |                             |
|               |                  |                             |
|               |                  |                             |
+---------------+------------------+-----------------------------+
|enteros sin    |bits más altos    |actualmente se envuelve      |
|signo          |puestos a cero    |silenciosamente; en el futuro|
|               |                  |se producirán excepciones    |
|               |                  |                             |
+---------------+------------------+-----------------------------+
