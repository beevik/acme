
newaction {
    trigger     = "clean",
    description = "Clean genie products",
}

if _ACTION == nil then
    _ACTION = "gmake"
end

if _ACTION == "clean" then
    os.rmdir("bin")
    os.rmdir("obj")
    os.remove("Makefile")
    os.remove("acme.make")
    return
end

if _OPTIONS['os'] == nil then
    if string.match(_ACTION, "vs.*") then
        print("OS set to Windows.")
        _OPTIONS['os'] = "windows"
    elseif string.match(_ACTION, "xcode.*") then
        print("OS set to MacOSX")
        _OPTIONS['os'] = "macosx"
    else
        print("OS set to Linux.")
        _OPTIONS['os'] = "linux"
    end
end


rootDir     = path.getabsolute(".")
targetDir   = path.join(rootDir, "bin")
objDir      = path.join(rootDir, "obj")
solutionDir = rootDir

solution("acme")
    location(solutionDir)

    language "C"

    if _ACTION == "gmake" or _ACTION == "ninja" then
        premake.gcc.cc  = "clang"
        premake.gcc.cxx = "clang++"
        premake.gcc.ar  = "llvm-ar"
    end

    configurations {
        "debug",
        "release",
    }

    platforms {
        "x64",
    }

    flags {
        "ExtraWarnings",
        "NativeWChar",
        "Symbols",
    }

    configuration { "gmake or ninja" }
        buildoptions {
            "-Wno-sign-compare",
            "-Wno-unused-parameter",
        }

    configuration { "Debug" }
        defines {
            "_DEBUG",
            "Debug",
        }
        flags {
            "DebugRuntime",
        }

    configuration { "Release" }
        defines {
            "NDEBUG",
        }
        flags {
            "OptimizeSpeed",
            "ReleaseRuntime",
        }

    configuration {} -- reset


project("acme")
    kind "ConsoleApp"

    uuid(os.uuid("app-acme"))

    configuration { "Debug" }
        targetdir(path.join(targetDir, name, "Debug"))
        objdir(path.join(objDir, "Debug"))

    configuration { "Release" }
        targetdir(path.join(targetDir, "Release"))
        objdir(path.join(objDir, "Release"))

    configuration { "linux" }
        links {
            "m",
        }

    configuration {} -- reset

    includedirs {
        path.join(rootDir, "src"),
    }

    files {
        path.join(rootDir, "src/**")
    }

    excludes {
        path.join(rootDir, "src", "_*.c"),
    }