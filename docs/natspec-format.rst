.. _natspec:

##############
Formato NatSpec
##############

Los contratos de Solidity pueden usar una forma especial de comentarios para proveer
documentación valiosa para funciones, variables de retorno y más. Esta forma especial se denomina
Ethereum Natural Language Specification Format (NatSpec).

.. note::

  NatSpec se inspiró en `Doxygen <https://en.wikipedia.org/wiki/Doxygen>`_.
  Aunque usa comentarios y etiquetas al estilo Doxygen, no hay intención de mantener
  compatibilidad estricta con Doxygen. Por favor, examine cuidadosamente las etiquetas
  admitidas listadas abajo.

Esta documentación se segmenta en mensajes enfocados al desarrollador y mensajes al
usuario final. Es posible que estos mensajes se muestren al usuario final (el humano) al
momento que interactue con el contrato (i.e. firma de una transacción). 

Se recomienda que los contratos de Solidity estén completamente comentados usando NatSpec
para todas las interfaces públicas (todo en el ABI).

NatSpec incluye el formateo para comentarios que el autor del contrato inteligente usará, y
los cuales son entendidos por el compilador de Solidity. También se detalla debajo la salida 
del compilador de Solidity el cual extrae estos comentarios a un formato de datos legibles mediante máquina.

NatSpec también pudiese incluir anotaciones usadas por herramientas de terceros. Estas se logran 
muy probablemente por medio de la etiqueta ``@custom:<name>``, y un buen caso de uso es el análisis y las
herramientas de verificación.

.. _header-doc-example:

Ejemplo de Documentación
=====================

La documentación se inserta encima de cada ``contrato``, ``interfaz``, ``biblioteca``,
``función`` y ``evento`` usando el formato de notación Doxygen.
Una variable de estado ``pública`` es equivalente a una ``función`` para los propósitos de NatSpec.

-  Para Solidity puede optar ``///`` para comentarios de una línea o múltiples líneas, 
   o ``/**`` y finalizar con ``*/``.
   
