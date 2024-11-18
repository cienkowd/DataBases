/*
grupa wtorek 10.30 - 12.00
projekt na 2 zajêcia do soboty przed majówk¹

Z5.1

X,Y,Z to s¹ nazwiska, które Pañstwo juz macie w swojej bazie
Np u mnie X = Stodolski, Y = Korytkowski, Z - Neptun
Firmy A,B,C to firmy istniej¹ce w Pañstwa bazie
Np. u mnie A = PW, B = HP, C = F£P

Prosze dodaæ etaty tym osobom aby

W Firmie A by³y
2 etaty osoby X
2 etaty osoby Y
1 etat osoby Z

W firmie B by³y
3 etaty osoby Y

W firmie C
2 etaty osoby Y
1 etat osoby Z

Proszê wstawiæ nazwiska do tabeli tymczasowej
Musz¹ byæ unikalne, dlatego doda³em klucz g³owny
CREATE TABLE #n (nazwiska nvarchar(100) not null constraint PK_nazw PRIMARY KEY)
INSERT INTO #n(nazwiska) VALUES (X) -- kazdy nazwiska ze swojej bazy wstawia
INSERT INTO #n(nazwiska) VALUES (Y)
INSERT INTO #n(nazwiska) VALUES (Z)

Proszê napisaæ zapytanie (lub procedurê - do wyboru)
która znajdzie firmy w których pracujê wszystkie osoby z tabeli #n
Czyli jezeli pracuje tylko X i Z a Y nie to nie pokazujemy takiej firmy
Musz¹ w niej pracowaæ wszystkie 3 osoby

Informacje znajdziecie na wczorajszym wyk³adzie

Z5.2

Proszê do tabeli FIRMY dodaæ kolumnê ILE_AKT_ET int domyslnie 0 (NOT NULL)
ALTER table ADD col ...

Proszê zaktualizowac liczbê aktualnych etatów w kazdej z firm - wskazowki
na poprzednich 2 wyk³adach by³y
Mo¿na próbowac kursorem po firmach mo¿na jednym UPDATE ...
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
INSERT INTO #T(nazwiska) VALUES ('Galiñska')

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
PP        5           Politechnika Poznañska                   60-965       Plac Marii Sk³odowskiej-Curie 5          1
PS        8           Politechnika Szczeciñska                 71-899       ul. Kazimierza Pu³askiego                0
PW        2           Politechnika Warszawska                  00-661       p. Politechniki 1                        5
SGH       2           Szko³a G³ówna Handlowa                   02-554       al. Niepodleg³oœci 162                   4
UP        5           Uniwersytet Poznañski                    61-712       ul. Wieniawskiego 1                      4
UW        2           Uniwersytet Warszawski                   00-927       ul. Krakowskie Przedmieœcie 26/28        5

(6 rows affected)
*/