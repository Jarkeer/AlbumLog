# Architecture Decision Record (ADR)
**Título:** Integración de API Externa para Catálogo Musical mediante HTTP asíncrono.
**Proyecto:** AlbumLog

## 1. Contexto (Riesgo Evaluado)
La funcionalidad central de AlbumLog depende de la obtención dinámica de datos de álbumes musicales. El mayor riesgo técnico arquitectónico identificado es la capacidad del sistema para gestionar asincronía, realizar peticiones HTTP de forma segura y decodificar respuestas JSON sin bloquear el hilo de la interfaz de usuario. Un mal manejo de esta infraestructura podría generar una Deuda Técnica alta y fallos críticos (ej. congelamiento de pantalla) en el entorno móvil.

## 2. Decisión Técnica Adoptada
Para aislar y validar este riesgo, se desarrolló una Prueba de Concepto (PoC) utilizando la librería nativa `http` de Dart. Como proveedor de datos, se resolvió consumir la API pública de iTunes Search en lugar de alternativas como la API de Spotify. 

Justificación Técnica: La API de iTunes no usa tokens y no requiere autenticación OAuth 2.0. Esto nos permitió aislar el riesgo exclusivo de la conexión web y el *parsing* de datos, evitando introducir la complejidad de gestión de credenciales, tokens de acceso y renovaciones que exigiría Spotify en esta fase temprana de experimentación.

## 3. Consecuencias y Plan de Integración
**Resultados de la PoC:
* El experimento técnico validó con éxito la funcionalidad asíncrona. La aplicación logró realizar la petición `GET`, decodificar el cuerpo JSON e imprimir los resultados en la UI, gestionando correctamente los estados de carga (`isLoading`).

**Limitaciones encontradas:**
* Al consumir una API externa pública, AlbumLog no tiene control sobre la estructura exacta o los datos faltantes en el JSON (ej. artistas sin imagen de alta resolución), lo que requiere implementar validaciones de *NullSafety* robustas en el modelo.

**Plan técnico para la rama principal:
Para evitar un alto acoplamiento, el código funcional de esta PoC no se implementará directamente en las vistas (UI) de la rama `main`. El plan de integración será:
1. Crear una clase `ITunesRepository` en la capa de Datos.
2. Encapsular la lógica de peticiones `http` dentro de este repositorio.
3. Transformar los diccionarios JSON a objetos estructurados `AlbumModel` antes de enviarlos a la capa de Presentación, cumpliendo con la separación de responsabilidades establecida en nuestro modelo de arquitectura (Clean Architecture).