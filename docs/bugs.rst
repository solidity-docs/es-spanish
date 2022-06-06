.. index:: Bugs

.. _known_bugs:

##################
Lista de Bugs Conocidos
##################

A continuación, puede encontrar una lista en formato JSON de algunos de los bugs conocidos, relacionados con la seguridad en el compiladfor de Solidity.
El archivo se encuentra en el `repositorio de GitHub <https://github.com/ethereum/solidity/blob/develop/docs/bugs.json>`_.
La lista se remonta a la versión 0.3.0, los errores que se conocen, que están presentes sólo en versiones anteriores, no se enumeran.

Hay otro archivo llamado `bugs_by_version.json <https://github.com/ethereum/solidity/blob/develop/docs/bugs_by_version.json>`_, que se puede utilizar para comprobar qué errores afectan a una versión específica del compilador.

Herramientas para la verificación del código fuente de un contrato y otras herramientas que interactúen con contratos, deben consultar esta lista de acuerdo a los siguientes criterios:

- Se puede sospechar levemente si un contrato fue compilado con una versión "nightly" del compilador en vez de un versión publicada.
  Esta lista no realiza un seguimiento de las versiones que no han sido publicadas o versiones "nightly".
- También se puede sospechar levemente si un contrato se compiló con una versión que no era la más reciente en el momento de la creación del contrato.
  Para los contratos creados a partir de otros contratos, se debe seguir la cadena de creación hasta una transacción y usar la fecha de esa transacción como fecha de creación.
- Es altamente sospechoso si un contrato se compiló con un compilador que contiene un bug conocido y el contrato se creó en un momento en que ya se había lanzado una versión más reciente del compilador que contenía una corrección.

El archivo JSON de bugs conocidos, que se encuentra a continuación, es una matriz de objetos, uno por cada error, con las siguientes claves:

uid
    Identificador único dado al error en forma de ``SOL-<año>-<número>``. Es posible que existan varias entradas con el mismo uid. Esto significa que varios rangos de versiones se ven afectados por el mismo error.
name
    Nombre único que se le da al bug.
summary
    Una breve descripción del bug.
description
    Una descripción detallada del bug.
link
    URL del sitio web con información detallada, opcional.
introduced
    La primera versión del compilador publicada que contenía el bug, opcional.
fixed
    La primera versión del compilador publicada que ya no contenía el bug.
publish
    La fecha en la que el bug se hizo público, opcional.
severity
    Gravedad del bug: muy baja, baja, media, alta.
    Se toma en cuenta la detectabilidad en los tests del contrato, probabilidad de ocurrencia y daños potenciales por exploits.
conditions
    Condiciones que deben cumplirse para desencadenar el bug.
    Se pueden utilizar las siguientes claves:
    ``optimizer``, Valor de tipo boolean, lo que significa que el optimizador debe ser encendido para habilitar el bug.
    ``evmVersion``, un string que indica qué tipo de configuración del compilador de la versión de EVM desencadena el bug.
    EL "string" puede contener operadores de comparación.
    Por ejemplo, ``">=constantinople"`` significa que el bug está presente cuando la versión de EVM se establece en "constantinople" o posterior.
    Si no hay condiciones, se debe suponer que el bug está presente.
check
    Este campo contiene diferentes comprobaciones que informan si el smart contract contiene el bug o no.
    El primer tipo de verificación son las expresiones regulares de Javascript que deben compararse con el código fuente ("source-regex") si el bug está presente.
    Si no hay compatibilidad, es muy probable que el bug no esté presente.
    Si hay compatibilidad, es probable que el bug esté presente.
    Para mayor precisión, las comprobaciones deben aplicarse al código fuente después de eliminar los comentarios.
    El segundo tipo de verificación son patrones que se verificarán en el AST compacto del programa Solidity ("ast-compact-json-path").
    La consulta de búsqueda especificada es una expresión `JsonPath <https://github.com/json-path/JsonPath>`_.
    Si al menos una ruta de Solidity AST coincide con la consulta de búsqueda, es probable que el bug esté presente.

.. literalinclude:: bugs.json
   :language: js
