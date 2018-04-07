from cx_Freeze import setup, Executable
import os
os.environ['TCL_LIBRARY'] = r'C:\Python36\tcl\tcl8.6'
os.environ['TK_LIBRARY'] = r'C:\Python36\tcl\tk8.6'

#E:\_PYTHON_\VibHub-WoW\src
executables = [
    Executable(
        "_index.py",
        base="Win32GUI", #None
        targetName="ExiWoW-VH.exe",
        icon="icon.ico"
        )]

packages = ["idna","multiprocessing"]
options = {
    'build_exe': {
        'packages':packages,
        'include_files':[
            r"C:\Python36\DLLs\tcl86t.dll",
            r"C:\Python36\DLLs\tk86t.dll"]
    },
}

setup(
    name = "ExiWoW VibHub Connector",
    options = options,
    version = "0.1",
    description = 'VibHub Connector for the ExiWoW World of Warcraft Addon',
    executables = executables,
    author="JasX",
    url="vibhub.io"
)
