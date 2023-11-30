***************************************
Cambios introducidos en Solidity v0.8.0
***************************************

Esta sección versa sobre los principales cambios introducidos en la versión 0.8.0 de Solidity.
Para ver la lista completa 
`registro de cambios de lanzamiento <https://github.com/ethereum/solidity/releases/tag/v0.8.0>`_.

Cambios silenciosos en la semántica
===================================

<<<<<<< HEAD
Esta sección enumera los cambios en los que el código existente cambia su comportamiento sin
que el compilador le notifique nada al respecto.

* Las operaciones aritmeticas se revertirán en underflow y overflow. Puede escribir ``unchecked { ... }`` para
  usar el comportamiento anterior del adaptador.
=======
This section lists changes where existing code changes its behavior without
the compiler notifying you about it.

* Arithmetic operations revert on underflow and overflow. You can use ``unchecked { ... }`` to use
  the previous wrapping behavior.
>>>>>>> english/develop

  Comprobar posibles problemas por overflow es bastante común, por lo que los hicimos predeterminados para
  aumentar la legibilidad del código, aunque eso signifique un ligero aumento del gas.

* ABI coder v2 está activado por defecto.

<<<<<<< HEAD
  Puede usar el comportamiento anterior con ``pragma abicoder v1;``.
  La directiva ``pragma experimental ABIEncoderV2;`` aún es válida, pero está obsoleta y no tiene ningún efecto.
  Si quiere ser explícitco, use ``pragma abicoder v2;``.
=======
  You can choose to use the old behavior using ``pragma abicoder v1;``.
  The pragma ``pragma experimental ABIEncoderV2;`` is still valid, but it is deprecated and has no effect.
  If you want to be explicit, please use ``pragma abicoder v2;`` instead.
>>>>>>> english/develop

  Tenga en cuenta que el ABI coder v2 admite más tipos que v1 y realiza más controles sanitarios en los inputs.
  ABI coder v2 encarece algunas llamadas de función y también puede hacer que algunas llamadas al contrato
  sean revertidas y que, sin embargo, no se revertirían con ABI coder v1, cuando contienen datos que no se ajustan a 
  los tipos de parámetros.

* La exponienciación es asociativa a derechas, por ejemplo, la expresión ``a**b**c`` es analizada como ``a**(b**c)``.
  Antes de la versión 0.8.0, era analizada como ``(a**b)**c``.

  Esta es la forma común de analizar el operador de exponenciación.

* Los asserts y otras verificaciones inernas como la división por cero o el desbordamiento aritmético no usan el opcode
  invalid, en su lugar usan el opcode revert.  
  Más específicamente, usarán datos de erro equivalentes a una llamada a la función ``Panic(uint256)`` con un código de 
  error acorde a las circunstancias.

  Esto ahorrará gas en errores mientras que permite a las herramientas de análisis estático distinguir estas situaciones
  entre un revert y un input inválido, como por ejemplo un fallo en ``require``.  

* Si se accede a un byte array en el almacenamiento cuya longitud está codificada incorrectamente, se generará un panic.
  Un contrato no puede entrar en esta situación a menos que se use inline assembly para modificar la representación raw
  de los byte arrays del almacenamiento (storage)

* Si se usan constantes en expresiones de longitud de array, las versiones previas de Solidity usarían precisión 
  arbitraria en todas las ramas del arbol de decisiones. Ahora, is las variables constantes se usan como expresiones
  intermedias, sus valores serán propiamente redondeados de la misma forma que las expresiones en tiempo de ejecución.

* El tipo ``byte`` se ha eliminado. Era un alias de ``bytes1``.

Nuevas restriciones
================

Esta sección enumera los cambios que pueden ocasionar que los contratos existentes no vuelvan a compilar nunca.

<<<<<<< HEAD
* Hay nuevas restricciones relacionadas con conversiones explícitas de literales. El comportamiento anterior en
  los siguientes casos probablemente era ambiguo:
=======
* There are new restrictions related to explicit conversions of literals. The previous behavior in
  the following cases was likely ambiguous:
>>>>>>> english/develop

  1. Conversiones explícitas de literales negativos y literales mayores que ``type(uint160).max`` a
     ``address`` no están permitidas.
  2. Las conversiones explícitas entre literales y un tipo entero ``T`` solo se permiten si el literal
     se encuentra entre ``tipo(T).min`` y ``tipo(T).max``. En particular, reemplace los usos de ``uint(-1)``
     con ``tipo(uint).max``.
  3. Las conversiones explícitas entre literales y enumeraciones solo se permiten si el literal puede
       representan un valor del enumerado.
  4. Las conversiones explícitas entre literales y el tipo ``address`` (por ejemplo, ``dirección(literal)``) tienen el
    tipo ``address`` en lugar de ``address payable``. Se puede obtener un tipo de payable address utilizando una
    conversión explícita, es decir, ``payable(literal)``.

