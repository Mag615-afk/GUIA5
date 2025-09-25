// Definición de la clase Libro
class Libro {
  // Atributo id de tipo entero que puede ser nulo
  int? id;
  // Atributo tituloLibro de tipo String, obligatorio
  String tituloLibro;

  // Constructor de la clase Libro, donde id es opcional y tituloLibro es obligatorio
  Libro({this.id, required this.tituloLibro});

  // Método para convertir el objeto Libro a un mapa (Map) con claves de tipo String
  Map<String, dynamic> toMap() {
    // Devuelve un mapa con los valores de los atributos de la clase Libro
    return {
      'id': id,  // Mapea el atributo 'id'
      'tituloLibro': tituloLibro,  // Mapea el atributo 'tituloLibro'
    };
  }
}