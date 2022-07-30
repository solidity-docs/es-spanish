
.. index: memory layout

****************
Diseño en memoria
****************

Solidity reserva cuatro ranuras de 32 bytes, con rangos de bytes específicos (incluidos los extremos) que se utilizan 
de la siguiente manera:

- ``0x00`` - ``0x3f`` (64 bytes): espacio de memoria virtual para métodos hash
- ``0x40`` - ``0x5f`` (32 bytes): tamaño de memoria asignado actualmente (aka. puntero de memoria libre)
- ``0x60`` - ``0x7f`` (32 bytes): ranura cero

El memoria virtual se puede utilizar entre instrucciones (es decir, dentro de un assembly en línea). La ranura cero 
se utiliza como valor inicial para matrices de memoria dinámica y nunca debe escribirse en 
(el puntero de memoria libre apunta inicialmente a ``0x80`').

Solidity siempre coloca nuevos objetos en el puntero de memoria libre y 
la memoria nunca se libera (esto podría cambiar en el futuro).

Los elementos en matrices de memoria en Solidity siempre ocupan múltiplos de 32 bytes (esto 
es incluso cierto para ``bytes1[]``, pero no para ``bytes`` y ``string``). 
Las matrices de memoria multidimensionales son punteros a matrices de memoria. La longitud de 
una matriz dinámica se almacena en la primera ranura de la matriz y seguida de los elementos 
de la matriz.

.. warning::
  Hay algunas operaciones en Solidity que necesitan un área de memoria temporal 
  superior a 64 bytes y, por lo tanto, no cabe en el memoria virtual. Se colocarán donde 
  apunta la memoria libre, pero dado su corta duración, el puntero no se actualiza. Es posible 
  que la memoria se ponga a cero o no. Debido a esto, uno no debería esperar que la memoria libre 
  apunte a cero.

  Aunque puede parecer una idea buena usar ``msize`` para llegar a un área 
  de memoria puesta a cero definitivamente, el uso de tal puntero no-temporalmente 
  sin actualizar el puntero de memoria libre puede tener resultados inesperados.


Diferencias con el diseño en el almacenamiento
================================

Como se describió anteriormente, el diseño en la memoria es diferente del diseño 
en :ref:'storage<storage-inplace-encoding>'. A continuación hay algunos ejemplos.

Ejemplo de diferencia en matrices
--------------------------------

La siguiente matriz ocupa 32 bytes (1 ranura) en almacenamiento, pero 128 
bytes (4 elementos con 32 bytes cada uno) en memoria.

.. code-block:: solidity

    uint8[4] a;



Ejemplo de diferencia en el diseño de estructura
---------------------------------------

La siguiente estructura ocupa 96 bytes (3 ranuras de 32 bytes) en almacenamiento, 
pero 128 bytes (4 elementos con 32 bytes cada uno) en memoria.


.. code-block:: solidity

    struct S {
        uint a;
        uint b;
        uint8 c;
        uint8 d;
    }
