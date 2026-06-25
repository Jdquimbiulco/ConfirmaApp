# ConfirmaApp — Sistema de Asistencia a Eventos

Aplicación móvil Flutter para la **gestión y confirmación de asistencia a eventos** en tiempo real. Combina escaneo QR, validación biométrica facial y verificación por geolocalización GPS para garantizar una presencia legítima y presencial de los participantes.

---

## 🚀 Características principales

### Para el Organizador
- **Crear y editar eventos** con nombre, descripción, fecha, hora, lugar y cupos disponibles.
- **Seleccionar ubicación GPS** directamente desde un mapa interactivo, definiendo un radio de tolerancia en metros.
- **Generar QR único por evento** para distribuir entre los participantes.
- **Escanear participantes** en modo estricto (el organizador opera el escáner).
- **Ver lista de participantes inscritos** con su estado de asistencia.
- **Generar reportes de asistencia** exportables en PDF.
- **Dashboard de organizador** con resumen de todos sus eventos.

### Para el Participante
- **Explorar y registrarse** en eventos disponibles.
- **Escanear el QR del evento** para registrar su asistencia de forma autónoma (modo auto-servicio).
- **Validación biométrica facial** mediante selfie al momento del registro y al confirmar asistencia.
- **Verificación GPS**: la asistencia solo se confirma si el participante está dentro del radio de tolerancia definido por el organizador.
- **Historial de eventos** en los que ha participado.
- **Perfil personal** con foto y datos de usuario.

---

## 🔐 Modos de control de asistencia

| Modo | Descripción |
|------|-------------|
| **Estricto** | El organizador escanea el QR de cada participante con su dispositivo. |
| **Auto-Servicio** | El participante escanea por sí solo el QR del evento mostrado en pantalla. |

---

## 🛠️ Tecnologías utilizadas

| Tecnología | Uso |
|---|---|
| **Flutter** | Framework de UI multiplataforma |
| **Firebase Auth** | Autenticación de usuarios |
| **Cloud Firestore** | Base de datos en tiempo real |
| **Firebase Storage** | Almacenamiento de imágenes (selfies, fotos de perfil) |
| **Google ML Kit** | Detección facial para validación biométrica |
| **Geolocator** | Obtención de coordenadas GPS del dispositivo |
| **flutter_map + latlong2** | Mapa interactivo para selección de ubicación |
| **mobile_scanner** | Escaneo de códigos QR |
| **qr_flutter** | Generación de códigos QR |
| **pdf + printing** | Exportación de reportes de asistencia |
| **Provider** | Manejo de estado (patrón MVVM) |

---

## 🏗️ Arquitectura

El proyecto sigue **Clean Architecture** con separación en capas:

```
lib/
├── data/
│   └── repositories/       # Implementaciones Firebase de los repositorios
├── domain/
│   ├── entities/           # Modelos de negocio (Evento, Usuario, Asistencia, Inscripcion)
│   └── repositories/       # Interfaces/contratos de repositorios
└── presentation/
    ├── screens/            # Pantallas de la app
    ├── viewmodels/         # Lógica de presentación (MVVM)
    ├── layouts/            # Widgets de layout reutilizables
    └── services/           # Servicios de UI
```

---

## 📱 Pantallas

| Pantalla | Rol |
|---|---|
| Login / Registro | Ambos |
| Dashboard Organizador | Organizador |
| Dashboard Participante | Participante |
| Crear / Editar Evento | Organizador |
| Escanear QR (organizador) | Organizador |
| Ver QR del Evento | Organizador |
| Participantes Inscritos | Organizador |
| Reporte de Asistencia (PDF) | Organizador |
| Explorar Eventos | Participante |
| Escanear QR (participante) | Participante |
| Tomar Selfie | Participante |
| Validación Facial | Participante |
| Análisis Biométrico | Participante |
| Historial de Eventos | Participante |
| Perfil de Usuario | Ambos |
| Selector de Mapa GPS | Organizador |

---

## ⚙️ Requisitos previos

- Flutter SDK `>=3.11.5`
- Android SDK con **JDK 17** (requerido por Gradle)
- Cuenta de Firebase con Firestore, Auth y Storage habilitados
- NDK de Android instalado (versión compatible con flutter)
- Archivo `google-services.json` configurado en `android/app/`

---

## 🔧 Instalación

```bash
# 1. Clonar el repositorio
git clone <url-del-repositorio>
cd ConfirmaApp

# 2. Instalar dependencias
flutter pub get

# 3. Ejecutar en modo debug
flutter run
```

> **Nota:** Asegúrate de que Gradle use **JDK 17**. Si tienes una versión más nueva del JDK como sistema, agrega en `android/gradle.properties`:
> ```properties
> org.gradle.java.home=/usr/lib/jvm/java-17-openjdk-amd64
> ```

---

## 👤 Roles de usuario

La aplicación distingue dos tipos de usuario al registrarse:

- **Organizador**: Gestiona sus propios eventos, controla asistencia y genera reportes.
- **Participante**: Explora eventos, se inscribe y confirma su asistencia presencial.
