--ЗАДАНИЕ №1
--В каких городах больше одного аэропорта?

--Логика запроса: Для решения достаточно таблицы airports. Сгруппировав по городам таблицу airports, подсчитываем количество аэропортов в них. 
--После этого выводим те города, в которых количество аэропортов больше единицы 

select city
from airports a 
group by city
having count(airport_code) > 1

--ЗАДАНИЕ №2
--В каких аэропортах есть рейсы, выполняемые самолетом с максимальной дальностью перелета?
--нужно выполнить с использованием подзапроса

--Логика запроса: Для решения необходимы таблицы:flights, airports, aircrafts. 
--Обогощаем таблицу flights приджойнив таблицу airports. В условии (используя подзапрос) отбираем те самолеты, 
--у которых дальность (еще один подзапрос) максимальная
--группируем по столбцам departure_airport, airport_code

select ap.airport_code
from flights f 
join airports ap on ap.airport_code = f.departure_airport
where f.aircraft_code = (
	select aircraft_code 
	from aircrafts ac 
	where range = (
		select max(range) 
		from aircrafts)
		) 
group by f.departure_airport, ap.airport_code

--ЗАДАНИЕ №3
--Вывести 10 рейсов с максимальным временем задержки вылета
--нужно выполнить с использованием оператора LIMIT

--Логика запроса: Для решения достаточно таблицы flights. Создаем столбец из разницы 
--значений столбцов actual_departure - scheduled_departure, это и будет задержкой рейса.
--В условии нам нужно исключить рейсы с нулевым actual_departure(отмененные рейсы).
--Упорядочим по сгенерированному столбцу от большего к меньшему и отберем 10 первых

select flight_id, (actual_departure - scheduled_departure) zaderzhka
from flights f
where actual_departure notnull 
order by zaderzhka desc 
limit 10

--ЗАДАНИЕ №4
--Были ли брони, по которым не были получены посадочные талоны?
--использовать верный тип JOIN

--Логика запроса: Для решения необходимы таблицы:bookings, tickets, boarding_passes, flights.
--В выводе будет или "Были", если брони были, или "Не были" в обратном случае.
--Обогащаем bookings приджойнив к нему tickets, и джойним, уже используя left join, boarding_passes.
--В условии отбираем где значения bp.ticket_no пустые  

select case 
		   when count(b.book_ref) > 0 
		   then 'Были'
		   else 'Не были' 
	   end as bookings
from bookings b 
join tickets t on t.book_ref = b.book_ref 
left join boarding_passes bp on bp.ticket_no = t.ticket_no 
where bp.ticket_no is null 

						  
select * from flights 

--ЗАДАНИЕ №5
--Найдите свободные места для каждого рейса, их % отношение к общему количеству мест в самолете.
--Добавьте столбец с накопительным итогом - суммарное накопление количества вывезенных пассажиров 
--из каждого аэропорта на каждый день. Т.е. в этом столбце должна отражаться накопительная сумма - 
--сколько человек уже вылетело из данного аэропорта на этом или более ранних рейсах в течении дня.
--использовать Оконная функция -- Подзапросы или/и cte

--Логика запроса: Для решения необходимы таблицы:flights, seats, boarding_passes.
--В запросе два подзапроса s и bp. В подзапросе s, сгруппировав таблицу seats по aircraft_code,  
--считаем количество мест всего в рамках группы.   
--В подзапросе bp, сгруппировав таблицу boarding_passes по flight_id, 
--считаем количество занятых мест в рамках группы 
--Приджойним к flights s и bp, bp джойним с помощью left join. В условии actual_departure is not null,
--если нет даты вылета, значит самолет не вылетал и нам они не интересны. В выводе результаты вычислений:
--1. Считаем количество свободных мест. Общее количество мест в самолете минус количество занятых
--2. Процент свободных мест. Количество свободных мест * 100 / Общее количество мест
--3. В оконной функции считаем нарастающий итог, разбив на секции departure_airport, 
--actual_departure сконвертированный из timestamp в date и сортировав по actual_departure
-- 

select f.flight_id, departure_airport, actual_departure::date, s.quantity_of_seats - coalesce(bp.occupied_seats_1, 0) available_seats, -- свободные места
	round((s.quantity_of_seats - coalesce(bp.occupied_seats_1, 0)) * 100.0 / s.quantity_of_seats, 2) percentage_of_available, -- процент свободных мест
	sum(coalesce(bp.occupied_seats_1, 0)) over(partition by f.departure_airport, actual_departure::date order by actual_departure) departed_passengers -- количество вывезенных пассажиров
from flights f 
join (select aircraft_code, count(*) quantity_of_seats
	  from seats
	  group by aircraft_code) s on s.aircraft_code = f.aircraft_code 
left join (select flight_id, count(*) occupied_seats_1
		   from boarding_passes
		   group by flight_id) bp on f.flight_id = bp.flight_id 
where actual_departure is not null
order by departure_airport, f.actual_departure

--ЗАДАНИЕ №6
--Найдите процентное соотношение перелетов по типам самолетов от общего количества.
--использовать - Подзапрос или оконная функция - Оператор ROUND

