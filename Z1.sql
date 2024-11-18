
-- Z1, GR4, Damian, Cienkowski

/* tego nie robimy - bazy są już utworzone */
-- CREATE DATABASE AA
GO

/* te otez nie robimy - po zaloowaniu jesteśmy w prawidłowej (swojej) bazie */
-- use AA

/* kasujemy wszzystkie utworzone wczesniej tabele w odwrotnej
** kolejności do tego jak je tworzyliśmy
** Tworzymy najpier WOJ, potem MIASTA, potem OSOBY, potem FIRMY na końcu ETATY
** Kasujemy odwrotnie
*/
IF OBJECT_ID('ETATY') IS NOT NULL /* mozemy kasowac od ETATY - nie możemy np od WOJ */
	DROP TABLE ETATY

IF OBJECT_ID('FIRMY') IS NOT NULL 
	DROP TABLE FIRMY

IF OBJECT_ID('OSOBY') IS NOT NULL 
	DROP TABLE OSOBY

IF OBJECT_ID('MIASTA') IS NOT NULL 
	DROP TABLE MIASTA

IF OBJECT_ID('WOJ') IS NOT NULL /* jeżeli jest już tabela to kasuj */
	DROP TABLE WOJ

IF OBJECT_ID('FIRMY') IS NOT NULL 
	DROP TABLE FIRMY

IF OBJECT_ID('ETATY') IS NOT NULL 
	DROP TABLE ETATY

IF OBJECT_ID('tempdb..#T') IS NOT NULL
	DROP TABLE #T
GO 
/* po tym słowie SQL wykonuje polecenia ostatnio przesłane fizycznie */

/* tworzymymy tabele w odpowiedniej kolejności */
	
CREATE TABLE dbo.WOJ 
(	kod_woj	nchar(4)		NOT NULL CONSTRAINT PK_WOJ PRIMARY KEY
,	nazwa	nvarchar(40)	NOT NULL
)
GO

CREATE TABLE dbo.MIASTA 
(	kod_woj nchar(4) NOT NULL
		CONSTRAINT FK_WOJ FOREIGN KEY
		REFERENCES WOJ(KOD_WOJ)
,	nazwa	nvarchar(40) NOT NULL
/* klucz głowny samonumerujący */
,	id_miasta int NOT NULL IDENTITY CONSTRAINT PK_MIASTA PRIMARY KEY
)
GO

CREATE TABLE dbo.OSOBY 
(	id_miasta INT NOT NULL 
		CONSTRAINT FK_OSOBY_MIASTA FOREIGN KEY
		REFERENCES MIASTA(ID_MIASTA)
,	imie		nvarchar(40)	NOT NULL
,	nazwisko	nvarchar(40)	NOT NULL
,	adres		nvarchar(100)	NOT NULL
,	id_osoby int NOT NULL IDENTITY 
		CONSTRAINT PK_OSOBY PRIMARY KEY
)
GO

CREATE TABLE dbo.FIRMY
(	nazwa_skr nchar(4) NOT NULL CONSTRAINT FK_NAZWA_SKR PRIMARY KEY
,	id_miasta INT NOT NULL CONSTRAINT FK_FIRMY_MIASTA FOREIGN KEY
		REFERENCES MIASTA(ID_MIASTA)
,	nazwa nvarchar(40) NOT NULL
,	kod_pocztowy nchar(6) NOT NULL
,	ulica nvarchar(40) NOT NULL
,	ILE_AKT_ET int NOT NULL DEFAULT 0
)
GO

CREATE TABLE dbo.ETATY
(	id_osoby INT NOT NULL CONSTRAINT FK_OSOBY FOREIGN KEY 
	REFERENCES OSOBY(ID_OSOBY)
,	id_firmy nchar(4) NOT NULL
,	stanowisko nvarchar(40) NOT NULL
,	pensja INT NOT NULL
,	od DATETIME NOT NULL
,	do DATETIME NULL
,	id_etatu INT NOT NULL IDENTITY CONSTRAINT PK_ETATY PRIMARY KEY
)
GO

/* utwórz tab tymczasową - takowe zaczynają się od # */
/*create table #t (d datetime not null)*/
/* wstawiam datę konwertując z tekstu, format 112 YYYYMMDD */
/*insert into #t (d) values (CONVERT(datetime,'20210130',112))*/
/* wstawiamy akt date z servera sql */
/*insert into #t (d) values (GETDATE())*/
/* przypominam, ze wszystkie kolumny sa NOT NULL za wyjątkiem DO
** czyli OD DATETIME NOT NULL, do DATETIME NULL
** dlatego wszystkie etaty muszą mieć wstawiona jakoś datę OD
** a niekatualne równiez jakąś datę do DO
*/
CREATE TABLE #T
(
	d DATETIME NOT NULL
)


