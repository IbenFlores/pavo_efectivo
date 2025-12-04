# Pavo Efectivo

**Descripción:** Aplicación de gestión financiera personal desarrollada en Flutter con integración de Firebase. Pavo Efectivo permite a los usuarios registrarse, autenticarse y gestionar sus transacciones financieras de manera segura y eficiente.

## Descripción del Proyecto

Pavo Efectivo es una aplicación móvil y web que facilita la gestión de finanzas personales. La aplicación proporciona autenticación segura mediante Firebase y permite a los usuarios visualizar, crear, actualizar y eliminar transacciones financieras.

### Público Objetivo
- Usuarios que desean gestionar sus finanzas personales
- Personas que necesitan un control centralizado de sus transacciones
- Usuarios que prefieren acceder a sus datos desde web o dispositivos móviles

### Características Principales
- ✅ Autenticación segura con Firebase Authentication
- ✅ Validación robusta de contraseñas (mínimo 1 mayúscula y 1 número)
- ✅ Interfaz mejorada y responsiva
- ✅ CRUD completo para gestión de transacciones
- ✅ Visualización del correo del usuario autenticado
- ✅ Sincronización en tiempo real con Firestore
- ✅ Compatibilidad con Web y Android/iOS

## Instalación y Ejecución

### Requisitos previos
- Flutter 3.38.0 o superior
- Dart 3.10.0 o superior
- Fire CLI 14. 19. 0  (junto a sus variables de entorno)
- Visual Studio Build Tools 2019 (para Windows)
- Microsoft Edge (para ejecutar en web)
- Git

### Pasos de instalación

1. **Clonar el repositorio**
```bash
git clone https://github.com/IbenFlores/pavo_efectivo.git
cd pavo_efectivo
```

2. **Instalar dependencias de Flutter**
```bash
flutter pub get
```

3. **Instalar Firebase CLI globalmente**
```bash
npm install -g firebase-tools
```

4. **Activar FlutterFire CLI**
```bash
dart pub global activate flutterfire_cli
```

5. **Configurar Firebase**
```bash
flutterfire configure --project=pavo-efectivo-app
```
Esto generará el archivo `firebase_options.dart` necesario para la conexión. Selecciona todas las plataformas cuando se te pida (android, ios, macos, web, windows).

6. **Ejecutar en Web (Edge)**
```bash
flutter run -d edge
```

6. **Ejecutar en Web (Edge)**
```bash
flutter run -d edge
```

7. **Ejecutar en Windows (Desktop)**
```bash
flutter run -d windows
```

8. **Ejecutar en Android/iOS**
```bash
flutter run -d android  # o -d ios
```

## Funciones Adicionales y Ubicación en el Proyecto

A continuación se describen las funcionalidades implementadas y los archivos donde se encuentran.

### ✅ Actividad 1 – Validación adicional

Se ha agregado validación extra a la contraseña en el formulario de registro/login.
**Requisitos:**
- Contiene al menos 1 número.
- Contiene al menos 1 mayúscula.

**Ubicación:** `lib/features/auth/login_screen.dart` (o el archivo correspondiente al formulario).

**Ejemplo de código:**
```dart
if (!value.contains(RegExp(r'[A-Z]'))) return 'Debe tener al menos una mayúscula';
if (!value.contains(RegExp(r'[0-9]'))) return 'Debe tener al menos un número';
```

### ✅ Actividad 2 – Sistema de Autoregistro

Sistema inteligente de autenticación con registro automático.

**Características implementadas:**
- ✅ **Login automático:** Si el email no existe, se crea cuenta automáticamente
- ✅ **Validación de contraseña:** Mínimo 1 mayúscula y 1 número
- ✅ **Sincronización Firebase:** Usuario guardado en Firestore al autenticarse
- ✅ **Manejo de errores:** Mensajes claros en la interfaz
- ✅ **indicador de carga:** Spinner visual mientras se procesa

**Ubicación:** `lib/features/auth/login_screen.dart`

