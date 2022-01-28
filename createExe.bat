if not exist %cd%\PaQt-man mkdir %cd%\PaQt-man
cd ..
windeployqt.exe --dir %cd%\PaQt-man\PaQt-man --qmldir %cd%\PaQt-man\qml %cd%\build-PaQt-man-Desktop_Qt_5_14_2_MSVC2017_64bit-Release\release\PaQt-man.exe
xcopy /S /Q /Y /F "%cd%\build-PaQt-man-Desktop_Qt_5_14_2_MSVC2017_64bit-Release\release\PaQt-man.exe" "%cd%\PaQt-man\PaQt-man\PaQt-man.exe*"
pause