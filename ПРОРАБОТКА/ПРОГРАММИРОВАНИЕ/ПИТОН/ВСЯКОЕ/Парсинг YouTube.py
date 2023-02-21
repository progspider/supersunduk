https://habr.com/ru/post/505888/ Парсинг YouTube, включая подгружаемые данные, без YouTube API

Вступление

Чтобы подгрузить данные контента на ютубе, обычно используют либо Selenium, либо YouTube API. Однако везде есть свои минусы.

 1. Selenium слишком медленный для парсинга. Представьте себе парсинг плейлиста из ~1000 роликов селениумом.
 2. YouTube API, конечно, наилучший вариант, если у вас какое-то свое приложение или проект, но там требуется зарегистрировать приложение и т.д. В «пробной» версии вам нужно постоянно авторизовываться для использования апи, еще там присутствует быстро заканчиваемая квота.
 3. В нашем методе, я бы сказал, очень сложные структуры данных, выдаваемыми ютубом. Особенно нестабильно работает парсинг поиска ютуб.

Как подгружать данные на ютубе?

Для этого есть токен, который можно найти в html коде страницы. Потом в дальнейшем его используем, как параметр для запроса к ютубу, выдающему нам новый контент. Сам ютуб прогружает контент с помощью запроса, где как раз используется этот токен.

Там есть дополнительные исходящие параметры, которые нам будут нужны в следующем шаге.

Картинка: https://habrastorage.org/r/w1560/webt/b8/s0/vc/b8s0vcfqcz6huqa4xo2svsyegga.png

Получение токена через скрипт

Составляем параметр headers для запроса к ютубу. Помимо user-agent вставляем два дополнительных, которые вы видите ниже.

headers = {
    'User-Agent': 'Вы можете взять свой или сгенерировать онлайн, но возможно он не будет работать',
    'x-youtube-client-name': '1',
    'x-youtube-client-version': '2.20200529.02.01'
}

Делаем запрос с помощью библиотеки requests. Ставляете ссылку на страницу, которую нужно прогрузить, а также добавляете headers.

token_page = requests.get(url, headers=headers)

Токен невозможно найти парсерами, т.к он спрятан в тэге script. Чтобы сохранить его в переменную, я прописываю такой некрасивый код:

nextDataToken = token_page.text.split('"nextContinuationData":{"continuation":"')[1].split('","')[0]

Обычно это токен длиной 80 символов.

Делаем запрос на получение контента

service = 'https://www.youtube.com/browse_ajax'
params = {
"ctoken": nextDataToken,
"continuation": nextDataToken
}
r = requests.post(service, params=params, headers=headers)

Разные типы подгружаемых данных имеют разные service ссылки. Наша подойдет для плейлистов и видео с каналов.

Данные Ютуб присылает в json формате. Поэтому пишем r.json(), но вам прилетит список, нам нужен второй элемент списка, поэтому r.json()[1]. Далее у нас уже имеются данные. Остается парсить.

Парсинг json ответа

Можно увидеть длинные цепочки словарей, но мы их сократим, чтобы было более менее понятно.

r_jsonResponse = r_json['response']
dataContainer = r_jsonResponse["continuationContents"]["playlistVideoListContinuation"]
nextDataToken = dataContainer["continuations"][0]["nextContinuationData"]["continuation"]

Здесь мы получаем новый токен для дальнейшего запроса. Если подгружаемые данные закончились, то токена вы не увидите.

for content in dataContainer["contents"]:
	videoId = content['playlistVideoRenderer']['videoId']

Вот так можно извлечь id видеоролика, дописав шаблонную часть, вы получите ссылку на видеоролик.

Чтобы получить следующие данные, вы должны проделать тоже самое — запрос токеном, парсинг и потом снова.

Полностью рабочий код выглядит вот так:

import requests, json

url = input('url: ')
headers = {
		"User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.122 Safari/537.36",
		'x-youtube-client-name': '1',
		'x-youtube-client-version': '2.20200429.03.00',
		}
token_page = requests.get(url, headers=headers)
nextDataToken = token_page.text.split('"nextContinuationData":{"continuation":"')[1].split('","')[0]
sleep = False #Цикл будет завершен, когда не будет токенов
ids = []
while not sleep:
	service = 'https://www.youtube.com/browse_ajax'
	params = {
	"ctoken": nextDataToken,
	"continuation": nextDataToken
	}
	r = requests.post(service, params=params, headers=headers)
	r_json = r.json()[1]
	r_jsonResponse = r_json['response']
	dataContainer = r_jsonResponse["continuationContents"]["playlistVideoListContinuation"]
	try: #пробуем найти токен
		nextDataToken = dataContainer["continuations"][0]["nextContinuationData"]["continuation"]
	except:
                #токен не найден. Значит, далее запроса не будет. Остается собрать оставшийся контент
		sleep = True
	for content in dataContainer["contents"]:
		videoId = content['playlistVideoRenderer']['videoId']
		ids.append(videoId)
print(len(ids))


Вы можете посмотреть мои парсеры каналов, плейлистов, видеороликов Ютуба на GitHub: https://github.com/0r030n0/youtube_parsers