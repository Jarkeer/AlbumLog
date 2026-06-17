# AlbumLog

AlbumLog es una aplicación movil que busca fomentar el descubrimiento y recomendación de álbums músicales. La plataforma permite ingresan algún álbum que te gusta y te saldran 
recomendaciones de distintos álbums similares, además de registrar un historial de escuchas y publicar reseñas personales.

Características:
- Se enviaran notificaciones cuando un amigo publique una reseña de us disco o alguien interactue con tus publicaciones
- Gestión de estado y caché: la app guardara en cache las imagenes de las portadas de los discos y los datos recientes de su "feed"

  Requerimientos:
  Como usuario quiero:
  - Como usuario de la aplicación, quiero visualizar una lista de álbumes en tendencia, para poder descubrir nueva música de forma rápida.
  - Como usuario de la aplicación, quiero seleccionar un álbum desde la lista principal, para ver su vista de detalle con la portada completa y discos similares.
  - Como usuario de la aplicación, quiero acceder a un menú de navegación, para poder visitar mi perfil, la sección de ayuda o la información sobre el desarrollador.
  
  Funcionales:
  - El sistema debe implementar un patrón Lista-Detalle (Master-Detail) presentando una colección dinámica de discos musicales y su navegación hacia la vista de detalle.
  - La aplicación debe contener una interfaz de acceso tipo Splash Screen para la transición inicial
  - El sistema debe incorporar pantallas informativas
  - La aplicación debe proveer una interfaz de menú o navegación

 No Funcionales:
- El diseño visual debe utilizar un ThemeData global configurado para evitar la codificación dura.
- Los recursos gráficos y textos (títulos de discos, nombres de artistas) deben ser altamente coherentes

Instrucciones de Uso:
- Al abrir la app desliza hacia abajo para ver las carcteristicas
- Utiliza el menú fijo en la parte inferior de la pantalla para moverte de forma rápida entre las cuatro secciones principales (Inicio, Explorar, Perfil, About).
- Toca el ícono de la brújula ("Explorar") en el menú inferior para acceder a la lista de discos en tendencia.
- Dentro de la sección "Explorar", presiona cualquier disco de la lista. Esto te llevará a una nueva pantalla con la información específica de ese álbum.
- Cuando estés en el detalle de un disco, utiliza la flecha ubicada en la esquina superior izquierda de la pantalla para regresar a la lista principal.
- Accede a las pestañas "Perfil" para gestionar tu cuenta (en construcción) o "Info" para leer más sobre deldesarrollador y buscar ayuda.