Para Vyper, utilice ``"""`` sangrado al contenido interior con desnudo
   comentarios. Consulte la documentación de `Vyper
   documentación <https://vyper.readthedocs.io/en/latest/natspec.html>`__.

El siguiente ejemplo muestra un contrato y una función usando todas las etiquetas disponibles.

.. note::

  El compilador de Solidity solo interpreta etiquetas si son externas o públicas.
  Puede usar comentarios similares para sus funciones privadas e internas,
  pero no serán interpretados. 

  Esto podría cambiar en el futuro.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.2 < 0.9.0;

    /// @title Un simulador para árboles
    /// @author Larry A. Gardner
    /// @notice Puede usar este contrato solo para la simulación más básica
    /// @dev Todas las llamadas a funciones están actualmente implementadas sin efectos secundarios
    /// @custom:experimental Este es un contrato experimental.
    contract Tree {
        /// @notice Calcula la edad del árbol en años, redondeado hacia arriba, para los árboles vivos.
        /// @dev El algoritmo de Alexandr N. Tetearing podría incrementar la precisión
        /// @param rings El número de anillos de una muestra dendrocronológica
        /// @return Edad en años, redondeado hacia arriba para años parciales
        function age(uint256 rings) external virtual pure returns (uint256) {
            return rings + 1;
        }

        /// @notice Retorna la cantidad de hojas que tiene el árbol.
        /// @dev Retorna solamente un número fijo.
        function leaves() external virtual pure returns(uint256) {
            return 2;
        }
    }

    contract Plant {
        function leaves() external virtual pure returns(uint256) {
            return 3;
        }
    }

    contract KumquatTree is Tree, Plant {
        function age(uint256 rings) external override pure returns (uint256) {
            return rings + 2;
        }

        /// Retorna la cantidad de hojas que tiene este tipo específico de árbol
        /// @inheritdoc Tree
        function leaves() external override(Tree, Plant) pure returns(uint256) {
            return 3;
        }
    }

.. _header-tags:

Etiquetas
====

Todas las etiquetas son opcionales. La siguiente tabla explica el propósito de cada
etiqueta NatSpec y donde puede ser usada. Como caso especial, si ninguna etiqueta se usa,
entonces el compilador de Solidity interpretará un comentario con ``///`` o ``/**`` de 
la misma manera como si fuese etiquetado con ``@notice``.

=============== ====================================================================================== =============================
Etiqueta                                                                                               Contexto
=============== ====================================================================================== =============================
<<<<<<< HEAD
``@title``      Un título que debería describir el contrato o la interfaz                              contrato, biblioteca, interfaz
``@author``     El nombre del autor                                                                    contrato, biblioteca, interfaz
``@notice``     Explica a un usuario final lo que esto hace                                            contrato, biblioteca, interfaz, función, variable de estado pública, evento
``@dev``        Explica a un desarrollador cualquier detalle extra                                     contrato, biblioteca, interfaz, función, variable de estado pública, evento
``@param``      Documenta un parámetro como en Doxygen (debe ser seguida por un nombre de parámetro)   función, evento
``@return``     Documenta las variables de retorno de la función de un contrato                        función, variable de estado pública
``@inheritdoc`` Copia todas las etiquetas faltantes de la función base                                 función, variable de estado pública
                (debe ser seguida por el nombre del contrato)
``@custom:...`` Etiqueta personalizada, la semántica se define por la aplicación                       en todas partes
=======
``@title``      A title that should describe the contract/interface                                    contract, library, interface, struct, enum
``@author``     The name of the author                                                                 contract, library, interface, struct, enum
``@notice``     Explain to an end user what this does                                                  contract, library, interface, function, public state variable, event, struct, enum
``@dev``        Explain to a developer any extra details                                               contract, library, interface, function, state variable, event, struct, enum
``@param``      Documents a parameter just like in Doxygen (must be followed by parameter name)        function, event
``@return``     Documents the return variables of a contract's function                                function, public state variable
``@inheritdoc`` Copies all missing tags from the base function (must be followed by the contract name) function, public state variable
``@custom:...`` Custom tag, semantics is application-defined                                           everywhere
>>>>>>> english/develop
=============== ====================================================================================== =============================

Si su función retorna múltiples valores, como ``(int quotient, int remainder)``,
entonces use múltiples declaraciones ``@return`` en el mismo formato como las declaraciones ``@param``.

Las etiquetas personalizadas comienzan con ``@custom:`` y deben ser seguidas por una o más letras minúsculas o guiones.
Sin embargo, no pueden comenzar con un guion. Se pueden usar en todas partes y forman parte de la documentación del desarrollador.

.. _header-dynamic:

Expresiones dinámicas
-------------------

El compilador de Solidity pasará a través de la documentación de NatSpec desde su
código fuente Solidity hasta la salida JSON como se describe en esta guía. El consumidor
de esta salida JSON, por ejemplo el software cliente del usuario final, puede presentar esto al usuario final directamente
o podría aplicar algún preprocesamiento.

Por ejemplo, algún software cliente presentará: 

.. code:: Solidity

   /// @notice Esta función multiplicará `a` por 7

al usuario final como:

.. code:: text

    Esta función multiplicará 10 por 7

si una función es invocada y la entrada ``a`` se le asigna un valor de 10.

<<<<<<< HEAD
Específicamente estas expresiones dinámicas están fuera del alcance de la documentación de Solidity
y puede leer más en `el proyecto radspec <https://github.com/aragon/radspec>`__.

=======
>>>>>>> 0b4b1045cf3e78065f446714872926cde72e5135
.. _header-inheritance:

Notas de Herencia
-----------------

Las funciones sin NatSpec automáticamente heredarán la documentación de su función base.
Excepciones a esto son:

* Cuando los nombres de parámetros son diferentes.
* Cuando hay más de una función base.
* Cuando hay una etiqueta explícita ``@inheritdoc`` la cual especifica cuál contrato debería ser usado para heredar.

.. _header-output:

Salida de la Documentación
====================

Cuando se analiza por el compilador, la documentación como la del ejemplo de arriba
producirá dos archivos JSON diferentes. Se pretende que uno sea consumido por el usuario final
como un aviso cuando una función se ejecuta y el otro para ser usado por el desarrollador.

Si el contrato de arriba se guarda como ``ex1.sol``, entonces puede generar
la documentación usando:

.. code-block:: shell

   solc --userdoc --devdoc ex1.sol

Y la salida está abajo.

.. note::
    A partir de la versión de Solidity 0.6.11, la salida NatSpec también contiene un campo ``version`` y un ``kind``.
    Actualmente ``version`` está establecido en ``1`` y ``kind`` debe ser o ``user`` o ``dev``.
    En el futuro es posible que nuevas versiones sean introducidas, discontinuando viejas versiones.

.. _header-user-doc:

Documentación del Usuario
------------------

La documentación de arriba producirá el siguiente archivo JSON 
de la documentación del usuario como salida:

.. code-block:: json

    {
      "version" : 1,
      "kind" : "user",
      "methods" :
      {
        "age(uint256)" :
        {
          "notice" : "Calcula la edad del árbol en años, redondeado hacia arriba, para los árboles vivos"
        }
      },
      "notice" : "Puede usar este contrato solo para la simulación más básica"
    }

Note que la clave por la cual se encuentran los métodos es la signatura canónica de la función
como se define en el :ref:`Contract ABI <abi_function_selector>` y no simplemente el nombre de la función

.. _header-developer-doc:

Documentación del Desarrollador
-----------------------

Aparte del archivo de documentación del usuario, un archivo JSON de la documentación del desarrollador
también se debería producir y debería asemejarse a esto:

.. code-block:: json

    {
      "version" : 1,
      "kind" : "dev",
      "author" : "Larry A. Gardner",
      "details" : "Todas las llamadas a funciones están actualmente implementadas sin efectos secundarios",
      "custom:experimental" : "Este es un contrato experimental.",
      "methods" :
      {
        "age(uint256)" :
        {
          "details" : "El algoritmo de Alexandr N. Tetearing podría incrementar la precisión",
          "params" :
          {
            "rings" : "El número de anillos de una muestra dendrocronológica"
          },
          "return" : "Edad en años, redondeado hacia arriba para años parciales"
        }
      },
      "title" : "Un simulador para árboles"
    }