/*
4 województwa
8 miast, w jednym województwie nie ma być żadnego miasta
6 firm (3 w jednym miescie, 2 w innym 1 w jeszcze innym)
11 osób (mieszające w 2 wybranych miastach innych niż miasta w których są firmy)
15 etatów, w tym 5 nieatualnych już (pole DO niepuste)
proszę aby były 2 osoby nie mające zadnych etatów, 3 osoby mających TYLKO niekatualne etaty
Na końccu dane ze wszystkich miast
Udowodnić, że klucze działają próbując kasować województwo w którym sa miasta
lub wpisywać miasto w województwie, którego nie ma w tabeli WOJ
*/

/* jeszcze trzeba dodać polecenia dla FIRMY i ETATY */

INSERT INTO WOJ (kod_woj, nazwa) VALUES ('MAZ', 'Mazowieckie')
INSERT INTO WOJ (kod_woj, nazwa) VALUES ('OPO', 'Opolskie')
INSERT INTO WOJ (kod_woj, nazwa) VALUES ('WLKP', 'Wielkopolskie')
INSERT INTO WOJ (kod_woj, nazwa) VALUES ('ZPM', 'Zachodniopomorskie')

DECLARE @id_wes int	/* do zapamiętania ID jakie dostanie Wesoła */
	,	@id_wwa int /* do zapamiętania ID jakie dostanie Warszawa */
	,	@id_mar int /* do zapamiętania ID jakie dostanie Marki */
	,	@id_otw int /* do zapamiętania ID jakie dostanie Otwock */
	,	@id_poz int /* do zapamiętania ID jakie dostanie Poznań */
	,	@id_kal int /* do zapamiętania ID jakie dostanie Kalisz */
	,	@id_miel int /* do zapamiętania ID jakie dostanie Mielno */
	,	@id_szcz int /* do zapamiętania ID jakie dostanie Szczecin */

	,	@id_ms	int /* do zapamiętania ID jakie dostanie Maciej Stodolski
					** aby mu potem etaty utworzyć */
	,	@id_jk	int /* do zapamiętania ID jakie dostanie J K
					** aby mu potem etaty utworzyć */
	,	@id_js	int /* do zapamiętania ID jakie dostanie Janusz Star
					** aby mu potem etaty utworzyć */
	,	@id_kk	int /* do zapamiętania ID jakie dostanie Kuba Kot
					** aby mu potem etaty utworzyć */
	,	@id_pm	int /* do zapamiętania ID jakie dostanie Paweł Matera
					** aby mu potem etaty utworzyć */
	,	@id_km	int /* do zapamiętania ID jakie dostanie Kamil Matera
					** aby mu potem etaty utworzyć */
	,	@id_mb	int /* do zapamiętania ID jakie dostanie Michał Baran
					** aby mu potem etaty utworzyć */
	,	@id_wb	int /* do zapamiętania ID jakie dostanie Wiktoria Beczek
					** aby mu potem etaty utworzyć */
	,	@id_oz	int /* do zapamiętania ID jakie dostanie Olga Zbucka
					** aby mu potem etaty utworzyć */
	,	@id_ar	int /* do zapamiętania ID jakie dostanie Alicja Rybkowska
					** aby mu potem etaty utworzyć */
	,	@id_mg	int /* do zapamiętania ID jakie dostanie Milena Galińska
					** aby mu potem etaty utworzyć */

INSERT INTO MIASTA (kod_woj, nazwa) VALUES ('MAZ', 'Wesoła')
SET @id_wes = SCOPE_IDENTITY()

INSERT INTO MIASTA (kod_woj, nazwa) VALUES ('MAZ', 'Warszawa')
SET @id_wwa = SCOPE_IDENTITY()

INSERT INTO MIASTA (kod_woj, nazwa) VALUES ('MAZ', 'Marki')
SET @id_mar = SCOPE_IDENTITY()

INSERT INTO MIASTA (kod_woj, nazwa) VALUES ('MAZ', 'Otwock')
SET @id_otw = SCOPE_IDENTITY()

INSERT INTO MIASTA (kod_woj, nazwa) VALUES ('WLKP', 'Poznań')
SET @id_poz = SCOPE_IDENTITY()

INSERT INTO MIASTA (kod_woj, nazwa) VALUES ('WLKP', 'Kalisz')
SET @id_kal = SCOPE_IDENTITY()

INSERT INTO MIASTA (kod_woj, nazwa) VALUES ('ZPM', 'Mielno')
SET @id_miel = SCOPE_IDENTITY()