```mermaid
flowchart TD
    A([Inicio: Pantalla Principal]) --> B[Ingresar a la pestaña de Búsqueda]
    B --> C[Escribir nombre del disco\nej: Synkronized]
    C --> D{¿El disco existe\nen la API?}
    D -- No --> E[Mostrar mensaje de error\n'Disco no encontrado']
    E --> B
    D -- Sí --> F[Mostrar lista de resultados]
    F --> G[El usuario selecciona el disco correcto]
    G --> H[Mostrar detalles del disco\ny sección de 'Discos Similares']
    H --> I{¿Usuario desea\ndejar una reseña?}
    I -- No --> J[Volver a navegar o salir]
    I -- Sí --> K[Abrir formulario de reseña]
    K --> L[Ingresar texto de reseña\ny asignar puntuación]
    L --> M[Presionar botón 'Publicar']
    M --> N[Guardar registro en la Base de Datos\ny actualizar el Feed]
    N --> O([Fin: Reseña publicada con éxito])

A continuación se presenta el diagrama estructural que describe el flujo de dependencias y la separación de responsabilidades en el proyecto:

```mermaid
flowchart TB
 subgraph subGraph0["Presentación (Flutter UI)"]
        A["Widgets: ExploreView, DetailView"]
        B["State Management / Controller"]
  end
 subgraph subGraph1["Dominio (Lógica de Negocio)"]
        C["Casos de Uso: GetAlbumDetails, SearchAlbums"]
        D["Entities/Models: AlbumModel"]
  end
 subgraph subGraph2["Datos (Infraestructura)"]
        E["Repository Implementation"]
        F["Data Sources: Last.fm API"]
  end
    A --> B
    B --> C
    C --> D & E
    E --> F

    Para ilustrar el comportamiento dinámico del sistema y la interacción entre el usuario, los componentes internos de AlbumLog y los servicios externos, se presenta el siguiente diagrama de secuencia:

    ```mermaid
sequenceDiagram
    actor U as Usuario
    
    box #F3E5F5 Sistema Interno (AlbumLog)
        participant V as ExploreView (UI)
        participant C as Controller / UseCase
        participant R as AlbumRepository
    end
    
    box #F8F9FA Infraestructura Externa
        participant API as Last.fm API
    end

    U->>V: Ingresa término de búsqueda
    V->>C: triggerSearch(query)
    V->>V: Set State: LOADING (Muestra Spinner)
    C->>R: fetchAlbumsFromAPI(query)
    R->>API: GET /albums?q=query
    API-->>R: JSON Response (200 OK)
    R-->>C: List<AlbumModel>
    C-->>V: Update Data
    V->>V: Set State: SUCCESS (Renderiza Lista)
    V-->>U: Muestra resultados en pantalla

    El siguiente diagrama modela los estados finitos por los que transita la vista de exploración (`ExploreView`) durante el proceso de consumo de la API, Diagrama de Maquina de Estados. 


```mermaid
stateDiagram-v2
    %% Definición de Estados Puros (Condiciones del sistema)
    state "Espera (Idle)" as Idle
    state "Cargando (Loading)" as Loading
    state "Resultados (Success)" as Success
    state "Error de Red (Error)" as Error

    %% Transiciones (Eventos / Acciones)
    [*] --> Idle : Inicialización de la vista
    
    Idle --> Loading : Acción: Ingresar búsqueda (onSearch)
    
    Loading --> Success : Evento: Recepción exitosa (HTTP 200)
    Loading --> Error : Evento: Timeout / Fallo de conexión
    
    Success --> Loading : Acción: Nueva búsqueda (onSearch)
    Success --> Idle : Acción: Limpiar pantalla (onClear)
    
    Error --> Loading : Acción: Presionar 'Reintentar'
    Error --> Idle : Acción: Presionar 'Cancelar'


El desarrollo de AlbumLog se apoya en el siguiente stack tecnológico y librerías clave:

* **Framework:** Flutter (SDK ^3.11.3)
* **Lenguaje:** Dart
* **Arquitectura:** MVVM (Model-View-ViewModel)
* **Gestor de Estado:** `provider` (^6.1.5+1)
* **Backend y Autenticación:** `firebase_core`, `cloud_firestore`, `firebase_auth`, `google_sign_in`
* **Persistencia Local:** `shared_preferences` (^2.5.5)
* **Consumo de API:** `http` (^1.6.0) para Last.fm API
* **Utilidades Nativas:** `url_launcher` (Redirección de correos), `flutter_launcher_icons` (Iconos adaptativos)

## Conclusiones del Registro de Decisiones Arquitectónicas (ADR)

### 1. Adopción del Patrón MVVM con Estado Reactivo
* **Decisión:** Separar la interfaz de usuario de la lógica de negocio mediante el patrón Model-View-ViewModel y gestionar el estado con el framework `provider`.
* **Consecuencias:** Desacoplamiento total. Las vistas operan como componentes declarativos que únicamente reaccionan a mutaciones de estado. Esto facilita la inyección de dependencias, permite aislar la lógica para pruebas unitarias y habilita la escalabilidad modular sin requerir la refactorización de la UI.

### 2. Persistencia Híbrida Tolerante a Fallos
* **Decisión:** Implementar almacenamiento local (`SharedPreferences`) como fuente de verdad principal para operaciones Offline, complementado con una arquitectura Cloud (`Firebase Auth`) para la identidad descentralizada.
* **Consecuencias:** Garantiza una latencia cero en la consulta de álbumes calificados y disponibilidad continua sin depender de la conectividad de red.

