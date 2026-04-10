buildscript {
    val kotlin_version by extra("2.1.10")
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.9.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 1. Setup build directories
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)


subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // Update the name from "edge_detection" to "cunning_document_scanner"
    if (project.name == "cunning_document_scanner") {
        project.plugins.withId("com.android.library") {
            configure<com.android.build.gradle.LibraryExtension> {
                // Set a namespace for the new plugin
                namespace = "com.cunning.document_scanner"

                compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_11
                    targetCompatibility = JavaVersion.VERSION_11
                }
            }
        }
    }

    project.evaluationDependsOn(":app")
}