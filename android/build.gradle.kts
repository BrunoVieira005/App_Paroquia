buildscript {
    repositories {
        google()  // Repositório do Google
        mavenCentral()  // Repositório Maven Central
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.1")  // Dependência do Google Services
        classpath("com.android.tools.build:gradle:7.0.4")  // Exemplo de versão, ajuste conforme necessário
    }
}

allprojects {
    repositories {
        google()  // Repositório do Google
        mavenCentral()  // Repositório Maven Central
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
