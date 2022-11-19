.. index: variable cleanup

*********************
Limpieza de Variables
*********************

Cuando un valor es inferior que a 256 bits, en algunos casos se deben limpiar los
bits restantes.
El compilador Solidity está diseñado para limpiar los bits restantes antes de cualquier operacion
que pueda verse afectada negativamente por la basura potencial en los bits restantes.
Por ejemplo, antes de escribir un valor en la memoria, los bits restantes deben borrarse 
porque el contenido de la memoria se puede usar para calcular hashes o enviarse como datos de 
una llamada de mensaje. Del mismo modo, antes de almacenar un valor en el almacenamiento, 
es necesario limpiar los bits restantes porque de lo contrario se puede observar el valor ilegible.

En última instancia, todos los valores en el EVM se almacenan en palabras de 256 bits.
Por lo tanto, en algunos casos, cuando el tipo de un valor tiene menos de 256 bits, 
es necesario limpiar los bits restantes.
El compilador Solidity está diseñado para realizar tal limpieza antes de cualquier operación 
que pueda verse afectada negativamente por la basura potencial en los bits restantes.
Por ejemplo, antes de escribir un valor en la memoria, los bits restantes deben borrarse porque el contenido de la memoria se puede usar para calcular hashes o enviarse como datos de una llamada de mensaje. Del mismo modo, antes de almacenar un valor en el almacenamiento, los bits restantes deben limpiarse porque de lo contrario se puede observar el valor confuso.

Tenga en cuenta que el acceso a través del ensamblado en línea no se considera una operación de este tipo: 
Si utiliza un ensamblado en línea para acceder a variables de Solidity inferiores a 256 bits, 
el compilador no garantiza que el valor se limpie correctamente.

Además, no limpiamos los bits si la operación inmediatamente siguiente no se ve afectada.  
Por ejemplo, dado que cualquier valor distinto de cero se considera ``true`` por la instruccion ``JUMPI``, 
no limpiamos los valores booleanos antes de que se usen como condición para ``JUMPI``.

Además del principio de diseño anterior, el compilador Solidity limpia los datos de entrada cuando se cargan en la pila.

Los diferentes tipos tienen diferentes reglas para limpiar valores no válidos:

+---------------+------------------+-----------------------------+
|Tipo           |Valores Validos   |Valores no Válidos Significan|
+===============+==================+=============================+
|enum of n      |0 hasta n - 1     |excepción                    |
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

La siguiente tabla describe las reglas de limpieza aplicadas a diferentes tipos, 
donde ``bits superiores`` se refiere a los bits restantes en caso de que el tipo tenga menos de 256 bits.

+---------------+---------------+-------------------------+
|Type           |Valid Values   |Cleanup of Invalid Values|
+===============+===============+=========================+
|enum de n      |0 hasta n - 1  |produce una excepción    |
|miembros       |               |                         |
+---------------+---------------+-------------------------+
|bool           |0 o 1          |resulta in 1             |
+---------------+---------------+-------------------------+
|enteros        |bits superiores|actualmente, en silencio,|
|firmados       |establecidos en|se extiende a un valor   | 
|               |el bit con el  |valido, es decir todos   |
|               |signo          |los bits superiores se.  |
|               |               |establacen en el bit de  |
|               |               |signo; puede producir una|
|               |               |excepción en el futuro   |
+---------------+---------------+-------------------------+
|enteros no     |bits superiores|actualmente, en silencio,|
|firmados       |establecidos   |enmascara a un valorto a |
|               |a cero         |válido, es decir, todos  |
|               |               |los bits superiores      |
|               |               |establecen en cero; puede|
|               |               |producir una excepción en|
|               |               |el futuro                |
+---------------+---------------+-------------------------+

Tenga en cuenta que los valores válidos y no válidos dependen de su tamaño de tipo. 
Considere ``uint8``, el tipo de 8-bit sin signo, que tiene los siguientes valores válidos:

.. code-block:: none

    0000...0000 0000 0000
    0000...0000 0000 0001
    0000...0000 0000 0010
    ....
    0000...0000 1111 1111

Cualquier valor no válido tendrá los bits más altos establecidos en cero:

.. code-block:: none

    0101...1101 0010 1010   invalid value
    0000...0000 0010 1010   cleaned value

Para ``int8``, el tipo de 8-bit firmado, los valores válidos son:

Negativo

.. code-block:: none

    1111...1111 1111 1111
    1111...1111 1111 1110
    ....
    1111...1111 1000 0000

Positivo

.. code-block:: none

    0000...0000 0000 0000
    0000...0000 0000 0001
    0000...0000 0000 0010
    ....
    0000...0000 1111 1111

El compilador ``signextend`` el bit de signo, que es 1 para valores negativos y 0 para 
valores positivos, sobrescribiendo los bits superiores:

Negativo

.. code-block:: none

    0010...1010 1111 1111   valor inválido
    1111...1111 1111 1111   valor limpiado

Positivo

.. code-block:: none

    1101...0101 0000 0100   valor inválido
    0000...0000 0000 0100   valor limpiado
