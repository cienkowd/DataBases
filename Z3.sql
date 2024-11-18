/*
Z3.1 proszê wykonaæ zapytanie
select e.id_osoby, count(*) as ile_et
from etaty e
group by e.id_osoby
order by 2 DESC
je¿eli osób z liczb¹ etatów wiêksz¹ jak 2 jest mniej jak 4 to proszê pododawaæ im etaty
teraz prosze wykonaæ zapytanie pokazuj¹ce:
id_osoby,imie,nazwisko,pensja,nazwa_skr,nazwa
pokazjace dane najmniejszej pensji dla kazdej osoby.
to beda 2 zapytania - jedne grupuj¹ce po id_osoby i szukajace minimum a drugie pokazujace detale. wynik zapisujemy w tabeli tymczasowej #ot
*/

/* Z3.1 
komendy dodajace potrzebne etaty, wklejam w komentarzu poniewaz wykonuje je tylko raz i pozniej nie sa mi potrzebne

INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od) VALUES (8, 'PW', 'magazynier', 3300, '2015')
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od) VALUES (9, 'UW', 'magazynier', 3600, '2016')
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od) VALUES (8, 'PW', 'kucharz', 4000, '2015')
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od) VALUES (9, 'UW', 'kucharz', 4000, '2016')

SELECT e.id_osoby, COUNT(*) AS ile_et
FROM etaty e
GROUP BY e.id_osoby
ORDER BY 2 DESC

id_osoby    ile_et
----------- -----------
4           5
7           3
8           3
9           3
10          1
11          1
1           1
2           1
3           1

(9 rows affected)*/

IF OBJECT_ID(N'tempdb..#ot') IS NOT NULL 
	DROP TABLE #ot

SELECT e.id_osoby, MIN(e.pensja) AS min_pensja
	FROM etaty e
	GROUP BY e.id_osoby

/*
id_osoby    min_pensja
----------- -----------
1           4000
2           3000
3           5000
4           1000
7           900
8           3300
9           3500
10          4500
11          2500

(9 rows affected)*/

SELECT o.id_osoby, o.imie, o.nazwisko, e.pensja AS [min_pensja] INTO #ot
	FROM etaty e
	JOIN osoby o ON (e.id_osoby = o.id_osoby)
	JOIN firmy f ON (e.id_firmy = f.nazwa_skr)
	JOIN (SELECT e.id_osoby, MIN(e.pensja) AS min_pensja
			FROM etaty e
			GROUP BY e.id_osoby) X ON (X.min_pensja = e.pensja AND X.id_osoby = e.id_osoby) 
	ORDER BY 1 ASC

SELECT * FROM #ot

/*
id_osoby    imie                                     nazwisko                                 min_pensja
----------- ---------------------------------------- ---------------------------------------- -----------
1           Maciej                                   Stach                                    4000
2           Jan                                      Kowalski                                 3000
3           Janusz                                   Star                                     5000
4           Kuba                                     Kot                                      1000
7           Micha³                                   Baran                                    900
8           Wiktoria                                 Beczek                                   3300
9           Olga                                     Zbucka                                   3500
10          Alicja                                   Rybkowska                                4500
11          Milena                                   Galiñska                                 2500

(9 rows affected)*/

/*
Z3.2 korzystaj¹c z tabeli #ot prosze znalezc najmniejsza pensje w bazie i pokazaæ jej dane (dane z tabeli #ot)*/

SELECT *
	FROM #ot
	WHERE #ot.min_pensja = (SELECT MIN(#ot.min_pensja) FROM #ot)

/*
id_osoby    imie                                     nazwisko                                 min_pensja
----------- ---------------------------------------- ---------------------------------------- -----------
7           Micha³                                   Baran                                    900

(1 row affected)*/


/*
Z3.3 proszê pokazaæ firmy je¿eli w tych firmach nie pracowa³a nigdy osoba o nazwisku (prosze sobie wybrac nazwisko). Zapytanie z not exists !!!
jezeli kiedykolwiek pracowal w danej firmie takowy osobnik to tej firmy nie pokazujemy
przykladowo w firmie X pracowa Stodolski i Mis. Pokazujemy tylko firmy gdzie nie pracowal Mis wiec firmy X nie mozemy pokazaæ.*/

SELECT f.* 
	FROM firmy f
	WHERE NOT EXISTS ( SELECT DISTINCT fW.nazwa_skr
							FROM firmy fW
							JOIN etaty eW ON (fW.nazwa_skr = eW.id_firmy)
							JOIN osoby oW ON (eW.id_osoby = oW.id_osoby)
							WHERE oW.nazwisko = 'Kot' AND fW.nazwa_skr = f.nazwa_skr)
/*
nazwa_skr id_miasta   nazwa                                    kod_pocztowy ulica
--------- ----------- ---------------------------------------- ------------ ----------------------------------------
PP        5           Politechnika Poznañska                   60-965       Plac Marii Sk³odowskiej-Curie 5
PS        8           Politechnika Szczeciñska                 71-899       ul. Kazimierza Pu³askiego
SGH       2           Szko³a G³ówna Handlowa                   02-554       al. Niepodleg³oœci 162
UP        5           Uniwersytet Poznañski                    61-712       ul. Wieniawskiego 1
UW        2           Uniwersytet Warszawski                   00-927       ul. Krakowskie Przedmieœcie 26/28

(5 rows affected)*/

/*
Z3.4 pokazac firmy w których nie pracowa³ nigdy nikt z Warszawy (mozna inne miasto)
nazwa_skr,nazwa,miast,woj
jezeli w danej firmie pracuje 2 jeden z Weso³ej a drugi z Warszawy to nie wolno jej pokazac
*/

SELECT f.nazwa_skr, f.nazwa, m.nazwa, w.nazwa
	FROM firmy f
	JOIN miasta m ON (f.id_miasta = m.id_miasta)
	JOIN woj w ON (m.kod_woj = w.kod_woj)
	WHERE NOT EXISTS ( SELECT DISTINCT fW.nazwa_skr
							FROM firmy fW
							JOIN etaty eW ON (fW.nazwa_skr = eW.id_firmy)
							JOIN osoby oW ON (eW.id_osoby = oW.id_osoby)
							JOIN miasta mW ON(oW.id_miasta = mW.id_miasta)
							WHERE mW.nazwa = 'Warszawa' AND fW.nazwa_skr = f.nazwa_skr)

/*
nazwa_skr nazwa                                    nazwa                                    nazwa
--------- ---------------------------------------- ---------------------------------------- ----------------------------------------
PP        Politechnika Poznañska                   Poznañ                                   Wielkopolskie
PS        Politechnika Szczeciñska                 Szczecin                                 Zachodniopomorskie
PW        Politechnika Warszawska                  Warszawa                                 Mazowieckie
SGH       Szko³a G³ówna Handlowa                   Warszawa                                 Mazowieckie
UP        Uniwersytet Poznañski                    Poznañ                                   Wielkopolskie
UW        Uniwersytet Warszawski                   Warszawa                                 Mazowieckie

(6 rows affected)*/