INSERT INTO MIASTA (kod_woj, nazwa) VALUES ('ZPM', 'Szczecin')
SET @id_szcz = SCOPE_IDENTITY()

INSERT INTO OSOBY (imie, nazwisko, id_miasta, adres) VALUES ('Maciej', 'Stach', @id_wes, 'ul. Klonowa 1')
SET @id_ms = SCOPE_IDENTITY()

INSERT INTO OSOBY (imie, nazwisko, id_miasta, adres) VALUES ('Jan', 'Kowalski', @id_kal, 'ul. Parkowa 44')
SET @id_jk = SCOPE_IDENTITY()

INSERT INTO OSOBY (imie, nazwisko, id_miasta, adres) VALUES ('Janusz', 'Star', @id_kal, 'ul. Nowa 1')
SET @id_js = SCOPE_IDENTITY()

INSERT INTO OSOBY (imie, nazwisko, id_miasta, adres) VALUES ('Kuba', 'Kot', @id_wes, 'ul. Nowa 66')
SET @id_kk = SCOPE_IDENTITY()

INSERT INTO OSOBY (imie, nazwisko, id_miasta, adres) VALUES ('Paweł', 'Matera', @id_wes, 'ul. Nowelska 22')
SET @id_pm = SCOPE_IDENTITY()

INSERT INTO OSOBY (imie, nazwisko, id_miasta, adres) VALUES ('Kamil', 'Matera', @id_kal, 'ul. Szkolna 2')
SET @id_km = SCOPE_IDENTITY()

INSERT INTO OSOBY (imie, nazwisko, id_miasta, adres) VALUES ('Michał', 'Baran', @id_kal, 'ul. Jedności 7')
SET @id_mb = SCOPE_IDENTITY()

INSERT INTO OSOBY (imie, nazwisko, id_miasta, adres) VALUES ('Wiktoria', 'Beczek', @id_wes, 'ul. Mieszkalna 3')
SET @id_wb = SCOPE_IDENTITY()

INSERT INTO OSOBY (imie, nazwisko, id_miasta, adres) VALUES ('Olga', 'Zbucka', @id_wes, 'ul. Stara 3')
SET @id_oz = SCOPE_IDENTITY()

INSERT INTO OSOBY (imie, nazwisko, id_miasta, adres) VALUES ('Alicja', 'Rybkowska', @id_kal, 'ul. Kozacka 2')
SET @id_ar = SCOPE_IDENTITY()

INSERT INTO OSOBY (imie, nazwisko, id_miasta, adres) VALUES ('Milena', 'Galińska', @id_kal, 'ul. Roboty 6')
SET @id_mg = SCOPE_IDENTITY()