--Логика запроса: Для решения достаточно таблицы flights. Таблицу группируем по столбцу aircraft_code
--добавляем столбец вычислением процентного соотношение перелетов по типам самолетов от общего количества 
--и округляем с помощью оператора ROUND
--Вычисление: считаем количество рейсов в рамках групп, делим на общее (вычисленное в подзапросе) количество 
--рейсов и умножаем на 100
 
select aircraft_code, round(count(aircraft_code) * 100.0 / (select count(flight_id) from flights), 2) percentage_of_flights
from flights f
group by aircraft_code

--ЗАДАНИЕ №7
--Были ли города, в которые можно  добраться бизнес - классом дешевле, чем эконом-классом в рамках перелета?
--использовать - CTE

--Логика запроса: Для решения необходимы таблицы:flights, airports. В запросе два CTE. В первом выдергиваем 
--значения таблицы, где tf.fare_conditions = 'Economy'. В другом fare_conditions = 'Business'. Джойним их 
--и плюс еще таблицу airports. Если в обогащенной таблице есть значения где максимальная стоимость эконом класса 
--будет больше минимальной стоимости бизнес класса, выводится 'Были', иначе 'Не были'

with economy_amount as(
	select f.flight_id, f.arrival_airport, max(tf.amount) max_eco_amount
	from flights f 
	join ticket_flights tf on tf.flight_id = f.flight_id 
	where tf.fare_conditions = 'Economy'
	group by f.flight_id
), business_amount as(
	select f.flight_id, f.arrival_airport, min(tf.amount) min_bus_amount
	from flights f 
	join ticket_flights tf on tf.flight_id = f.flight_id 
	where tf.fare_conditions = 'Business'
	group by f.flight_id
)
select  case 
			when count(*) > 0 
			then 'Были'
			else 'Не были' 
		end as city
from economy_amount ea
join business_amount ba on ba.flight_id = ea.flight_id
join airports a on a.airport_code = ea.arrival_airport
where max_eco_amount > min_bus_amount

--ЗАДАНИЕ №8
--Между какими городами нет прямых рейсов?
--использовать - Декартово произведение в предложении FROM,
--Самостоятельно созданные представления (если облачное подключение, то без представления), 
--Оператор EXCEPT

--Логика запроса: Для решения необходимы таблицы:flights, airports. 
--Создаем материализованное представление real_direct_flights, где таблицу
--flights дважды джойним с airports, по аэропорту отправки и аэропорту
--прибытия. 
--С помощью декартового произведения получаем все возможные вариации город вылета -
--город прилета из таблицы airports, в условии избавляемся от зеркальных вариантов
--Находим разность между Декартовым произведением и таблицей из материализованного 
--представления с помощью оператора EXCEPT

create materialized view real_direct_flights as
	select a1.city dep_city, a2.city  arr_city
	from flights f 
	join airports a1 on a1.airport_code = f.departure_airport
	join airports a2 on a2.airport_code = f.arrival_airport
with data

select a1.city city_a, a2.city city_b
from airports a1, airports a2
where a1.city <> a2.city
except
select *
from real_direct_flights

--ЗАДАНИЕ №9
--Вычислите расстояние между аэропортами, связанными прямыми рейсами, сравните с допустимой 
--максимальной дальностью перелетов в самолетах, обслуживающих эти рейсы 
--использовать - Оператор RADIANS или использование sind/cosd - CASE 

--Логика запроса: Для решения необходимы таблицы:flights, aircrafts, airports. Создаем функцию 
--для расчета расстояний между аэропортами, используя их географические координаты. 
--Используется формула из условия
--в подзапросе получаем столбцы departure_airport, arrival_airport, aircraft_code из таблицы
--flights, группируем по этим же столбцам. Обогащаем приджойнив таблицу aircrafts и два раза приджойнив
--airports. В первом случае по столбцу departure_airport, во втором случае по arrival_airport.
--Выводятся столбцы Аэропорты отправки и прибытия, рассчитанная дистанция и разница между этой дистанцией
--и допустимой максимальной дальностью перелета самолета, обслуживающего данный рейс

CREATE OR REPLACE FUNCTION distance(
	lat1 double precision,
	lon1 double precision,
	lat2 double precision,
	lon2 double precision)
    RETURNS double precision
    LANGUAGE 'plpgsql'
AS $$
DECLARE
    R integer = 6371; -- средний радиус земного шара
   
	d1 double precision = sind(lat1) * sind(lat2);
	d2 double precision = cosd(lat1) * cosd(lat2);
	d3 double precision = cosd(lon1 - lon2);
   
    distance double precision = acos(d1 + d2 * d3) * R;  
BEGIN                                                     
    RETURN distance;        
END
$$;

select departure_airport, arrival_airport, 
	distance(a_dep.latitude, a_dep.longitude, a_arr.latitude, a_arr.longitude) distance,
	a."range" - distance(a_dep.latitude, a_dep.longitude, a_arr.latitude, a_arr.longitude) difference
from (select departure_airport, arrival_airport, aircraft_code from flights f group by departure_airport, arrival_airport, aircraft_code)f
join aircrafts a on a.aircraft_code = f.aircraft_code
join airports a_dep on a_dep.airport_code = f.departure_airport 
join airports a_arr on a_arr.airport_code = f.arrival_airport 

