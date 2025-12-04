android {
    namespace = "com.example.pavo_efectivo"
    // CAMBIO 1: Definimos explícitamente la versión 34 (Android 14)
    compileSdk = 34 
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID.
        applicationId = "com.example.pavo_efectivo"
        
        // CAMBIO 2: Firebase requiere mínimo 21 o 23. Usamos 23 para seguridad.
        minSdk = 23
        // CAMBIO 3: Igualamos el target al compileSdk
        targetSdk = 34
        
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}