### 3. Migración de Infraestructura de Datos (iTunes API a Last.fm API)
* **Contexto (Fase POC):** Durante la Prueba de Concepto (POC) del proyecto, se utilizó la API pública de iTunes. Tras el análisis de respuestas JSON, se determinó que su modelo de datos es estrictamente transaccional , lo cual limitaba severamente la obtención de datos.
* **Decisión:** Refactorizar la capa de infraestructura (Data Sources) para abandonar iTunes API y adoptar la API de Last.fm como fuente definitiva.
* **Consecuencias:** Last.fm provee una arquitectura diseñada para el descubrimiento y catalogación musical. Esta migración permitió mejorar los modelos de dominio con datos(etiquetas de género precisas, resúmenes wiki de álbumes y métricas globales), mejorando exponencialmente la calidad del contenido renderizado en la `DetailView` sin añadir carga computacional de parseo extra al cliente.

Resultados del Aseguramiento de Calidad (Beta Testing)

El proceso de QA contó con la participación de **13 usuarios de prueba**, quienes evaluaron la aplicación bajo tres métricas clave: Usabilidad, Contenido y Compartir. Cada criterio fue puntuado en una escala del 1 al 5.

A continuación, se detalla el promedio de calificación obtenido por cada pregunta:

| Categoría | Criterio Evaluado (Pregunta) | Promedio (sobre 5.00) | Representación |
| :--- | :--- | :---: | :---: |
| **Usabilidad** | ¿Qué tan fácil fue navegar a través de la aplicación? | **5.00** | 
| **Usabilidad** | ¿Pudiste completar tus tareas sin problemas? | **4.85** | 
| **Usabilidad** | Diseño y claridad de la interfaz gráfica | **4.69** | 
| **Contenido** | ¿El contenido de la aplicación fue útil para ti? | **4.08** | 
| **Contenido** | Adaptación del contenido a tus expectativas | **4.62** | 
| **Contenido** | Claridad en la presentación de la información | **4.85** | 
| **Compartir** | Probabilidad de recomendar la aplicación a un amigo | **4.69** | 
| **Compartir** | ¿Cómo te sentirías al compartir esta aplicación? | **4.77** | 
| **Compartir** | Utilidad de la app para personas cercanas a ti | **4.69** | 

>  **Calificación Promedio del Sistema: 4.69 / 5.00**

### Resumen Analítico del Beta Testing

A partir de las métricas recopiladas, se levantó el siguiente análisis técnico sobre el estado actual de la aplicación y la ruta de evolución del producto:

**Fortalezas del Sistema (Lo que funcionó)**
* **Navegación Intuitiva:** La implementación del `BottomNavigationBar` fijo fue un acierto absoluto (5.00/5.00), garantizando una curva de aprendizaje nula.
* **Estabilidad Transaccional:** La arquitectura MVVM y el CRUD local operaron sin interrupciones, bloqueos ni errores de tipo, asegurando un flujo de usuario fluido.
* **Claridad Estructural:** El renderizado del JSON consumido desde la API se presentó de forma limpia y altamente comprensible en la UI.

**Oportunidades de Mejora**
* **Profundidad de Contenido:** Fue el área de menor rendimiento (4.08/5.00). Los usuarios indicaron que visualizar solo la portada y el título no genera suficiente valor agregado.
* **Refinamiento Visual:** Aunque funcional, la interfaz gráfica requiere modernización y más interacciones para sentirse como un producto final más pulido.
* **Factor Social:** La aplicación carece de incentivos o herramientas visuales que motiven a los usuarios a compartir sus reseñas de forma orgánica.

**Roadmap y Trabajos Futuros**
1. **Enriquecimiento de Dominio:** Escalar el consumo de la API de Last.fm para incluir listas de canciones (Tracklists), duración total del disco y enlaces directos a plataformas de Streaming.
2. **Sistema de Diseño (UI/UX):** Implementar transiciones animadas, pantallas de carga y optimizar el contraste del Modo Oscuro.

###  Descarga Directa
El archivo ejecutable final:
**[Descargar AlbumLog_v1.0.apk](./apk/AlbumLog_v1.0.apk)**