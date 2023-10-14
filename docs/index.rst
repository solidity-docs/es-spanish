Solidity
========

<<<<<<< HEAD
Solidity es un lenguaje de alto nivel orientado a objetos, para implementar contratos inteligentes (smart contracts).
Los contratos inteligentes son programas que rigen el comportamiento de las cuentas dentro del ecosistema de Ethereum.

Solidity es un `lenguaje de llaves <https://en.wikipedia.org/wiki/List_of_programming_languages_by_type#Curly-bracket_languages>`_, diseñado para la Máquina Virtual de Ethereum (Ethereum Virtual Machine).
Está influenciado por los lenguajes de programación C++, Python y JavaScript.
Para más detalles sobre los lenguajes que han inspirado Solidity visite la sección :doc:`influencia de lenguajes <language-influences>`.

Solidity es estáticamente escrito, soporta herencia, librerías, y tipos complejos definidos por el usuario, entre otras características.

Con Solidity se pueden crear contratos para votaciones, financiación colectiva (crowdfunding), subastas a ciegas, y monederos (wallets) multifirma.

Al momento de desplegar un contrato, debes utilizar la versión más reciente de Solidity.
Aparte de casos excepcionales, solamente la última versión recibe `correciones de seguridad <https://github.com/ethereum/solidity/security/policy#supported-versions>`_.
Además, cambios importantes y nuevas funciones se introducen periódicamente.
Actualmente se utiliza el número de versión 0.y.z `para indicar estos rápidos cambios <https://semver.org/#spec-item-4>`_.
=======
Solidity is an object-oriented, high-level language for implementing smart contracts.
Smart contracts are programs that govern the behavior of accounts within the Ethereum state.

Solidity is a `curly-bracket language <https://en.wikipedia.org/wiki/List_of_programming_languages_by_type#Curly-bracket_languages>`_ designed to target the Ethereum Virtual Machine (EVM).
It is influenced by C++, Python, and JavaScript.
You can find more details about which languages Solidity has been inspired by in the :doc:`language influences <language-influences>` section.

Solidity is statically typed, supports inheritance, libraries, and complex user-defined types, among other features.

With Solidity, you can create contracts for uses such as voting, crowdfunding, blind auctions, and multi-signature wallets.

When deploying contracts, you should use the latest released version of Solidity.
Apart from exceptional cases, only the latest version receives
`security fixes <https://github.com/ethereum/solidity/security/policy#supported-versions>`_.
Furthermore, breaking changes, as well as new features, are introduced regularly.
We currently use a 0.y.z version number `to indicate this fast pace of change <https://semver.org/#spec-item-4>`_.
>>>>>>> english/develop

.. Advertencia::

<<<<<<< HEAD
  Solidity lanzó recientemente la versión 0.8.x, que introdujo varios cambios significantes.
  Asegúrese de leer :doc:`la lista completa de cambios <080-breaking-changes>`.
=======
  Solidity recently released the 0.8.x version that introduced a lot of breaking changes.
  Make sure you read :doc:`the full list <080-breaking-changes>`.
>>>>>>> english/develop

Ideas para mejorar Solidity o esta misma documentación son siempre bienvenidas, lea nuestra :doc:`guía de contribución <contributing>` para más detalles.

.. Nota::

<<<<<<< HEAD
  Puede descargar esta documentación como PDF, HTML o Epub haciendo click en el menú desplegable que se encuentra en la esquina inferior izquierda y seleccionando su formato preferido de descarga.
=======
  You can download this documentation as PDF, HTML or Epub
  by clicking on the versions flyout menu in the bottom-left corner and selecting the preferred download format.
>>>>>>> english/develop

Para Comenzar
-------------

**1. Comprender los Conceptos Básicos de los Contratos Inteligentes**

Si usted es nuevo y todavía no está familiarizado con el concepto de los contratos inteligentes, le recomendamos iniciar con la sección "Introducción a los Contratos Inteligentes", que cubre:

<<<<<<< HEAD
* :ref:`Un ejemplo sencillo de un contrato inteligente <simple-smart-contract>` escrito en Solidity.
* :ref:`Conceptos Básicos de las Cadenas de Bloques (Blockchain) <blockchain-basics>`.
* :ref:`La Máquina Virtual de Ethereum <the-ethereum-virtual-machine>`.
=======
If you are new to the concept of smart contracts, we recommend you to get started by digging into the "Introduction to Smart Contracts" section, which covers the following:
>>>>>>> english/develop

**2. Conozca Solidity**

Una vez que esté relacionado con los conceptos básicos, le recomendamos leer las secciones de :doc:`"Solidity con Ejemplos" <solidity-by-example>` y "Descripción del Lenguaje" para comprender los conceptos fundamentales del lenguaje.

**3. Instalar el Compilador de Solidity**

Hay distintas maneras de instalar el compilador de Solidity, simplemente elija su opción preferida y siga los pasos indicados en la :ref:`página de instalación <installing-solidity>`.

.. Nota::

<<<<<<< HEAD
  Puede probar algunos ejemplos de código directamente en su navegador con `Remix IDE <https://remix.ethereum.org>`_.
  Remix es un entorno de desarrollo integrado (IDE) basado en el navegador web, que permite a cualquier usuario escribir, desplegar y administrar contratos inteligentes de Solidity; sin la necesidad de instalar Solidity localmente.

.. Advertencia::
=======
.. hint::
  You can try out code examples directly in your browser with the
  `Remix IDE <https://remix.ethereum.org>`_.
  Remix is a web browser-based IDE that allows you to write, deploy and administer Solidity smart contracts,
  without the need to install Solidity locally.

