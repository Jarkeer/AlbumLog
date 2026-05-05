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


 
[DiagramaDFlujo.pdf](https://github.com/user-attachments/files/27035821/DiagramaDFlujo.pdf)
[RESEARCH.md](https://github.com/user-attachments/files/27037290/RESEARCH.md)
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

