# Documentación API Rabbit Tasking

## PRUEBA GESTION USUARIO(DEPRECADO)

[Pruebas de login y registro.pdf](https://github.com/user-attachments/files/18893680/Pruebas.de.login.y.registro.pdf)

## PRUEBAS GESTIÓN TAREAS(DEPRECADO)

[Pruebas gestión tareas.pdf](https://github.com/user-attachments/files/19027805/Pruebas.gestion.tareas.pdf)

## 1. Esquema de Documentos

### Documento Usuario

| Campo        | Tipo             | Restricciones |
|-------------|-----------------|--------------|
| **id**      | ObjectId         | No nulo, autogenerado |
| **username** | String          | No nulo, Máximo 50 caracteres |
| **email**   | String          | No nulo, Máximo 320 caracteres, Tiene que seguir el formato de un email |
| **password** | String         | No nulo, hasheada, Máximo 50 caracteres antes de hashear, Mínimo de complejidad requerido |
| **direccion** | Documento Embebido |  |
| ├ **provincia** | String | No nulo, tiene que existir en GEOAPI |
| ├ **municipio** | String | No nulo, tiene que existir en GEOAPI |
| ├ **calle** | String | No nulo |
| ├ **num** | String | No nulo |
| ├ **cp** | String | No nulo, tiene que seguir formato de código postal |
| **roles** | String         | `USER` o `ADMIN` |

### Documento Tareas

| Campo        | Tipo             | Restricciones |
|-------------|-----------------|--------------|
| **id**      | ObjectId         | No nulo, autogenerado |
| **username** | String         | Clave secundaria al usuario, se usa el nombre de usuario |
| **name**    | String         | Nombre de la tarea, No nulo, Máximo 50 caracteres, Nombre que describa la tarea |
| **description** | String    | Descripción más a fondo de la tarea, Máximo 300 caracteres |
| **date_created** | Date    | No nulo, Se establece automáticamente en la creación |
| **date_limit** | Date    | Fecha límite opcional, Tiene que ser una fecha futura a la hora de creación o modificación |
| **done**    | Boolean    | No nulo, Estado de finalización de la tarea, Si se marca como completada no se puede pasar a incompletada |


## 2. Endpoints

## Endpoints Usuario
- **POST** `/usuarios/register`
  - Endpoint para registrar nuevos usuarios 
- **POST** `/usuarios/login`
  - Permite iniciar sesión, devuelve un token de auntenticación 
- **GET** `/usuarios`
  - Devuelve la información de todos los usuarios 
- **GET** `/usuarios/self`
  - Devuelve la información del usuario que está logueado ahora mismo
- **GET** `/usuarios/{id}`
  - Devuelve la información del usuario según el id 
- **PUT** `/usuarios/self`
  - Modifica el usuario que está logueado ahora mismo   
- **PUT** `/usuarios/{id}`
  - Modifica el usuario según el id
- **DELETE** `/usuarios/self`
  - Borra el usuario que esté logueado ahora mismo 
- **DELETE** `/usuarios/{id}`
  - Borra el usuario según el id

## Endpoints Tareas
- **POST** `/tareas/self`
  - Crea una tarea donde el usuario logueado sea un dueño
- **POST** `/tareas/{idUsuario}`
  - Crea una tarea donde el dueño es el id de usuario 
- **GET** `/tareas`
  - Devuelve todas las tareas
- **GET** `/tareas/self`
  - Devuelve todas las tareas donde el usuario sea el dueño.
- **GET** `/tareas/{idUsuario}`
  - Develve todas las tareas donde el usuario segun el id sea el dueño 
- **PUT** `/tareas/{id}`
  - Modifica una tarea según id 
- **PUT** `/tareas/{id}/done`
  - Marca una tarea como finalizada según id 
- **DELETE** `/tareas/{id}`
  - Borrar una tarea según id


## 3. Lógica de Negocio

La idea es que los usuarios puedan crear o modificar sus datos o sus tareas sin que otros usuarios puedan modificarlos, y marcarlas como finalizadas. La excepción a esta regla son los administradores que tienen acceso a toda la información y pueden modificar o borrar lo que sea necesario. La forma en la que me aseguro de que esto se cumple es con los endpoints /self que permiten a los usuarios acceder o modificar sus propios perfiles únicamente, ya que su nombre de usuario se saca usando su token de inicio de sesión evitando que se pueda acceder a otros usuarios. Los endpoints donde se puede elegir a que usuario se accede por su id son exclusivos de administradores.

En el caso de las tareas antes de que se puedan modificar se comprueba que el usuario sea el dueño de la tarea antes de que se devuelva al información o se permita borrar o modificar.

## 4. Excepciones

- **400 Bad Request**
  - En caso de que algún dato no siga los estándares establecidos
 
- **401 Unathorized**
  - En caso de que el usuario no haya iniciado sesión en un endpoint donde sea necesario

- **404 Not Found**
  - Si el dato que se está buscando no existe

- **409 Conflict**
  - Si el dato está correctamente escrito pero entra en conflicto con algo que ya está en la base de datos
 
- **403 Forbidden de SpringBoot**
  - Para que Preauthorize funcione correctamente hace falta poner una excepción personalizada que evite que se quede atascada en la excepción generica

- **500 Internal Server Error**
  - GENÉRICA: Si algo se escapa que no sea las anteriores, se asume que es un error interno y se limita la información devuelta para no revelar información sensible

## 5. Restricciones de Seguridad

Los usuarios solo pueden acceder a sus propios perfiles además de modificarlos de cualquier forma, pero solo ellos. Otros usuarios no pueden tocar los perfiles de otros. La única excepción son los administradores que sí tienen acceso a todos los documentos y otros usuarios.

## Endpoints de acceso público (sin autenticación requerida)
- **POST** `/usuarios/register`
- **POST** `/usuarios/login`

## Endpoints accesibles solo para usuarios autenticados
- **GET** `/usuarios/self`
- **PUT** `/usuarios/self`
- **DELETE** `/usuarios/self`
- **POST** `/tareas/self`
- **GET** `/tareas/self`

## Endpoints accesibles solo para administradores (`ROLE_ADMIN`)
- **GET** `/usuarios`
- **GET** `/usuarios/{id}`
- **PUT** `/usuarios/{id}`
- **DELETE** `/usuarios/{id}`
- **POST** `/tareas/{idUsuario}`
- **GET** `/tareas`
- **GET** `/tareas/{idUsuario}`

## Endpoints accesibles para administradores o dueños de la tarea
- **PUT** `/tareas/{id}`
- **PUT** `/tareas/{id}/done`
- **DELETE** `/tareas/{id}`


## 6.Pruebas de endpoints

[Pruebas de API Tareas-2.pdf](https://github.com/user-attachments/files/19027837/Pruebas.de.API.Tareas-2.pdf)



