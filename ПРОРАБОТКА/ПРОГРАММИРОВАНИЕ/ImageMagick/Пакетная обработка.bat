https://habr.com/ru/post/351014/ Пакетная обработка изображений в Windows с ImageMagick. Часть I

ImageMagick — свободный и кроссплатформенный редактор для работы с графикой.
Он состоит из нескольких консольных утилит. Его возможностей не счесть, как звезд на небе.
В сети есть множество примеров (http://www.imagemagick.org/Usage/), как пользоваться им. Но большинство из них для Linux или PHP. Для Windows же их кот наплакал. Настало время восполнить пробел.

Вначале была установка

Есть версии много ImageMagick. Если машина уже не молода и памяти не больше 1024 Мбайт — вам уготована Q8. Иначе, загружайте Q16 (http://www.imagemagick.org/script/download.php#windows).

Во время установки, отметьте чекбоксы:

 ✔ Create a desktop icon
 ✔ Add application directory to your system path
 ✔ Install FFmpeg
 ✔ Install legacy utilities (e.g. convert)

Таким образом, мы получим весь комплект утилит и добавим их в системную переменную path.

Пакетное сжатие и ресайз PNG и JPG с помощью ImageMagick

Ресайз и сжатие выполняют две утилиты ImageMagick:
mogrify.exe — изменяет исходное изображение.
convert.exe – на основе исходного, создает новое, измененное изображение.

JPG. Основные опции ImageMagick для сжатия и ресайза

-quality 80 — уровень сжатия (80 приблизительно равен 60 в Adobe Photoshop)
-filter Lanczos — фильтр Ланцоша.
-gaussian-blur 0.05 — размытие по Гауссу.
Параметры: Радиус × Сигма в пикселях. Сигма — это стандартное отклонение от нормального распределения Гаусса. Небольшое размытие уменьшает размер, но снижает качество при масштабировании изображения.
-sampling-factor 4:2:0 — цветовая субдискретизация.
Значение 4:2:0 уменьшает разрешение канала цветности до половины. Применяется только если параметр -quality меньше чем 90. Параметр -sampling-factor определяет коэффициенты выборки, которые будут использоваться кодером JPEG, для понижающей дискретизации цветности. Если этот параметр опущен, библиотека JPEG будет использовать собственные значения по умолчанию. Рекомендуется использовать его вместе с параметром -define jpeg:dct-method=float, что дает небольшое улучшение качества, без увеличения размера файла, поскольку использует более точное дискретное косинус-преобразование с плавающей запятой.
-unsharp 0x3+1+0 — придает ощущение большей четкости изображения.
Значения: Радиус× Сигма+усиление+порог.
Радиус — радиус гауссова размытия в пикселях, не считая центральный пиксель (по умолчанию 0). Для приемлемых результатов радиус должен быть больше сигмы. Если он не задан или установлен на ноль, ImageMagick рассчитает максимально возможный радиус, который даст приемлемые результаты для распределения Гаусса.
Сигма — стандартное отклонение гауссова размытия в пикселях (по умолчанию 1.0). Является важным аргументом и определяет фактическое количество размытия, которое будет иметь место.
Усиление — величина разницы между оригинальным и размытым изображением, которое добавляется обратно в оригинал (по умолчанию 1.0).
Порог — величина количественной разницы между изображениями (по умолчанию 0,05).
- colorspace RGB — цветовое пространство RGB.
-interlace Plane — используется если нужен прогрессивный JPEG.
-strip — удаление всех метаданных (exif, цветовой профиль и т.п.).
-resize — изменяет размер изображения в пикселях.
-thumbnail — опция похожая на -resize. Помимо реcайза, удаляет также и метаданные изображения. Говорят, что работает быстрее и качественнее, чем -resize.

Важно понимать, что нет «лучших» настроек. Применение одинаковых настроек ко всем изображениям, не даст лучших результатов. Некоторые изображения будут выглядеть размытыми, или наоборот, слишком резкими. Поэтому нужно выбрать «средние» параметры, которые вам подойдут.

Примеры использования параметра -thumbnail:

Ресайз по ширине 100px, с сохранением соотношения сторон (высота изменится пропорционально):
convert img.jpg -thumbnail 100x img1.jpg

Ресайз по высоте 150px, с сохранением соотношения сторон (ширина изменится пропорционально).
convert img.jpg -thumbnail x150 img1.jpg

Ресайз без сохранения соотношения сторон:
convert img.jpg -thumbnail 100x150! img1.jpg

Ресайз в % (процентах):
convert img.jpg -thumbnail 20% img1.jpg 

Для удобной пакетной обработки изображений, воспользуемся батниками. Это пакетные файлы с расширением .BAT или.CMD. В примерах с jpg, установим сжатие с качеством 80 и ресайз по ширине 800px.
Батник будет изменять изображения, только в каталоге, из которого он запущен. Он создаст папку «Compressed» и запишет в нее измененные изображения, добавляя к имени "_Compressed.jpg".

JPG — батники для сжатия и ресайза с потерями

Оптимальный, на мой взгляд, вариант для jpg:

@Echo Off
Setlocal
color 0a
set "Source=%~dp0"
cd /d "%~dp0"
if not exist ".\*.jpg" (
echo.
echo FAILED! Files *.jpg not found.
echo.
 pause
 endlocal & exit
) else (
echo.
echo Compress all JPG in a Directory:
echo %Source%
if not exist Compressed mkdir Compressed
for %%i in (*.jpg) do (
	convert ^
	-quality 80 ^
	-filter Lanczos ^
	-sampling-factor 4:2:0 ^
	-define jpeg:dct-method=float ^
	-thumbnail 800x ^
	"%%i" ".\Compressed\%%~ni_Compressed.jpg"
)
)&& cls
echo. 
echo  Process done!
echo.
pause
endlocal & exit

Что делает это батник? В каталоге, из которого он запущен, находит все файлы с расширением *.jpg. Здесь же, создает папку «Compressed» и копирует в нее все обработанные изображения, добавляя к их имени "_Compressed.jpg".

Приведу для примера, батник с утилитой mogrify.exe (обработает и перезапишет все изображения .jpg, в каталоге, из которого будет запущен):

Пример батника с утилитой mogrify.exe:

@Echo Off
Setlocal
color 0a
set "Source=%~dp0"
cd /d "%~dp0"
if not exist ".\*.jpg" (
echo.
echo FAILED! Files *.jpg not found.
echo.
pause
 endlocal & exit
) else (
echo.
echo: mogrify: compress all JPG in a Directory:
echo: %Source%
for %%i in (*.jpg) do (
    mogrify ^
	-quality 80 ^
	-filter Lanczos ^
	-sampling-factor 4:2:0 ^
	-define jpeg:dct-method=float ^
	-gaussian-blur 0.05 ^
	-thumbnail 800x ^
	"%%i"
	)
)&& cls
echo.
echo Process done!
echo.
pause
endlocal & exit


PNG. Основные опции ImageMagick для сжатия и ресайза

PNG сжимается без потерь и сохра­няет про­зрач­но­сть ( альфа-канал).
Хотя, его тоже возможно сжимать с потерями. Также, как и с jpg, можно использовать опции:-gaussian-blur, -strip, -resize, -thumbnail, -unsharp.
А также множество вариантов с опциями для png:
-define png:compression-filter=2
-define png:compression-level=9
-define png:compression-strategy=1
-colors 255 — Почему не 256? Потому что 1 резервируется для альфа-канала.
-depth 8 — количество бит.
-quality 90 — для png этот параметр имеет иной принцип работы и другие значения, чем для jpg.

Подробнее об этих опциях, смотрите на сайте ImageMagick. Их очень много, на любой вкус и цвет. Я привел средние параметры, которые меня устроили. Теперь давайте посмотрим, как их можно использовать в батниках.


PNG — батники для сжатия и ресайза

Вариант 1. Сжатие и ресайз 400px по ширине без потерь:

@echo off
Setlocal
color 0a
set "Source=%~dp0"
cd /d "%~dp0"
	if not exist ".\*.png" (
	echo.
	echo FAILED! Files *.png not found.
	echo.
 pause
 endlocal & exit	
) else (
    echo.
	echo   Lossy compress all PNG in a Directory:
	echo   %Source%
if not exist Compressed mkdir Compressed
FOR %%i IN (.\*.png) DO (
	convert ^
	-thumbnail 400x ^
	-define png:compression-level=9 ^
	-define png:compression-filter=2 ^
	-define png:compression-strategy=1 ^
	"%%i" ".\Compressed\%%~ni_Compressed.png"
		)
	)&& cls 	
	echo.
	echo Process done!   	
	echo.	
 pause
 endlocal & exit

Вариант 2. Сжатие и ресайз 400px по ширине с потерями:

@Echo Off
Setlocal
color 0a
set Source="%~dp0"
cd /d "%~dp0"	
	if not exist ".\*.png" (
	echo.
	echo FAILED! Files *.png not found.
	echo.
 pause
 endlocal & exit	
) else (
    echo.
	echo  Lossy compress all PNG in a Directory:	
	echo  %Source%
if not exist Compressed mkdir Compressed
FOR %%i IN (.\*.png) DO (
	convert ^
	-thumbnail 400x ^
	-colors 255 ^
	-depth 8 ^
	-quality 90 ^
	"%%i" ".\Compressed\%%~ni_Compressed.png" 	
		)
	)&& cls 	
	echo.
	echo  Process done!   	
	echo.
 pause
 endlocal & exit

Изменяя опции и значения параметров в этих батниках, можно подобрать подходящий для вас вариант, для пакетного сжатия и ресайза.


Что делать, если вы изменили батник, и он перестал работать?

 1. Убрать все пробелы в конце строк. В Notepad++ это можно сделать так: выделить все, Правка — Операции с Пробелами — Убрать замыкающие пробелы и сохранить. Или: Ctrl+A — Ctrl+Shift+B — Ctrl+S.
 2. Проверьте, стоит ли кодировка UTF-8 без BOM. Если же вы используете в батнике кириллицу, кодировка OEM 866.
 3. Убедитесь, что используются подходящие параметры для данного формата.

Загрузить все батники >> https://disk.yandex.kz/d/xU3m-V2C3Thi88

И на десерт

Я протестировал все популярные PNG компрессоры. Для себя сделал вывод: лучшее сжатие PNG с потерями дает pngquant (https://pngquant.org/). Если применять его для сжатия скриншотов. С другими изображениями — не тестировал. Работает очень быстро. С параметром "--strip" — удаляет все метаданные.
pngquant — это PNG-компрессор, который значительно уменьшает размеры файлов путем преобразования изображений в более эффективный 8-битный PNG-формат с альфа-каналом (часто на 60-80% меньше, чем 24/32-битные PNG-файлы). Сжатые изображения полностью совместимы со стандартами и поддерживаются всеми веб-браузерами и операционными системами.
Параметры командной строки pngquant: https://github.com/kornelski/pngquant#options

И конечно же есть автомат Калашникова батник для пакетной обработки:

@Echo Off
Setlocal
color 0a
set "Source=%~dp0"
cd /d "%~dp0"
if not exist ".\*.png" (
	echo.
	echo FAILED! Files *.png not found. 
	echo.
 pause
 endlocal & exit
) else (
    echo.
	echo   Lossy compress all PNG in a Directory:
	echo   %Source%
if not exist Compressed mkdir Compressed
for %%i in (*.png) do (
"pngquant.exe" --strip "%%i" -o ".\Compressed\%%~ni_Compressed.png" && (Echo "%%i" - OK& Rem.) || Echo === "%%i" - FAILED!
)
	)
    echo.
    echo Process done!
    echo.
 pause
endlocal & exit

Чтобы все работало, нужно положить pngquant.exe рядом с батником. Либо скопировать его в любую папку и в батнике, вместо «pngquant.exe», указать путь «YourPath\pngquant.exe»
Примечание: pngquant почему-то не обрабатывает файлы с кириллическими именами.

Но, мы отвлеклись. Во второй части продолжим и поговорим о пакетном добавлении водяных знаков с помощью ImageMagick.