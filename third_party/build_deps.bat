@echo off


:: NOTE: Milton provides built SDL binaries for Windows 64 and 32 bit. If for
:: whatever reason you need to go through the hassle of building SDL, this is
:: the script we use to build it
::
::

:: Milton provides a vendored SDL3 with the following changes:
::
::    - Directories removed to save space:
::          test
::          XCode iOS Demo dir
::    - VS SDL project changed to compile a static library instead of a DLL.
::
::
:: Building:
::   Run this script from the third_party directory.
::
::

set target=x64
if "%1"=="x86" set target=x86


if "%target%"=="x86" set outdir=Win32
if "%target%"=="x64" set outdir=x64

echo "Milton build_deps.bat: Building target platform %outdir%"

pushd SDL3-3.4.4\VisualC
msbuild SDL\SDL.vcxproj /p:Configuration="Debug" /p:Platform=%outdir%
popd

echo Copying SDL3 lib and pdb files to bin\%target%\
copy SDL3-3.4.4\VisualC\SDL\%outdir%\Debug\SDL3.lib bin\%target%\SDL3.lib

:: NOTE: For some reason the SDL project does not generate a PDB for 32 bit.
:: Doesn't matter too much since dev is done in x64.
if "%target%"=="x64" copy SDL3-3.4.4\VisualC\SDL\%outdir%\Debug\SDL3.pdb bin\%target%\SDL3.pdb

