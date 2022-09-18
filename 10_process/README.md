# Работаем с процессами

### Задания на выбор:
*    написать свою реализацию ps ax используя анализ /proc  
     Результат ДЗ - рабочий скрипт который можно запустить

    
* дописать обработчики сигналов в прилагаемом скрипте, оттестировать, приложить сам скрипт, инструкции по использованию   
    Результат ДЗ - рабочий скрипт который можно запустить + инструкция по использованию и лог консоли


---

1. Реализован  [скрипт](ps.sh)
2. Обработка сигналов

Дорабатываем [скрипт](myfork.py) 

```python
python3 myfork.py  
```

* Нажимаем [Ctrl] + [C]

```sh
➜  10_process git:(10_process) ✗ python3 myfork.py                                                                                                     19:22:21 11/09/22
Hello! I am an example
pid of my child is 699750
HHHrrrrr
pid of my child is 0
I am a child. Im going to sleep
mrrrrr
2
my child pid is 699751
my name is 2
mrrrrr
4
my child pid is 699760
my name is 4
^CПерехвачен сигнал: 2
Перехвачен сигнал: 2
Выходим по Ctrl+C:
```

* или посылаем сигнал SIGTERM
```sh
ps a |  grep myfork.py | grep python  | head -n 1 |  awk '{ print $1 }' | xargs kill -s SIGTERM 
```
Видим что, и родитель и потомок получили сигнал о прекращени и  выполнили отключение

```sh
➜  10_process git:(10_process) ✗ python3 myfork.py                                                                                                     19:25:26 11/09/22
Hello! I am an example
pid of my child is 702572
HHHrrrrr
pid of my child is 0
I am a child. Im going to sleep
mrrrrr
2
my child pid is 702573
my name is 2
mrrrrr
4
my child pid is 702591
my name is 4
Перехвачен сигнал: 15
Перехвачен сигнал: 15
Выходим по SIGTERM
Выходим по SIGTERM
```