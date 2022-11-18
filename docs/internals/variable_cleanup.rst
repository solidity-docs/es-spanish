.. index: variable cleanup

*********************
Limpieza de Variables
*********************

<<<<<<< HEAD
Cuando un valor es inferior que a 256 bits, en algunos casos se deben limpiar los
bits restantes.
El compilador Solidity está diseñado para limpiar los bits restantes antes de cualquier operacion
que pueda verse afectada negativamente por la basura potencial en los bits restantes.
Por ejemplo, antes de escribir un valor en la memoria, los bits restantes deben borrarse 
porque el contenido de la memoria se puede usar para calcular hashes o enviarse como datos de 
una llamada de mensaje. Del mismo modo, antes de almacenar un valor en el almacenamiento, 
es necesario limpiar los bits restantes porque de lo contrario se puede observar el valor ilegible.
=======
Ultimately, all values in the EVM are stored in 256 bit words.
Thus, in some cases, when the type of a value has less than 256 bits,
it is necessary to clean the remaining bits.
The Solidity compiler is designed to do such cleaning before any operations
that might be adversely affected by the potential garbage in the remaining bits.
For example, before writing a value to  memory, the remaining bits need
to be cleared because the memory contents can be used for computing
hashes or sent as the data of a message call.  Similarly, before
storing a value in the storage, the remaining bits need to be cleaned
because otherwise the garbled value can be observed.
>>>>>>> 0b4b1045cf3e78065f446714872926cde72e5135

Tenga en cuenta que el acceso a través del ensamblado en línea no se considera una operación de este tipo: 
Si utiliza un ensamblado en línea para acceder a variables de Solidity inferiores a 256 bits, 
el compilador no garantiza que el valor se limpie correctamente.

Además, no limpiamos los bits si la operación inmediatamente siguiente no se ve afectada.  
Por ejemplo, dado que cualquier valor distinto de cero se considera ``true`` por la instruccion ``JUMPI``, 
no limpiamos los valores booleanos antes de que se usen como condición para ``JUMPI``.

Además del principio de diseño anterior, el compilador Solidity limpia los datos de entrada cuando se cargan en la pila.

<<<<<<< HEAD
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
=======
The following table describes the cleaning rules applied to different types,
where ``higher bits`` refers to the remaining bits in case the type has less than 256 bits.

+---------------+---------------+-------------------------+
|Type           |Valid Values   |Cleanup of Invalid Values|
+===============+===============+=========================+
|enum of n      |0 until n - 1  |throws exception         |
|members        |               |                         |
+---------------+---------------+-------------------------+
|bool           |0 or 1         |results in 1             |
+---------------+---------------+-------------------------+
|signed integers|higher bits    |currently silently       |
|               |set to the     |signextends to a valid   |
|               |sign bit       |value, i.e. all higher   |
|               |               |bits are set to the sign |
|               |               |bit; may throw an        |
|               |               |exception in the future  |
+---------------+---------------+-------------------------+
|unsigned       |higher bits    |currently silently masks |
|integers       |zeroed         |to a valid value, i.e.   |
|               |               |all higher bits are set  |
|               |               |to zero; may throw an    |
|               |               |exception in the future  |
+---------------+---------------+-------------------------+

Note that valid and invalid values are dependent on their type size.
Consider ``uint8``, the unsigned 8-bit type, which has the following valid values:

.. code-block:: none

    0000...0000 0000 0000
    0000...0000 0000 0001
    0000...0000 0000 0010
    ....
    0000...0000 1111 1111

Any invalid value will have the higher bits set to zero:

.. code-block:: none

    0101...1101 0010 1010   invalid value
    0000...0000 0010 1010   cleaned value

For ``int8``, the signed 8-bit type, the valid values are:

Negative

.. code-block:: none

    1111...1111 1111 1111
    1111...1111 1111 1110
    ....
    1111...1111 1000 0000

Positive

.. code-block:: none

    0000...0000 0000 0000
    0000...0000 0000 0001
    0000...0000 0000 0010
    ....
    0000...0000 1111 1111

The compiler will ``signextend`` the sign bit, which is 1 for negative and 0 for
positive values, overwriting the higher bits:

Negative

.. code-block:: none

    0010...1010 1111 1111   invalid value
    1111...1111 1111 1111   cleaned value

Positive

.. code-block:: none

    1101...0101 0000 0100   invalid value
    0000...0000 0000 0100   cleaned value
>>>>>>> 0b4b1045cf3e78065f446714872926cde72e5135
