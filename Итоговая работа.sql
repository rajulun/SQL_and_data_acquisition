--������� �1
--� ����� ������� ������ ������ ���������?

--������ �������: ��� ������� ���������� ������� airports. ������������ �� ������� ������� airports, ������������ ���������� ���������� � ���. 
--����� ����� ������� �� ������, � ������� ���������� ���������� ������ ������� 

select city
from airports a 
group by city
having count(airport_code) > 1

--������� �2
--� ����� ���������� ���� �����, ����������� ��������� � ������������ ���������� ��������?
--����� ��������� � �������������� ����������

--������ �������: ��� ������� ���������� �������:flights, airports, aircrafts. 
--��������� ������� flights ���������� ������� airports. � ������� (��������� ���������) �������� �� ��������, 
--� ������� ��������� (��� ���� ���������) ������������
--���������� �� �������� departure_airport, airport_code

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

--������� �3
--������� 10 ������ � ������������ �������� �������� ������
--����� ��������� � �������������� ��������� LIMIT

--������ �������: ��� ������� ���������� ������� flights. ������� ������� �� ������� 
--�������� �������� actual_departure - scheduled_departure, ��� � ����� ��������� �����.
--� ������� ��� ����� ��������� ����� � ������� actual_departure(���������� �����).
--���������� �� ���������������� ������� �� �������� � �������� � ������� 10 ������

select flight_id, (actual_departure - scheduled_departure) zaderzhka
from flights f
where actual_departure notnull 
order by zaderzhka desc 
limit 10

--������� �4
--���� �� �����, �� ������� �� ���� �������� ���������� ������?
--������������ ������ ��� JOIN

--������ �������: ��� ������� ���������� �������:bookings, tickets, boarding_passes, flights.
--� ������ ����� ��� "����", ���� ����� ����, ��� "�� ����" � �������� ������.
--��������� bookings ���������� � ���� tickets, � �������, ��� ��������� left join, boarding_passes.
--� ������� �������� ��� �������� bp.ticket_no ������  

select case 
		   when count(b.book_ref) > 0 
		   then '����'
		   else '�� ����' 
	   end as bookings
from bookings b 
join tickets t on t.book_ref = b.book_ref 
left join boarding_passes bp on bp.ticket_no = t.ticket_no 
where bp.ticket_no is null 

						  
select * from flights 

--������� �5
--������� ��������� ����� ��� ������� �����, �� % ��������� � ������ ���������� ���� � ��������.
--�������� ������� � ������������� ������ - ��������� ���������� ���������� ���������� ���������� 
--�� ������� ��������� �� ������ ����. �.�. � ���� ������� ������ ���������� ������������� ����� - 
--������� ������� ��� �������� �� ������� ��������� �� ���� ��� ����� ������ ������ � ������� ���.
--������������ ������� ������� -- ���������� ���/� cte

--������ �������: ��� ������� ���������� �������:flights, seats, boarding_passes.
--� ������� ��� ���������� s � bp. � ���������� s, ������������ ������� seats �� aircraft_code,  
--������� ���������� ���� ����� � ������ ������.   
--� ���������� bp, ������������ ������� boarding_passes �� flight_id, 
--������� ���������� ������� ���� � ������ ������ 
--���������� � flights s � bp, bp ������� � ������� left join. � ������� actual_departure is not null,
--���� ��� ���� ������, ������ ������� �� ������� � ��� ��� �� ���������. � ������ ���������� ����������:
--1. ������� ���������� ��������� ����. ����� ���������� ���� � �������� ����� ���������� �������
--2. ������� ��������� ����. ���������� ��������� ���� * 100 / ����� ���������� ����
--3. � ������� ������� ������� ����������� ����, ������ �� ������ departure_airport, 
--actual_departure ����������������� �� timestamp � date � ���������� �� actual_departure
-- 

select f.flight_id, departure_airport, actual_departure::date, s.quantity_of_seats - coalesce(bp.occupied_seats_1, 0) available_seats, -- ��������� �����
	round((s.quantity_of_seats - coalesce(bp.occupied_seats_1, 0)) * 100.0 / s.quantity_of_seats, 2) percentage_of_available, -- ������� ��������� ����
	sum(coalesce(bp.occupied_seats_1, 0)) over(partition by f.departure_airport, actual_departure::date order by actual_departure) departed_passengers -- ���������� ���������� ����������
