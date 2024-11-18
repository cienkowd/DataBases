/*
grupa wtorek 10.30 - 12.00
projekt na 2 zaj�cia do soboty przed maj�wk�

Z5.1

X,Y,Z to s� nazwiska, kt�re Pa�stwo juz macie w swojej bazie
Np u mnie X = Stodolski, Y = Korytkowski, Z - Neptun
Firmy A,B,C to firmy istniej�ce w Pa�stwa bazie
Np. u mnie A = PW, B = HP, C = F�P

Prosze doda� etaty tym osobom aby

W Firmie A by�y
2 etaty osoby X
2 etaty osoby Y
1 etat osoby Z

W firmie B by�y
3 etaty osoby Y

W firmie C
2 etaty osoby Y
1 etat osoby Z

Prosz� wstawi� nazwiska do tabeli tymczasowej
Musz� by� unikalne, dlatego doda�em klucz g�owny
CREATE TABLE #n (nazwiska nvarchar(100) not null constraint PK_nazw PRIMARY KEY)
INSERT INTO #n(nazwiska) VALUES (X) -- kazdy nazwiska ze swojej bazy wstawia
INSERT INTO #n(nazwiska) VALUES (Y)
INSERT INTO #n(nazwiska) VALUES (Z)

Prosz� napisa� zapytanie (lub procedur� - do wyboru)
kt�ra znajdzie firmy w kt�rych pracuj� wszystkie osoby z tabeli #n
Czyli jezeli pracuje tylko X i Z a Y nie to nie pokazujemy takiej firmy
Musz� w niej pracowa� wszystkie 3 osoby

Informacje znajdziecie na wczorajszym wyk�adzie

Z5.2

Prosz� do tabeli FIRMY doda� kolumn� ILE_AKT_ET int domyslnie 0 (NOT NULL)
ALTER table ADD col ...

Prosz� zaktualizowac liczb� aktualnych etat�w w kazdej z firm - wskazowki
na poprzednich 2 wyk�adach by�y
Mo�na pr�bowac kursorem po firmach mo�na jednym UPDATE ...
*/

/* 
A-UW
INSERT INTO ETATY(id_osoby, id_firmy, stanowisko, pensja, od) VALUES (10, 'UW', 'magazynier', 5500, '2020')
INSERT INTO ETATY(id_osoby, id_firmy, stanowisko, pensja, od) VALUES (11, 'UW', 'specjalista', 6000, '2022')

B-SGH
INSERT INTO ETATY(id_osoby, id_firmy, stanowisko, pensja, od) VALUES (10, 'SGH', 'doktor', 5500, '2020')
INSERT INTO ETATY(id_osoby, id_firmy, stanowisko, pensja, od) VALUES (10, 'SGH', 'magister', 6500, '2021')
INSERT INTO ETATY(id_osoby, id_firmy, stanowisko, pensja, od) VALUES (10, 'SGH', 'profesor', 7500, '2022')

C-UP
INSERT INTO ETATY(id_osoby, id_firmy, stanowisko, pensja, od) VALUES (10, 'UP', 'robotnik', 1500, '2010')
INSERT INTO ETATY(id_osoby, id_firmy, stanowisko, pensja, od) VALUES (10, 'UP', 'kasjer', 2500, '2013')
*/



DROP TABLE #T


CREATE TABLE #T (nazwiska nvarchar(100) not null constraint PK_nazwa PRIMARY KEY)
INSERT INTO #T(nazwiska) VALUES ('Baran')
INSERT INTO #T(nazwiska) VALUES ('Rybkowska')
INSERT INTO #T(nazwiska) VALUES ('Gali�ska')

SELECT e.id_firmy, COUNT(DISTINCT #T.nazwiska) AS ilosc
	FROM ETATY e
	JOIN OSOBY o ON (o.id_osoby=e.id_osoby)
    JOIN #T ON (#T.nazwiska=o.nazwisko)
    GROUP BY e.id_firmy
    HAVING COUNT(DISTINCT #T.nazwiska) = 3

/*
id_firmy ilosc
-------- -----------
UP       3
UW       3

(2 rows affected)
*/

UPDATE FIRMY
	SET ILE_AKT_ET = temp.ILE_AKT_ET
	FROM(
		SELECT f.nazwa_skr, f.nazwa, COUNT(*) as ILE_AKT_ET
			FROM FIRMY f 
			JOIN ETATY e ON (f.nazwa_skr=e.id_firmy) 
			WHERE e.do IS NULL
			GROUP BY f.nazwa_skr, f.nazwa) AS temp
	WHERE FIRMY.nazwa_skr = temp.nazwa_skr

SELECT * FROM FIRMY

/*
nazwa_skr id_miasta   nazwa                                    kod_pocztowy ulica                                    ILE_AKT_ET
--------- ----------- ---------------------------------------- ------------ ---------------------------------------- -----------
PP        5           Politechnika Pozna�ska                   60-965       Plac Marii Sk�odowskiej-Curie 5          1
PS        8           Politechnika Szczeci�ska                 71-899       ul. Kazimierza Pu�askiego                0
PW        2           Politechnika Warszawska                  00-661       p. Politechniki 1                        5
SGH       2           Szko�a G��wna Handlowa                   02-554       al. Niepodleg�o�ci 162                   4
UP        5           Uniwersytet Pozna�ski                    61-712       ul. Wieniawskiego 1                      4
UW        2           Uniwersytet Warszawski                   00-927       ul. Krakowskie Przedmie�cie 26/28        5

(6 rows affected)
*/