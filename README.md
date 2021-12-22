# Нетология. Курс "SQL и получение данных" (SQL-35)

Проектная работа выполнена в рамках обучения на курсе Нетологии
Ссылка на курс: https://netology.ru/programs/sql-lessons

Итоговая работа. 
Файлы:

  1.Описание БД.pdf содержание:
  
          1.Описание типа подключения
          2.Скриншот ER-диаграммы
          3.Краткое описание БД
          4.Развернутый анализ БД

  2.Итоговая работа.sql выполнены задания:
  
          1	В каких городах больше одного аэропорта?
          
          2	В каких аэропортах есть рейсы, выполняемые самолетом с максимальной дальностью перелета?
          
              В решении обязательно должно быть использовано - Подзапрос
          
          3	Вывести 10 рейсов с максимальным временем задержки вылета	
          
              В решении обязательно должно быть использовано - Оператор LIMIT 
          
          4	Были ли брони, по которым не были получены посадочные талоны?	
          
              В решении обязательно должно быть использовано - Верный тип JOIN
          
          5	Найдите свободные места для каждого рейса, их % отношение к общему количеству мест в самолете.
              Добавьте столбец с накопительным итогом - суммарное накопление количества вывезенных пассажиров 
              из каждого аэропорта на каждый день. Т.е. в этом столбце должна отражаться накопительная сумма - 
              сколько человек уже вылетело из данного аэропорта на этом или более ранних рейсах за день.	
              
              В решении обязательно должно быть использовано - Оконная функция
              
          6	Найдите процентное соотношение перелетов по типам самолетов от общего количества.	
          
              В решении обязательно должно быть использовано - Подзапрос - Оператор ROUND
          
          7	Были ли города, в которые можно  добраться бизнес - классом дешевле, чем эконом-классом в рамках перелета?
          
              В решении обязательно должно быть использовано - CTE
          
          8	Между какими городами нет прямых рейсов?	
          
              В решении обязательно должно быть использовано - Декартово произведение в предложении FROM
              Самостоятельно созданные представления (если облачное подключение, то без представления)
              Оператор EXCEPT
              
          9	Вычислите расстояние между аэропортами, связанными прямыми рейсами, сравните с допустимой максимальной дальностью 
              перелетов  в самолетах, обслуживающих эти рейсы *	
              
              В решении обязательно должно быть использовано - Оператор RADIANS или использование sind/cosd - CASE
              
              
          * - В облачной базе координаты находятся в столбце airports_data.coordinates - работаете, как с массивом. 
          В локальной базе координаты находятся в столбцах airports.longitude и airports.latitude.
          
