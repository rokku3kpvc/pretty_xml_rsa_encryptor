# PrettyXMLEncryptor (RSA)

PrettyXMLEncryptor (RSA) является результатом выполнения лабораторной работы по дисциплине "Информационная Безопасность".  
Программа является модификацией оригинального [PrettyXMLEncryptor](https://github.com/rokku3kpvc/pretty_xml_encryptor).  
ПО демонстрирует шифрование/дешифрование полей XML файла с помощью асимметричного ключа.  
В качестве алгоритма шифрования использован [RSA](https://ru.wikipedia.org/wiki/RSA)

## Зависимости

Необходимая версия ЯП Ruby содержится в файле `.ruby-version`.  
В качестве инструкций по установке можно использовать данную [документацию](https://www.ruby-lang.org/ru/documentation/installation/).  
Программа использует [bundler](https://bundler.io/) версии 2.0.2 для управлением зависимостями.  
Установка:
```bash
gem install bundler -v 2.0.2
```
Список зависимостей описан в `Gemfile`  
Для установки всех библиотек необходимо выполнить:
```bash
bundle install
```

## Использование
PrettyXMLEncryptor (RSA) предоставляет удобный [CLI](https://ru.wikipedia.org/wiki/CLI)  

Список команд можно посмотреть с помощью флага `--help`
```bash
bundle exec ruby pretty_xml_encryptor.rb --help
```

Флаг `--help` также можно указать для получение справки по конкретной команде, пример:
```bash
bundle exec ruby pretty_xml_encryptor.rb version --help
```

#### Генерация ключей
Для начала работы нужно сгенерировать пару RSA ключей. Это возможно сделать с помощью команды `generate` (также `g -g --generate`).  
В качестве опций можно задать длину ключа и имя выходных файлов.

```bash
$ bundle exec ruby pretty_xml_rsa_encryptor.rb g --help
Command:
  pretty_xml_rsa_encryptor.rb g

Usage:
  pretty_xml_rsa_encryptor.rb g

Description:
  Генерирует приватный и публичный RSA ключи

Options:
  --key-len=VALUE                       # Длина ключа, default: 2048
  --key-name=VALUE                      # Имя файла-ключа, default: ""
  --help, -h                            # Print this help
```

Публичный ключ используется для шифрования документов, может быть передан сторонним лицам:
```text
-----BEGIN PUBLIC KEY-----
MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAPIgjHq0xb8R6P/bacHqaXKbk7VIGOco
iSJzjX+jOjab1koURQ4yxRxQyd5eRzH8Z5CR9aDvAiTwl88GFIXlgwECAwEAAQ==
-----END PUBLIC KEY-----
```

Приватный ключ используется для дешифрования документов и должен оставаться в секрете:
```text
-----BEGIN RSA PRIVATE KEY-----
MIIBOgIBAAJBAPIgjHq0xb8R6P/bacHqaXKbk7VIGOcoiSJzjX+jOjab1koURQ4y
xRxQyd5eRzH8Z5CR9aDvAiTwl88GFIXlgwECAwEAAQJAZPp2G+awYdNSXQJgxOLC
P23q2DvNRvp81sViSc0FRihAN7QOAKpX8IQ/smx8alFx0EMPZPhEqBA11Nubqqen
AQIhAPocJRWmsTnRwQ2MM6LATIe2DT9vDKViR7c2Soiqb7NJAiEA99RHBnK0dCX+
XlVGQ96xhYve5M0ksrPaUE7WcQLOGfkCIDUfhUD0BvCg/MBD5zPKZHbu1CGFFMqL
9W+UuIAOs2sBAiBH2UseG3MlmT49qwtL8ewVg4+DVdYl2O6aCcEx0lZeQQIhAI3b
yRvCq+17WOwdmhebycz4PUGilyQtI02JqoX7CVF1
-----END RSA PRIVATE KEY-----
```

#### Шифрование
За шифрование XML полей отвечает команда `encrypt` (также `enc -enc --encrypt`).  
Она требует путь до публичного ключа и до XML файла.

```bash
$ bundle exec ruby pretty_xml_rsa_encryptor.rb encrypt --help
Command:
  pretty_xml_rsa_encryptor.rb encrypt

Usage:
  pretty_xml_rsa_encryptor.rb encrypt FILE PUB_KEY

Description:
  Шифрует значения XML файла публичным ключом

Arguments:
  FILE                  # REQUIRED Путь до XML файла
  PUB_KEY               # REQUIRED Путь до публичного ключа

Options:
  --help, -h                            # Print this help
```

В директории с оригинальным файлом программа создаст зашифрованную копию с префиксом `enc_`  
Зашифрованный XML файл имеет вид:
```xml
<?xml version="1.0"?>
<PRIVATE>
  <PERSON>
    <NUMBER>gjuMZ8AoCzfRc9KRR_d3sZfEAVV8KfUDQ21NEHmpFd5_qHAMd40QhghVvSTq39XiSeq4tcVnQcUPBhZ9OEysYA==</NUMBER>
    <NAME>ke476V3gfh6slbgAAHGdc036BpK68UDvxVxC60_gRYsI9nwAEPugik-cbDmb6xx5WAh55Cl1AMsoEITbNJJGKA==</NAME>
    <COUNTRY>g7f2q2JKBSpWRDEftBK4Ctrv_JOh7jBBdtzdxdw45USvcUUy71B95I0usddJ-1UYN0sqUpjmTDOuiBOUY83iIw==</COUNTRY>
    <CITY>5eHew7pqip_ey0p9eT9hSbgojxU_zfKJ3qD5FIpWBHc8cds540Q_MNPTkUfXLSQAu61XM1DCSMiwnmSCsaL6YA==</CITY>
    <YEAR>ZZicyxdlgaW_7dD8rxcoh3dm4EXhkPQSZ-pXx6BDezprzQLOnXeJGXgsTg7TthHBmXVoNNcbGWdVS7Q0c__CKQ==</YEAR>
    <CREDIT_CARD>tAZ6RSWhS-b6rPK7pFLqgG9ePkI-1vnY2gs2VQdJ8jPt4KhQf1pILiQDRFns9pgPSDsmSf_ngyMQQmfrm6Xb7g==</CREDIT_CARD>
  </PERSON>
</PRIVATE>
```

#### Дешифрование
За дешифрование отвечает команда `decrypt` (также `dec -dec --decrypt`).  
Она требует путь до приватного ключа и до XML файла.

```bash
$ bundle exec ruby pretty_xml_rsa_encryptor.rb decrypt --help
Command:
  pretty_xml_rsa_encryptor.rb decrypt

Usage:
  pretty_xml_rsa_encryptor.rb decrypt FILE KEY

Description:
  Расшифровывает значения XML файла приватным ключом

Arguments:
  FILE                  # REQUIRED Путь до XML файла
  KEY                   # REQUIRED Путь до приватного ключа

Options:
  --help, -h                            # Print this help
```

В директории с зашифрованным файлом программа создаст расшифрованную копию с префиксом `dec_`:
```xml
<?xml version="1.0"?>
<PRIVATE>
  <PERSON>
    <NUMBER>+79991112233</NUMBER>
    <NAME>Vladimir</NAME>
    <COUNTRY>Russia</COUNTRY>
    <CITY>Moscow</CITY>
    <YEAR>1952</YEAR>
    <CREDIT_CARD>5492537333607674</CREDIT_CARD>
  </PERSON>
</PRIVATE>
```

## TODO
1) Считывать XML файл через курсоры, не заполняя ОЗУ (см. [Nokogiri::XML::Reader](https://nokogiri.org/rdoc/Nokogiri/XML/Reader.html)).
2) Вынести классы и модули в отдельные файлы, создать единую точку входа с подгрузкой всех зависимостей.
3) Обработать поведение при возникновении дополнительных неожиданных исключений (например, при ошибке декодирования).

## Содействие
Пользование PrettyXMLEncryptor (RSA) покрывается лицензией [MIT](https://ru.wikipedia.org/wiki/%D0%9B%D0%B8%D1%86%D0%B5%D0%BD%D0%B7%D0%B8%D1%8F_MIT). Вы можете использовать исходный код программы под собственным авторским именем только после оформления и последующего утверждения мною PR с изменениями, которые затрагивают работу внутренних алгоритмов программы, влияют на структуру и итоговую производительность кода. Идеи для PR можно взять, например, из блока **TODO**.