**Flujo de autenticación:**
```dart
// 1. Intenta login con email y contraseña
// 2. Si usuario no existe (user-not-found), lo crea automáticamente
// 3. Guarda datos básicos en Firestore (uid, email, timestamp)
// 4. Navega a pantalla principal si es exitoso
// 5. Muestra error si hay problema con Firebase

try {
  // Intenta login
  UserCredential cred = await FirebaseAuth.instance.signInWithEmailAndPassword(...);
  await _ensureUserInFirestore(cred.user!);
} on FirebaseAuthException catch (e) {
  if (e.code == 'user-not-found') {
    // Crea cuenta automáticamente
    UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(...);
    await _ensureUserInFirestore(cred.user!);
  }
}
```

### ✅ Actividad 3 – Mostrar email en la pantalla CRUD

Visualización del correo electrónico del usuario autenticado en la pantalla principal (Lista de Usuarios).

**Implementación:**
- Se recibe `final String email;` en el widget.
- Se muestra en el `AppBar`.

**Ubicación:** `lib/features/home/home_screen.dart` (UserListScreen)

**Ejemplo de código:**
```dart
// En el constructor
final String email;

// En el build
AppBar(title: Text('Bienvenido: $email'))
```

## Configuración de Firebase

Para configurar Firebase, asegúrate de ejecutar:
```bash
dart pub global run flutterfire_cli:configure
```
Esto generará el archivo `firebase_options.dart` necesario para la conexión.

## Configuración Inicial

### Requisitos previos
- Flutter 3.38.0 o superior
- Dart 3.10.0 o superior
- Visual Studio Build Tools 2019 (para Windows)
- Microsoft Edge (para ejecutar en web)

## Correcciones de Compilación

### Errores resueltos en Windows

Se han corregido los siguientes errores de compilación:

1. **Error de includes faltantes** en `windows/runner/utils.cpp`:
   - Se agregaron los headers `<string>` y `<vector>` necesarios

2. **Errores de advertencias tratadas como errores**:
   - Se modificó `windows/CMakeLists.txt` para desabilitar `/WX` (convertir advertencias en errores)
   - Se agregó `/wd"4996"` para ignorar advertencias de funciones deprecadas como `strncpy`
   - Se agregó `/FORCE:MULTIPLE` para permitir símbolos duplicados en Firebase

### Cambios realizados:

**Archivo:** `windows/CMakeLists.txt`
```cmake
function(APPLY_STANDARD_SETTINGS TARGET)
  target_compile_features(${TARGET} PUBLIC cxx_std_17)
  target_compile_options(${TARGET} PRIVATE /W4 /wd"4100" /wd"4996")
  target_compile_options(${TARGET} PRIVATE /EHsc)
  target_compile_definitions(${TARGET} PRIVATE "_HAS_EXCEPTIONS=0")
  target_compile_definitions(${TARGET} PRIVATE "$<$<CONFIG:Debug>:_DEBUG>")
  target_link_options(${TARGET} PRIVATE /FORCE:MULTIPLE /IGNORE:LNK4217,LNK4286)
endfunction()
```

## Ejecución del Proyecto

### Ejecutar en Web (Edge)
```bash
flutter run -d edge
```

La aplicación se abrirá en Microsoft Edge. Tendrás disponibles los siguientes comandos:
- `r` - Hot reload (recarga en caliente)
- `R` - Hot restart (reinicio en caliente)
- `h` - Listar todos los comandos disponibles
- `d` - Detach (desconectar pero dejar la app corriendo)
- `c` - Limpiar pantalla
- `q` - Quit (salir)

### Dispositivos disponibles
```bash
flutter devices
```

Dispositivos soportados:
- Windows (desktop) - `windows`
- Edge (web) - `edge`
- Android/iOS (si están configurados)

### Limpiar compilación previa
```bash
flutter clean
```

### Estado de la Compilación

**Plataforma Web (Edge):** ✅ Funcionando correctamente

**Plataforma Windows (Desktop):** ⚠️ Requiere resolver dependencias de Firebase en versiones más recientes


## IU de PavoEfectivo

A continuaci�n se presentan las interfaces de usuario de la aplicaci�n Pavo Efectivo:

### Pantalla de Login
![Login](01%20-%20Documentación/images_IU/login.png)

### Pantalla de Inicio (Home)
![Home](01%20-%20Documentación/images_IU/home.png)

### Pantalla de Transferencias
![Transferencias](01%20-%20Documentación/images_IU/transferir.png)

### Pantalla de Pago de Servicios
![Pago de Servicios](01%20-%20Documentación/images_IU/pagar_servicios.png)