* :ref:`Address literals<address_literals>` tienen el tipo ``address`` en lugar de ``address
  payable``. Se pueden convertir a ``address payable`` usando una conversión explícita, por ejemplo
  ``payable(0xdCad3a6d3569DF655070DEd06cb7A1b2Ccd1D3AF)``.  

* Hay nuevas restricciones en las conversiones de tipos explícitos. La conversión sólo se permite cuando hay
  como máximo un cambio de signo, tamaño o la categoría de tipo (``int``, ``address``, ``bytesNN``, etc.).
  Para realizar varios cambios, utilice varias conversiones.  

  Use la notación ``T(S)`` para denotar la conversión explícita ``T(x)``, donde, ``T`` y
  ``S`` son tipos, y ``x`` es cualquier variable arbitraria de tipo ``S``. Un ejemplo de tal
  conversión no permitida sería ``uint16(int8)`` ya que cambia el tamaño (8 bits a 16 bits)
  y signo (entero con signo a entero sin signo). Para hacer la conversión, tiene que ir
  a través de un tipo intermedio. En el ejemplo anterior, sería ``uint16(uint8(int8))`` o
  ``uint16(int16(int8))``. Tenga en cuenta que las dos formas de convertir producirán resultados 
  diferentes, por ejemplo, para ``-1``. Los siguientes son algunos ejemplos de conversiones que no 
  están permitidas por esta regla.

  - ``address(uint)`` y ``uint(address)``: conversión simultanea de la categoría del tipo y tamaño. Reemplace esto por
    ``address(uint160(uint))`` y ``uint(uint160(address))`` respectivamente..
  - ``payable(uint160)``, ``payable(bytes20)`` y ``payable(integer-literal)``: conversión simultanea de la 
    categoría del tipo and estado de la mutabilidad. Reemplace esto por ``payable(address(uint160))``,
    ``payable(address(bytes20))`` y ``payable(address(integer-literal))`` respectivamente. Tenga en cuenta que
    ``payable(0)`` es válido y no es una excepción de la regla.
  - ``int80(bytes10)`` y ``bytes10(int80)``: conversión simultanea de la categoría del tipo y signo. Reemplace esto por
    ``int80(uint80(bytes10))`` y ``bytes10(uint80(int80)`` respectivamente.
  - ``Contract(uint)``: conversión simultanea de la categoría del tipo y el tamaño. Reemplace esto por
    ``Contract(address(uint160(uint)))``.

  Estas conversiones fueron deshabilitadas para evitar ambiguedades. Por ejemplo, en la expresión ``uint16 x =
  uint16(int8(-1))``, el valor de ``x`` dependería de que conversión, el signo ó el ancho, se aplicará antes.

* Las opciones de llamada de función solo se pueden dar una vez, es decir, ``c.f{gas: 10000}{value: 1}()`` no es válido 
  y debe cambiarse a ``c.f{gas: 10000, value: 1}() ``.

* Las funciones globales ``log0``, ``log1``, ``log2``, ``log3`` y ``log4`` han sido eliminadas.
  
  Estas son funciones de bajo nivel que en gran parte se dejaron de utilizar. Se puede acceder a su comportamiento 
  desde el inline assembly.

<<<<<<< HEAD
* Las definiciones de ``enum`` no pueden contener más de 256 miembros.
=======
  These are low-level functions that were largely unused. Their behavior can be accessed from inline assembly.
>>>>>>> english/develop

  Esto hará que sea seguro asumir que el tipo subyacente en la ABI siempre sea ``uint8``.

* Las declaraciones con el nombre ``this``, ``super`` y ``_`` no están permitidas, con la excepción de
  funciones y eventos públicos. La excepción es hacer posible declarar interfaces de contratos
  implementados en lenguajes distintos a Solidity que permiten tales nombres de funciones.  

* Eliminada la compatibilidad con las secuencias de escape ``\b``, ``\f`` y ``\v`` en el código.
  Todavía se pueden insertar a través de carácteres de escapes hexadecimales, p. ``\x08``, ``\x0c`` y ``\x0b``, 
  respectivamente.  

* Las variables globales ``tx.origin`` y ``msg.sender`` tienen el tipo ``address`` en lugar de 
  ``address payable``. Se pueden convertir en ``address payable`` usando una conversión explícita,
  por ejemplo, ``payable(tx.origin)`` o ``payable(msg.sender)``.

  This change was done since the compiler cannot determine whether or not these addresses
  are payable or not, so it now requires an explicit conversion to make this requirement visible.

  Este cambio se realizó ya que el compilador no puede determinar si estas direcciones
  son payable ó no, por lo que ahora requiere una conversión explícita para cumplir este requisito.  

* La conversión explícita al tipo ``address`` siempre devuelve un tipo not-payable ``address``. En
  particular, Las siguientes conversiones explícitas tienen el tipo ``address`` en lugar de ``address
  payable``:

  - ``address(u)`` donde ``u`` es una variable de tipo ``uint160``. Se puede convertior ``u``
    en el tipo ``address payable`` usando dos conversiones explícitas, por ejemplo,
    ``payable(address(u))``.
  - ``address(b)`` donde ``b`` es una variable de tipo ``bytes20``. Se puede convertir ``b``
    en el tipo ``address payable`` usando dos conversiones explícitas, por ejemplo,
    ``payable(address(b))``.	
  - ``address(c)`` donde ``c`` es un contrato. Previamente, el tipo de retorno de esta conversión
    dependía si el contrato podía recibir Ether (bien por que tenía una función receive o bien por una
	función payable fallback). La conversión ``payable(c)`` tiene el tipo ``address
    payable`` y solamente está permitida cuando el contrato ``c`` puede recibir Ether. En general, siempre
    se puede convertir ``c`` en el tipo ``address payable`` usando la siguiente conversión explícita: 
	``payable(address(c))``. Tenga en cuenta que ``address(this)`` pertenece a la misma categoría que
	``address(c)`` y se aplican las misma reglas.

* El ``chainid`` incorporado en el inline assembly ahora se considera ``view`` en lugar de ``pure``.

* La negación unaria ya no se puede usar, solo para enteros con signo.

Cambios en el interface
=================

* La salida de ``--combined-json`` ha cambiado: Los campos JSON ``abi``, ``devdoc``, ``userdoc`` y
  ``storage-layout`` ahora son subobjetos. Antes de la versión 0.8.0 se usaban serializados como strings.

* El "legacy AST" ha sido eliminado (``--ast-json`` en el interfaz de linea de comandos ``legacyAST`` para el 
  standard JSON). Use "compact AST" (``--ast-compact--json`` para ``AST``) en su lugar.

* El antigüo informador (``--old-reporter``) ha sido eliminado.


Como actualizar su código
=========================

<<<<<<< HEAD
- Si confía en la aritmética subyacente, encuelva cada operación con ``unchecked { ... }``.
- Opcional: Si usa SafeMath o una librería similar, cambie ``x.add(y)`` a ``x + y``, ``x.mul(y)`` a ``x * y`` etc.
- Añada ``pragma abicoder v1;`` si quiere mantener el antiggüo codificador de ABI.
- Opcionalmente elimine ``pragma experimental ABIEncoderV2`` o ``pragma abicoder v2`` ya que es redundante.
- Cambie ``byte`` a ``bytes1``.
- Agregue conversiones de tipo explícitas intermedias si es necesario.
- Combine ``c.f{gas: 10000}{value: 1}()`` a ``c.f{gas: 10000, value: 1}()``.
- Cambie ``msg.sender.transfer(x)`` a ``payable(msg.sender).transfer(x)`` ó use una variable de almacenamiento de  
  tipo ``address payable``.
- Cambie ``x**y**z`` a ``(x**y)**z``.
- Use inline assembly reemplazando ``log0``, ..., ``log4``.
- Niegue los enteros sin signo restándolos del valor máximo del tipo y sumando 1 (por ejemplo ``type(uint256).max - x + 1``, 
  mientras se asegura que `x` no es cero)
=======
- If you rely on wrapping arithmetic, surround each operation with ``unchecked { ... }``.
- Optional: If you use SafeMath or a similar library, change ``x.add(y)`` to ``x + y``, ``x.mul(y)`` to ``x * y`` etc.
- Add ``pragma abicoder v1;`` if you want to stay with the old ABI coder.
- Optionally remove ``pragma experimental ABIEncoderV2`` or ``pragma abicoder v2`` since it is redundant.
- Change ``byte`` to ``bytes1``.
- Add intermediate explicit type conversions if required.
- Combine ``c.f{gas: 10000}{value: 1}()`` to ``c.f{gas: 10000, value: 1}()``.
- Change ``msg.sender.transfer(x)`` to ``payable(msg.sender).transfer(x)`` or use a stored variable of ``address payable`` type.
- Change ``x**y**z`` to ``(x**y)**z``.
- Use inline assembly as a replacement for ``log0``, ..., ``log4``.
- Negate unsigned integers by subtracting them from the maximum value of the type and adding 1 (e.g. ``type(uint256).max - x + 1``, while ensuring that ``x`` is not zero)
>>>>>>> english/develop