from flights f 
join (select aircraft_code, count(*) quantity_of_seats
	  from seats
	  group by aircraft_code) s on s.aircraft_code = f.aircraft_code 
left join (select flight_id, count(*) occupied_seats_1
		   from boarding_passes
		   group by flight_id) bp on f.flight_id = bp.flight_id 
where actual_departure is not null
order by departure_airport, f.actual_departure

--������� �6
--������� ���������� ����������� ��������� �� ����� ��������� �� ������ ����������.
--������������ - ��������� ��� ������� ������� - �������� ROUND

--������ �������: ��� ������� ���������� ������� flights. ������� ���������� �� ������� aircraft_code
--��������� ������� ����������� ����������� ����������� ��������� �� ����� ��������� �� ������ ���������� 
--� ��������� � ������� ��������� ROUND
--����������: ������� ���������� ������ � ������ �����, ����� �� ����� (����������� � ����������) ���������� 
--������ � �������� �� 100
 
select aircraft_code, round(count(aircraft_code) * 100.0 / (select count(flight_id) from flights), 2) percentage_of_flights
from flights f
group by aircraft_code

--������� �7
--���� �� ������, � ������� �����  ��������� ������ - ������� �������, ��� ������-������� � ������ ��������?
--������������ - CTE

--������ �������: ��� ������� ���������� �������:flights, airports. � ������� ��� CTE. � ������ ����������� 
--�������� �������, ��� tf.fare_conditions = 'Economy'. � ������ fare_conditions = 'Business'. ������� �� 
--� ���� ��� ������� airports. ���� � ����������� ������� ���� �������� ��� ������������ ��������� ������ ������ 
--����� ������ ����������� ��������� ������ ������, ��������� '����', ����� '�� ����'

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
			then '����'
			else '�� ����' 
		end as city
from economy_amount ea
join business_amount ba on ba.flight_id = ea.flight_id
join airports a on a.airport_code = ea.arrival_airport
where max_eco_amount > min_bus_amount

--������� �8
--����� ������ �������� ��� ������ ������?
--������������ - ��������� ������������ � ����������� FROM,
--�������������� ��������� ������������� (���� �������� �����������, �� ��� �������������), 
--�������� EXCEPT

--������ �������: ��� ������� ���������� �������:flights, airports. 
--������� ����������������� ������������� real_direct_flights, ��� �������
--flights ������ ������� � airports, �� ��������� �������� � ���������
--��������. 
--� ������� ����������� ������������ �������� ��� ��������� �������� ����� ������ -
--����� ������� �� ������� airports, � ������� ����������� �� ���������� ���������
--������� �������� ����� ���������� ������������� � �������� �� ������������������ 
--������������� � ������� ��������� EXCEPT

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

--������� �9
--��������� ���������� ����� �����������, ���������� ������� �������, �������� � ���������� 
--������������ ���������� ��������� � ���������, ������������� ��� ����� 
--������������ - �������� RADIANS ��� ������������� sind/cosd - CASE 

--������ �������: ��� ������� ���������� �������:flights, aircrafts, airports. ������� ������� 
--��� ������� ���������� ����� �����������, ��������� �� �������������� ����������. 
--������������ ������� �� �������
--� ���������� �������� ������� departure_airport, arrival_airport, aircraft_code �� �������
--flights, ���������� �� ���� �� ��������. ��������� ���������� ������� aircrafts � ��� ���� ����������
--airports. � ������ ������ �� ������� departure_airport, �� ������ ������ �� arrival_airport.
--��������� ������� ��������� �������� � ��������, ������������ ��������� � ������� ����� ���� ����������
--� ���������� ������������ ���������� �������� ��������, �������������� ������ ����

CREATE OR REPLACE FUNCTION distance(
	lat1 double precision,
	lon1 double precision,
	lat2 double precision,
	lon2 double precision)
    RETURNS double precision
    LANGUAGE 'plpgsql'
AS $$
DECLARE
    R integer = 6371; -- ������� ������ ������� ����
   
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