/* dodajemy firmy a potem etaty - w firmach sami nadajemy klucze główne */
INSERT INTO FIRMY (nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES ('PW', @id_wwa, 'Politechnika Warszawska', '00-661', 'p. Politechniki 1')
INSERT INTO FIRMY (nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES ('UW', @id_wwa, 'Uniwersytet Warszawski', '00-927', 'ul. Krakowskie Przedmieście 26/28')
INSERT INTO FIRMY (nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES ('SGH', @id_wwa, 'Szkoła Główna Handlowa', '02-554', 'al. Niepodległości 162')
INSERT INTO FIRMY (nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES ('PP', @id_poz, 'Politechnika Poznańska', '60-965', 'Plac Marii Skłodowskiej-Curie 5')
INSERT INTO FIRMY (nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES ('UP', @id_poz, 'Uniwersytet Poznański', '61-712', 'ul. Wieniawskiego 1')
INSERT INTO FIRMY (nazwa_skr, id_miasta, nazwa, kod_pocztowy, ulica) VALUES ('PS', @id_szcz, 'Politechnika Szczecińska', '71-899', 'ul. Kazimierza Pułaskiego')

INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES (@id_ms, 'PS', 'analityk', 4000, '2000', '2019')
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES (@id_jk, 'PS', 'magazynier', 3000, '2003', '2020')
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od, do) VALUES (@id_js, 'PS', 'dyrektor', 5000, '2005', '2012')
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od) VALUES (@id_kk, 'PW', 'adjunkt', 3500, '2015')
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od) VALUES (@id_kk, 'PW', 'wykładowca', 5500, '2012')
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od) VALUES (@id_kk, 'PW', 'sprzątacz', 2500, '2009')
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od) VALUES (@id_kk, 'PW', 'dyrektor', 7500, '2020')
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od) VALUES (@id_kk, 'PW', 'doktorant', 1000, '2015')
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od) VALUES (@id_mb, 'UW', 'st.adjunkt', 5500, '2016')
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od) VALUES (@id_mb, 'UW', 'doktorant', 900, '2016')
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od) VALUES (@id_wb, 'SGH', 'dyrektor', 8000, '2019')
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od) VALUES (@id_oz, 'PP', 'wykładowca', 3500, '2017')
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od) VALUES (@id_ar, 'UW', 'st.adjunkt', 4500, '2013')
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od) VALUES (@id_mg, 'UP', 'sprzątacz', 2500, '2012')
INSERT INTO ETATY (id_osoby, id_firmy, stanowisko, pensja, od) VALUES (@id_mb, 'UP', 'magazynier', 2500, '2016')
/* z menu uery wybieramy RESULTS TO TXT i uruchamiamy poniższe zapytania i ich wynik
** wklejamy jako komentarz */
SELECT * FROM WOJ
/*
kod_woj nazwa
------- ----------------------------------------
MAZ     Mazowieckie
OPO     Opolskie
WLKP    Wielkopolskie
ZPM     Zachodniopomorskie

(4 rows affected)
*/
SELECT * FROM MIASTA
/*
kod_woj nazwa                                    id_miasta
------- ---------------------------------------- -----------
MAZ     Wesoła                                   1
MAZ     Warszawa                                 2
MAZ     Marki                                    3
MAZ     Otwock                                   4
WLKP    Poznań                                   5
WLKP    Kalisz                                   6
ZPM     Mielno                                   7
ZPM     Szczecin                                 8

(8 rows affected)
*/
SELECT * FROM OSOBY
/*
id_miasta   imie                                     nazwisko                                 adres                                                                                                id_osoby
----------- ---------------------------------------- ---------------------------------------- ---------------------------------------------------------------------------------------------------- -----------
1           Maciej                                   Stach                                    ul. Klonowa 1                                                                                        1
6           Jan                                      Kowalski                                 ul. Parkowa 44                                                                                       2
6           Janusz                                   Star                                     ul. Nowa 1                                                                                           3
1           Kuba                                     Kot                                      ul. Nowa 66                                                                                          4
1           Paweł                                    Matera                                   ul. Nowelska 22                                                                                      5
6           Kamil                                    Matera                                   ul. Szkolna 2                                                                                        6
6           Michał                                   Baran                                    ul. Jedności 7                                                                                       7
1           Wiktoria                                 Beczek                                   ul. Mieszkalna 3                                                                                     8
1           Olga                                     Zbucka                                   ul. Stara 3                                                                                          9
6           Alicja                                   Rybkowska                                ul. Kozacka 2                                                                                        10
6           Milena                                   Galińska                                 ul. Roboty 6                                                                                         11

(11 rows affected)
*/
SELECT * FROM FIRMY
/*
nazwa_skr id_miasta   nazwa                                    kod_pocztowy ulica
--------- ----------- ---------------------------------------- ------------ ----------------------------------------
PP        5           Politechnika Poznańska                   60-965       Plac Marii Skłodowskiej-Curie 5
PS        8           Politechnika Szczecińska                 71-899       ul. Kazimierza Pułaskiego
PW        2           Politechnika Warszawska                  00-661       p. Politechniki 1
SGH       2           Szkoła Główna Handlowa                   02-554       al. Niepodległości 162
UP        5           Uniwersytet Poznański                    61-712       ul. Wieniawskiego 1
UW        2           Uniwersytet Warszawski                   00-927       ul. Krakowskie Przedmieście 26/28

(6 rows affected)
*/
SELECT * FROM ETATY
/*
id_osoby    id_firmy stanowisko                               pensja      od                      do                      id_etatu
----------- -------- ---------------------------------------- ----------- ----------------------- ----------------------- -----------
1           PS       analityk                                 4000        2000-01-01 00:00:00.000 2019-01-01 00:00:00.000 1
2           PS       magazynier                               3000        2003-01-01 00:00:00.000 2020-01-01 00:00:00.000 2
3           PS       dyrektor                                 5000        2005-01-01 00:00:00.000 2012-01-01 00:00:00.000 3
4           PW       adjunkt                                  3500        2015-01-01 00:00:00.000 NULL                    4
4           PW       wykładowca                               5500        2012-01-01 00:00:00.000 NULL                    5
4           PW       sprzątacz                                2500        2009-01-01 00:00:00.000 NULL                    6
4           PW       dyrektor                                 7500        2020-01-01 00:00:00.000 NULL                    7
4           PW       doktorant                                1000        2015-01-01 00:00:00.000 NULL                    8
7           UW       st.adjunkt                               5500        2016-01-01 00:00:00.000 NULL                    9
7           UW       doktorant                                900         2016-01-01 00:00:00.000 NULL                    10
8           SGH      dyrektor                                 8000        2019-01-01 00:00:00.000 NULL                    11
9           PP       wykładowca                               3500        2017-01-01 00:00:00.000 NULL                    12
10          UW       st.adjunkt                               4500        2013-01-01 00:00:00.000 NULL                    13
11          UP       sprzątacz                                2500        2012-01-01 00:00:00.000 NULL                    14
7           UP       magazynier                               2500        2016-01-01 00:00:00.000 NULL                    15

(15 rows affected)
*/
/*
to wiadomosc z czatu kiedy usuniemy jedno wojewodztwo
(1 row affected)

(1 row affected)

(1 row affected)
Msg 547, Level 16, State 0, Line 172
The INSERT statement conflicted with the FOREIGN KEY constraint "FK_WOJ". The conflict occurred in database "b3_325456", table "dbo.WOJ", column 'kod_woj'.
The statement has been terminated.
Msg 547, Level 16, State 0, Line 175
The INSERT statement conflicted with the FOREIGN KEY constraint "FK_WOJ". The conflict occurred in database "b3_325456", table "dbo.WOJ", column 'kod_woj'.
The statement has been terminated.
Msg 547, Level 16, State 0, Line 178
The INSERT statement conflicted with the FOREIGN KEY constraint "FK_WOJ". The conflict occurred in database "b3_325456", table "dbo.WOJ", column 'kod_woj'.
The statement has been terminated.
Msg 547, Level 16, State 0, Line 181
The INSERT statement conflicted with the FOREIGN KEY constraint "FK_WOJ". The conflict occurred in database "b3_325456", table "dbo.WOJ", column 'kod_woj'.
The statement has been terminated.

(1 row affected)

(1 row affected)

(1 row affected)

(1 row affected)
Msg 515, Level 16, State 2, Line 196
Cannot insert the value NULL into column 'id_miasta', table 'b3_325456.dbo.OSOBY'; column does not allow nulls. INSERT fails.
The statement has been terminated.

(1 row affected)

(1 row affected)
Msg 515, Level 16, State 2, Line 205
Cannot insert the value NULL into column 'id_miasta', table 'b3_325456.dbo.OSOBY'; column does not allow nulls. INSERT fails.
The statement has been terminated.
Msg 515, Level 16, State 2, Line 208
Cannot insert the value NULL into column 'id_miasta', table 'b3_325456.dbo.OSOBY'; column does not allow nulls. INSERT fails.
The statement has been terminated.

(1 row affected)

(1 row affected)
Msg 515, Level 16, State 2, Line 217
Cannot insert the value NULL into column 'id_miasta', table 'b3_325456.dbo.OSOBY'; column does not allow nulls. INSERT fails.
The statement has been terminated.
Msg 515, Level 16, State 2, Line 220
Cannot insert the value NULL into column 'id_miasta', table 'b3_325456.dbo.OSOBY'; column does not allow nulls. INSERT fails.
The statement has been terminated.

(1 row affected)

(1 row affected)
Msg 515, Level 16, State 2, Line 230
Cannot insert the value NULL into column 'id_miasta', table 'b3_325456.dbo.FIRMY'; column does not allow nulls. INSERT fails.
The statement has been terminated.
Msg 515, Level 16, State 2, Line 231
Cannot insert the value NULL into column 'id_miasta', table 'b3_325456.dbo.FIRMY'; column does not allow nulls. INSERT fails.
The statement has been terminated.
Msg 515, Level 16, State 2, Line 232
Cannot insert the value NULL into column 'id_miasta', table 'b3_325456.dbo.FIRMY'; column does not allow nulls. INSERT fails.
The statement has been terminated.

(1 row affected)

(1 row affected)

(1 row affected)
Msg 547, Level 16, State 0, Line 237
The INSERT statement conflicted with the FOREIGN KEY constraint "FK_OSOBY". The conflict occurred in database "b3_325456", table "dbo.OSOBY", column 'id_osoby'.
The statement has been terminated.

(1 row affected)

(1 row affected)

(1 row affected)

(1 row affected)

(1 row affected)

(1 row affected)

(1 row affected)

(1 row affected)

(1 row affected)

(1 row affected)

(1 row affected)

(1 row affected)

(1 row affected)

(1 row affected)

(3 rows affected)

(4 rows affected)

(6 rows affected)

(3 rows affected)

(14 rows affected)

Completion time: 2023-03-12T22:27:06.6963527+01:00
*/