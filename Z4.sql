/*
Napisac procedurê, która bêdzie mieæ 3 parametry

CREATE PROCEDURE dbo.szukaj_os
( @imie nnvarchar(40) = NULL
, @nazwisko nvarchar(40) = NULL
, @miasto_nazwa nvarchar(40) = NULL
)

Zawsze bêdzie zwracaæ
imie, nazwisko, id_osoby, miasto.nazwa (miasto gdzie osoba mieszka), woj.nazwa

EXEC szukaj_os @imie = N'Maciej'
zwróci wszystkie osoby o imieniu Maciej

EXEC szukaj_os @imie='Maciej', @nazwisko='Stodolski'
zwróci osoby o imieniu Maciej i Nazwisku Stodolski

EXEC szukaj_os @imie='Maciej', @miasto_nazwa='Warszawa'
zwróci osoby o imieniu Maciej mieszkaj¹ce w miescie o nazwie
Warszawa

Czyli wszystkie NIE NULL warunki tworz¹ warunek WHERE

Sa 2 metody na zrobienie
Albo w procedurze sprawdzamy czy wszyskie 3 warunki nie s¹ NULL
i robimy do tego zapytanie,
Potem sprawdzamy wszystkie mozliwe pary warunków
i do kazdej pary zapytanie
Potem pojedyncze warunki i do kazdego zapytanie
Zatem zapytan bedzie masa

Drugie:
deklarujemy zmienna @zapytanie nvarchar(3000)
zapytanie wstawiamy do zmiennej tekstowej
W chmurze jest podpowied¿ jak budowac warunek WHERE z4_pomoc
i na koniec najpier robimy select tego zapytania aby sprawdziæ czy dzia³a a potem
ka¿emy je uruchomiæ

EXEC sp_sqlexec @zapytanie
*/

CREATE PROCEDURE dbo.szukaj_os ( @imie nvarchar(40) = NULL, @nazwisko nvarchar(40) = NULL, @miasto_nazwa nvarchar(40) = NULL )
AS 
	BEGIN
		SELECT 
			o.imie,
			o.nazwisko,
			m.nazwa,
			w.nazwa
		FROM OSOBY o
		JOIN MIASTA m ON (o.id_miasta = m.id_miasta)
		JOIN WOJ w ON (m.kod_woj = w.kod_woj)
		WHERE 
			(o.imie = @imie OR (@imie IS NULL))
			AND (o.nazwisko = @nazwisko OR (@nazwisko IS NULL))
			AND (m.nazwa = @miasto_nazwa OR (@miasto_nazwa IS NULL))
			
	END

SELECT 
		o.imie,
		o.nazwisko,
		m.nazwa,
		w.nazwa
		FROM OSOBY o
		JOIN MIASTA m ON (o.id_miasta = m.id_miasta)
		JOIN WOJ w ON (m.kod_woj = w.kod_woj)

/* imie                                     nazwisko                                 nazwa                                    nazwa
---------------------------------------- ---------------------------------------- ---------------------------------------- ----------------------------------------
Maciej                                   Stach                                    Wesoła                                   Mazowieckie
Jan                                      Kowalski                                 Kalisz                                   Wielkopolskie
Janusz                                   Star                                     Kalisz                                   Wielkopolskie
Kuba                                     Kot                                      Wesoła                                   Mazowieckie
Paweł                                    Matera                                   Wesoła                                   Mazowieckie
Kamil                                    Matera                                   Kalisz                                   Wielkopolskie
Michał                                   Baran                                    Kalisz                                   Wielkopolskie
Wiktoria                                 Beczek                                   Wesoła                                   Mazowieckie
Olga                                     Zbucka                                   Wesoła                                   Mazowieckie
Alicja                                   Rybkowska                                Kalisz                                   Wielkopolskie
Milena                                   Galińska                                 Kalisz                                   Wielkopolskie

(11 rows affected) */



EXEC szukaj_os @imie = N'Wiktoria'
/* imie                                     nazwisko                                 nazwa                                    nazwa
---------------------------------------- ---------------------------------------- ---------------------------------------- ----------------------------------------
Wiktoria                                 Beczek                                   Wesoła                                   Mazowieckie

(1 row affected)*/

EXEC szukaj_os @imie = N'Janusz', @nazwisko = N'Star'
/* imie                                     nazwisko                                 nazwa                                    nazwa
---------------------------------------- ---------------------------------------- ---------------------------------------- ----------------------------------------
Janusz                                   Star                                     Ciechanów                                Mazowieckie

(1 row affected) */
