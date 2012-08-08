from distutils.core import setup
from distutils.extension import Extension

version = '1.1'

cmdclass = {}
source_files = ['qrencode.c']

setup(
    name="pyqrencode_esv",
    version=version,
    description="Ed Vinyard's branch of Python bindings for libqrencode",
    author="Matt Reiferson, Ed Vinyard",
    author_email="mattr@bit.ly, ed@tzahk.com",
    url="http://github.com/EdVinyard/pyqrencode",
    download_url="https://github.com/EdVinyard/pyqrencode/tarball/%s" % version,
    cmdclass=cmdclass,
    ext_modules=[Extension("qrencode", source_files, libraries=["qrencode"])]
)
