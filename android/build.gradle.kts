// ------------------------------
// TOP-LEVEL PLUGINS
// ------------------------------
plugins {
    id("com.google.gms.google-services") version "4.4.4" apply false
}

// ------------------------------
// REPOSITORIES FOR ALL MODULES
// ------------------------------
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ------------------------------
// BUILD DIRECTORY FIX
// ------------------------------
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()

rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

// ------------------------------
// CLEAN TASK
// ------------------------------
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
