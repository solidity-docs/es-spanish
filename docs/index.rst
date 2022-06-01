Solidity
========

Solidity es un lenguaje de alto nivel orientado a objetos, para implementar contratos inteligentes (smart contracts).
Los contratos inteligentes son programas que rigen el comportamiento de las cuentas dentro del ecosistema de Ethereum.

Solidity es un `lenguaje de llaves <https://en.wikipedia.org/wiki/List_of_programming_languages_by_type#Curly-bracket_languages>`_, diseñado para la Máquina Virtual de Ethereum (Ethereum Virtual Machine).
Está influenciado por los lenguajes de programación C++, Python y JavaScript.
Para más detalles sobre los lenguajes que han inspirado Solidity visita la sección :doc:`influencia de lenguajes <language-influences>`.

Solidity es estáticamente escrito, soporta herencia, librerías, y tipos complejos definidos por el usuario, entre otras características.

Con Solidity se pueden crear contratos para votaciones, financiación colectiva (crowdfunding), subastas a ciegas, y monederos (wallets) multifirma.

Al momento de desplegar un contrato, debes utilizar la versión más reciente de Solidity.
Aparte de casos excepcionales, solamente la última versión recibe `correciones de seguridad <https://github.com/ethereum/solidity/security/policy#supported-versions>`_.
Además, cambios importantes y nuevas funciones se introducen periódicamente.
Actualmente se utiliza el número de versión 0.y.z `para indicar estos rápidos cambios <https://semver.org/#spec-item-4>`_.

.. Advertencia::

  Solidity lanzó recientemente la versión 0.8.x, que introdujo varios cambios significantes.
  Asegúrese de leer :doc:`la lista completa de cambios <080-breaking-changes>`.

Ideas para mejorar Solidity o esta misma documentación son siempre bienvenidas, lea nuestra :doc:`guía de contribución <contributing>` para más detalles.

.. Nota::

  Puede descargar esta documentación como PDF, HTML o Epub haciendo click en el menú desplegable que se encuentra en la esquina inferior izquierda y seleccionando su formato preferido de descarga.

Para Comenzar
---------------

**1. Comprender los Conceptos Básicos de los Contratos Inteligentes**

Si usted es nuevo y todavía no está familiarizado con el concepto de los contratos inteligentes, le recomendamos iniciar con la sección "Introducción a los Contratos Inteligents", que cubre:

* :ref:`Un ejemplo sencillo de un contrato inteligente <simple-smart-contract>` escrito en Solidity.
* :ref:`Conceptos Básicos de las Cadenas de Bloques (Blockchain) <blockchain-basics>`.
* :ref:`La Máquina Virtual de Ethereum <the-ethereum-virtual-machine>`.

**2. Conozca Solidity**

Una vez que esté relacionado con los conceptos básicos, le recomendamos leer las secciones de :doc:`"Solidity con Ejemplos" <solidity-by-example>` y "Descripción del Lenguaje" para comprender los conceptos fundamentales del lenguaje.

**3. Instalar el Compilador de Solidity**

Hay distintas maneras de instalar el compilador de Solidity, simplemente elija su opción preferida y siga los pasos indicados en la :ref:`página de instalación <installing-solidity>`.

.. Nota::

  Puede probar algunos ejemplos de código directamente en su navegador con `Remix IDE <https://remix.ethereum.org>`_.
  Remix es un entorno de desarrollo integrado (IDE) basado en el navegador web, que permite a cualquier usuario escribir, desplegar y administrar contratos inteligentes de Solidity; sin la necesidad de instalar Solidity localmente.

.. Advertencia::

    Ya que el software está escrito por humanos, puede contener errores.
    Usted debe seguir e implementar las mejores prácticas de desarrollo de software establecidas al escribir sus contratos inteligentes.
    Esto incluye la revisión, pruebas, auditorías y la correcta validez del código.
    Algunas veces los usuarios de los contratos inteligentes tienen más confianza con el código que sus mismos autores; ya que las cadenas de bloques y los contratos inteligentes tienes sus respectivos problemas, se recomienda que lea la sección :ref:`security_considerations` antes de trabajar en el código de producción.

**4. Conocer Más**

Si desea obtener más información sobre la creación de aplicaciones descentralizadas en Ethereum, los recursos para desarrolladores de Ethereum pueden ayudarlo con más documentación general sobre Ethereum y una amplia selección de tutoriales, herramientas y marcos de desarrollo (frameworks).

Si tiene alguna duda o pregunta, puede intentar buscar consultas o respuestas en `Ethereum StackExchange <https://ethereum.stackexchange.com/>`_, o en nuetro `Canal de Gitter <https://gitter.im/ethereum/solidity/>`_.

.. _translations:

Traducciones
------------

La comunidad de contribuidores es la encargada de la traducción de esta documentación en diferentes lenguajes.
Por favor, tenga en cuenta que se tienen diversos grados de integridad y actualización.
La versión en Inglés es tomada como referencia.

Puede elegir entre distintos idiomas haciendo click en el menú desplegable que se encuentra en la esquina inferior izquierda y seleccionando su lenguaje preferido.

* `Francés <https://docs.soliditylang.org/fr/latest/>`_
* `Indonesio <https://github.com/solidity-docs/id-indonesian>`_
* `Persa <https://github.com/solidity-docs/fa-persian>`_
* `Japonés <https://github.com/solidity-docs/ja-japanese>`_
* `Coreano <https://github.com/solidity-docs/ko-korean>`_
* `Chino <https://github.com/solidity-docs/zh-cn-chinese/>`_

.. Nota::

  Recientemente se creó una nueva organización en GitHub y un flujo de trabajo para las traducciones, con el motivo de agilizar los esfuerzos de la comunidad.
  Por favor, consulte la `guía de traducción <https://github.com/solidity-docs/translation-guide>`_ para obtener información sobre cómo iniciar un nuevo idioma o contribuir en las traducciones de la comunidad.


:ref:`Índice de Palabras Clave <genindex>`, :ref:`Página de Búsqueda <search>`

.. toctree::
   :maxdepth: 2
   :caption: Basics

   introduction-to-smart-contracts.rst
   installing-solidity.rst
   solidity-by-example.rst

.. toctree::
   :maxdepth: 2
   :caption: Language Description

   layout-of-source-files.rst
   structure-of-a-contract.rst
   types.rst
   units-and-global-variables.rst
   control-structures.rst
   contracts.rst
   assembly.rst
   cheatsheet.rst
   grammar.rst

.. toctree::
   :maxdepth: 2
   :caption: Compiler

   using-the-compiler.rst
   analysing-compilation-output.rst
   ir-breaking-changes.rst

.. toctree::
   :maxdepth: 2
   :caption: Internals

   internals/layout_in_storage.rst
   internals/layout_in_memory.rst
   internals/layout_in_calldata.rst
   internals/variable_cleanup.rst
   internals/source_mappings.rst
   internals/optimizer.rst
   metadata.rst
   abi-spec.rst

.. toctree::
   :maxdepth: 2
   :caption: Additional Material

   050-breaking-changes.rst
   060-breaking-changes.rst
   070-breaking-changes.rst
   080-breaking-changes.rst
   natspec-format.rst
   security-considerations.rst
   smtchecker.rst
   resources.rst
   path-resolution.rst
   yul.rst
   style-guide.rst
   common-patterns.rst
   bugs.rst
   contributing.rst
   brand-guide.rst
   language-influences.rst
