// Importa las librerías necesarias para crear la interfaz en Flutter
import 'package:flutter/material.dart';
// Importa el helper de base de datos para interactuar con SQLite
import 'package:guia5/database_helper.dart';
// Importa la clase Libro que representa el modelo de los libros
import 'libros.dart';

// Función principal que ejecuta la aplicación
void main() {
  runApp(const MyApp());
}

// Clase principal de la aplicación, que extiende StatelessWidget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Este widget es la raíz de la aplicación
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',  // Título de la aplicación
      theme: ThemeData(
        // Configuración del esquema de color usando un color deepPurple
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,  // Usa Material 3 para la interfaz
      ),
      home: const MyHomePage(),  // La pantalla principal será MyHomePage
    );
  }
}

// Widget de la pantalla principal, que extiende StatefulWidget (necesita estado mutable)
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// Estado de la pantalla principal, donde se maneja la lógica de la UI
class _MyHomePageState extends State<MyHomePage> {
  // Instancia de DatabaseHelper para interactuar con la base de datos
  final DatabaseHelper _dbHelper = DatabaseHelper();
  // Controlador para gestionar el texto del campo de entrada del título del libro
  final TextEditingController _EditTituloLibro = TextEditingController();
  // Lista para almacenar los libros que se obtienen de la base de datos
  List<Libro> _items = [];

  @override
  void initState() {
    super.initState();
    // Carga los libros de la base de datos cuando el widget se inicializa
    _cargarListaLibros();
  }

  // Método que carga la lista de libros desde la base de datos
  Future<void> _cargarListaLibros() async {
    final items = await _dbHelper.getItems();  // Obtiene los libros
    setState(() {
      _items = items;  // Actualiza el estado con los libros obtenidos
    });
  }

  // Método para agregar un nuevo libro a la base de datos
  void _agregarNuevoLibro(String tituloLibro) async {
    final nuevoLibro = Libro(tituloLibro: tituloLibro);  // Crea un nuevo libro
    await _dbHelper.insertLibro(nuevoLibro);  // Inserta el libro en la base de datos
    print("SE AGREGO EL NUEVO LIBRO");
    _cargarListaLibros();  // Recarga la lista de libros
  }

  // Método para mostrar una ventana emergente (dialog) que permite agregar un nuevo libro
  void _mostrarVentanaAgregar() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Agregar Titulo"),  // Título del dialog
          content: TextField(
            controller: _EditTituloLibro,  // Asigna el controlador al campo de texto
            decoration: const InputDecoration(hintText: "Ingrese el titulo"),  // Placeholder
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_EditTituloLibro.text.isNotEmpty) {  // Verifica que el campo no esté vacío
                  _agregarNuevoLibro(
                    _EditTituloLibro.text.toString(),  // Llama al método para agregar el libro
                  );
                  Navigator.of(context).pop();  // Cierra el dialog
                }
              },
              child: const Text("Agregar"),
            )
          ],
        );
      },
    );
  }

  // Método para eliminar un libro de la base de datos
  void _eliminarLibro(int id) async {
    await _dbHelper.eliminar('libros', where: 'id = ?', whereArgs: [id]);  // Elimina el libro por ID
    _cargarListaLibros();  // Recarga la lista de libros después de la eliminación
  }

  // Método que muestra un mensaje de confirmación antes de eliminar un libro
  void _mostrarMensajeModificar(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirmar eliminación"),  // Título del dialog
          content: Text("¿Estás seguro de que quieres eliminar este libro?"),  // Mensaje de confirmación
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Cierra el dialog sin hacer nada
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                _eliminarLibro(id);  // Llama al método para eliminar el libro
                Navigator.of(context).pop();  // Cierra el dialog
              },
              child: Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }

  // Método para actualizar el título de un libro en la base de datos
  void _actualizarLibro(int id, String nuevoTitulo) async {
    await _dbHelper.actualizar('libros', {'tituloLibro': nuevoTitulo}, where: 'id = ?', whereArgs: [id]);
    _cargarListaLibros();  // Recarga la lista de libros después de la actualización
  }

  // Método para mostrar la ventana de edición del título de un libro
  void _ventanaEditar(int id, String tituloActual) {
    TextEditingController _tituloController = TextEditingController(text: tituloActual);  // Controlador para el título actual
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Modificar Titulo del Libro"),  // Título del dialog
          content: TextField(
            controller: _tituloController,  // Asigna el controlador al campo de texto
            decoration: InputDecoration(hintText: "Escribe el nuevo titulo"),  // Placeholder
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Cierra el dialog sin hacer nada
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                if (_tituloController.text.isNotEmpty) {  // Verifica que el campo no esté vacío
                  _actualizarLibro(id, _tituloController.text.toString());  // Llama al método para actualizar el libro
                  Navigator.of(context).pop();  // Cierra el dialog
                }
              },
              child: Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra de navegación superior
      appBar: AppBar(
        title: Text("SqfLite Flutter"),  // Título de la aplicación
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,  // Color de fondo de la appBar
      ),
      // Lista que muestra los libros, separados por un divider
      body: ListView.separated(
        itemCount: _items.length,  // Número de libros en la lista
        separatorBuilder: (context, index) => Divider(),  // Separadores entre libros
        itemBuilder: (context, index) {
          final libro = _items[index];  // Obtiene el libro en la posición actual
          return ListTile(
            title: Text(libro.tituloLibro),  // Muestra el título del libro
            subtitle: Text('ID: ${libro.id}'),  // Muestra el ID del libro
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.grey),  // Icono para eliminar el libro
              onPressed: () {
                _mostrarMensajeModificar(int.parse(libro.id.toString()));  // Muestra el mensaje de confirmación
              },
            ),
            onTap: () {
              _ventanaEditar(int.parse(libro.id.toString()), libro.tituloLibro);  // Muestra la ventana para editar el libro
            },
          );
        },
      ),
      // Botón flotante para agregar un nuevo libro
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarVentanaAgregar,  // Muestra la ventana para agregar un libro
        child: const Icon(Icons.add),  // Icono del botón flotante (suma)
      ),
    );
  }
}
