
.. index: calldata layout

*******************
Diseño de los datos de llamadas
*******************

Se supone que los datos de entrada para una llamada a función están en el formato definido por 
:ref:`especificación ABI <ABI>`. Entre otros, la especificación ABI requiere que los argumentos 
se rellenen en múltiplos de 32 bytes. Las llamadas a funciones internas utilizan una convención diferente.

Los argumentos para el constructor de un contrato se anexan directamente al final del código del contrato, 
también en codificación ABI. El constructor accederá a ellos a través de un desplazamiento codificado, 
y no utilizando el opcode de codificación, ya que esto cambia por supuesto al anexar datos al código.

