# bosquejo del flujo de la aplicación

[Restaurante(script)] → http → [API-Rails] → queue →  [Sidekiq] → orm → [PostgreSQL] → view → [Dashboard]


# TODOs:

- innitiate the project with sidekiq and postgresql
- connect to the database with environment variables
- configure sidekiq
- use a procfile

- configure tests
- 

# Prueba Niufoods
## Contexto:
 Estás trabajando para una franquicia de alimentos con varios locales en diferentes ciudades.
 Cada restaurante opera una variedad de dispositivos de hardware, tales como terminales de punto de venta POS, impresoras de cocina, y sistemas de red, que son cruciales para el funcionamiento diario del negocio. Mantener estos dispositivos operativos es fundamental para evitar interrupciones en el servicio y garantizar la disponibilidad.

 Para asegurar un monitoreo continuo y la alta disponibilidad de estos dispositivos, la franquicia ha decidido implementar un sistema centralizado que permita a los restaurantes reportar el estado de sus dispositivos a una API central. Además, se requiere que cada restaurante lleve un registro detallado de las actualizaciones realizadas en sus dispositivos.

## Objetivo de la Prueba:
 El objetivo es evaluar tu capacidad para diseñar y desarrollar una API en Ruby on Rails que reciba, valide, y procese datos de dispositivos enviados por un script que simule la operación de un restaurante. La aplicación debe mostrar estos datos actualizados y debe(OPCIONALMENTE utilizar Sidekiq para el procesamiento en segundo plano. PostgreSQL será la base de datos utilizada.
 
## Tareas:
### Diagrama de Conexión:
 - Diseña un diagrama que represente la conexión y flujo de datos entre el restaurante y la API
 desarrollada en Ruby on Rails. El diagrama debe mostrar cómo se envían los datos desde el
restaurante, cómo son procesados por la API, y cómo se almacenan en la base de datos
 PostgreSQL. También debe incluir el uso de Sidekiq para tareas en segundo plano. no es necesari
 ser tan detallista puede ser a alto nivel.
 - Diseño de base de datos
### Desarrollo de la API
 - Implementa una API en Ruby on Rails que reciba datos de dispositivos. La API debe:
   - Validar los datos recibidos utilizando validaciones a nivel de modelo.
   - Implementar strong params para asegurar la seguridad y control de los datos que se
     permiten a través de las solicitudes.
   - Procesar los datos y actualizar el estado de los dispositivos en la base de datos.
 - Implementar base de datos diseñada.
 - Implementa la lógica en los modelos para manejar las actualizaciones de estado de los
   dispositivos. Esto incluye la gestión de los registros de mantenimiento y cómo afectan al
   estado de los dispositivos y del restaurante.
### Simulación de Restaurante:
 - Escribe un script en Ruby que simule ser uno o varios restaurantes enviando datos a la API
 en intervalos regulares. El script debe:
   - Simular el cambio de estado de los dispositivos (de operativo a fallando, en
 mantenimiento, etc.).
   - Enviar solicitudes HTTP a la API con los datos actualizados de los dispositivos.
   - Manejar posibles respuestas de la API, incluyendo errores de validación.
### Visualización de Datos:
 - Desarrolla una interfaz básica donde se puedan ver los datos actualizados de los
 dispositivos por restaurante. La interfaz debe mostrar:
   - Una lista de restaurantes con su estado general Operativo, Warning, Problemas).
   - Detalles de los dispositivos asociados a cada restaurante, incluyendo su estado actual.
 - El front-end puede ser desarrollado en Ruby on Rails o utilizar un framework JS como React
    o Angular para la visualización de los datos.
### Documentación:
 - Proporciona documentación:
   - Diagrama de lo creado
   - Cómo funciona el script de simulación y cómo interactúa con la API.
 - Instrucciones sobre cómo instalar, configurar y ejecutar la aplicación y el script de
 simulación.




Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