.. warning::
    As humans write software, it can have bugs.
    Therefore, you should follow established software development best practices when writing your smart contracts.
    This includes code review, testing, audits, and correctness proofs.
    Smart contract users are sometimes more confident with code than their authors,
    and blockchains and smart contracts have their own unique issues to watch out for,
    so before working on production code, make sure you read the :ref:`security_considerations` section.
>>>>>>> english/develop

    Ya que el software está escrito por humanos, puede contener errores.
    Usted debe seguir e implementar las mejores prácticas de desarrollo de software establecidas al escribir sus contratos inteligentes.
    Esto incluye la revisión, pruebas, auditorías y la correcta validez del código.
    Algunas veces los usuarios de los contratos inteligentes tienen más confianza el el código que sus mismos autores; ya que las cadenas de bloques y los contratos inteligentes tienes sus respectivos problemas, se recomienda que lea la sección :ref:`security_considerations` antes de trabajar en el código de producción.

<<<<<<< HEAD
**4. Conocer Más**

Si desea obtener más información sobre la creación de aplicaciones descentralizadas en Ethereum, los recursos para desarrolladores de Ethereum pueden ayudarlo con más documentación general sobre Ethereum y una amplia selección de tutoriales, herramientas y marcos de desarrollo (frameworks).

Si tiene alguna duda o pregunta, puede intentar buscar consultas o respuestas en `Ethereum StackExchange <https://ethereum.stackexchange.com/>`_, o en nuestro `Canal de Gitter <https://gitter.im/ethereum/solidity/>`_.
=======
If you want to learn more about building decentralized applications on Ethereum,
the `Ethereum Developer Resources <https://ethereum.org/en/developers/>`_ can help you with further general documentation around Ethereum,
and a wide selection of tutorials, tools, and development frameworks.

If you have any questions, you can try searching for answers or asking on the
`Ethereum StackExchange <https://ethereum.stackexchange.com/>`_,
or our `Gitter channel <https://gitter.im/ethereum/solidity>`_.
>>>>>>> english/develop

.. _translations:

Traducciones
------------

<<<<<<< HEAD
La comunidad de contribuidores es la encargada de la traducción de esta documentación en diferentes lenguajes.
Por favor, tenga en cuenta que se tienen diversos grados de integridad y actualización.
La versión en Inglés es tomada como referencia.
=======
Community contributors help translate this documentation into several languages.
Note that they have varying degrees of completeness and up-to-dateness.
The English version stands as a reference.
>>>>>>> english/develop

Puede elegir entre distintos idiomas haciendo click en el menú desplegable que se encuentra en la esquina inferior izquierda y seleccionando su lenguaje preferido.

* `Chino <https://docs.soliditylang.org/zh/latest/>`_
* `Francés <https://docs.soliditylang.org/fr/latest/>`_
* `Indonesio <https://github.com/solidity-docs/id-indonesian>`_
* `Japonés <https://github.com/solidity-docs/ja-japanese>`_
* `Coreano <https://github.com/solidity-docs/ko-korean>`_
* `Persa <https://github.com/solidity-docs/fa-persian>`_
* `Ruso <https://github.com/solidity-docs/ru-russian>`_
* `Español <https://github.com/solidity-docs/es-spanish>`_
* `Turco <https://github.com/solidity-docs/tr-turkish>`_
* `Alemán <https://github.com/solidity-docs/de-german>`_
* `Portugués <https://github.com/solidity-docs/pt-portuguese>`_

.. Note::
  Recientemente se creó una nueva organización en GitHub y un flujo de trabajo para las traducciones, con el motivo de agilizar los esfuerzos de la     comunidad. Por favor, consulte la `guía de traducción <https://github.com/solidity-docs/translation-guide>`_ para obtener información sobre cómo iniciar un nuevo idioma o contribuir en las traducciones de la comunidad.
  Hemos establecido una organización de Github y flujo de trabajo de traducción para ayudar a optimizar los esfuerzos de la comunidad. Consulte la guīa de traducción en `solidity-docs org <https://github.com/solidity-docs>`_ para obtener información sobre cómo iniciar una nuevo idioma o contribuir a la traducciones de la comunidad.

<<<<<<< HEAD
Contenidos
==========
=======
   We set up a GitHub organization and translation workflow to help streamline the community efforts.
   Please refer to the translation guide in the `solidity-docs org <https://github.com/solidity-docs>`_
   for information on how to start a new language or contribute to the community translations.
>>>>>>> english/develop

:ref:`Índice de palabras clave <genindex>`, :ref:`Página de búsqueda <search>`

.. toctree::
   :maxdepth: 2
   :caption: Conceptos Básicos

   introduction-to-smart-contracts.rst
   solidity-by-example.rst
   installing-solidity.rst

.. toctree::
   :maxdepth: 2
   :caption: Descripción del Lenguaje

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
   :caption: Compilador

   using-the-compiler.rst
   analysing-compilation-output.rst
   ir-breaking-changes.rst

.. toctree::
   :maxdepth: 2
   :caption: Componentes Internos

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
<<<<<<< HEAD
   :caption: Material Adicional
=======
   :caption: Advisory content
>>>>>>> english/develop

   security-considerations.rst
   bugs.rst
   050-breaking-changes.rst
   060-breaking-changes.rst
   070-breaking-changes.rst
   080-breaking-changes.rst

.. toctree::
   :maxdepth: 2
   :caption: Additional Material

   natspec-format.rst
   smtchecker.rst
   yul.rst
   path-resolution.rst

.. toctree::
   :maxdepth: 2
   :caption: Resources

   style-guide.rst
   common-patterns.rst
   resources.rst
   contributing.rst
   language-influences.rst
   brand-guide.rst
