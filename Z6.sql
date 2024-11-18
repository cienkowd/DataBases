/*
tworzenie nowych tabel i triggerow do nich
trigger moze tyczyc jednego lub wielu rekordow
nie moze byc rekurencyjny (nieskonczenie)
trigger nie moze zmieniac ca³ej tabeli a tylko zmienione rekordy

wypozyczalnia aut

auta (id_a int not null identity (klucz)
, model nvarchar(60)
, liczba_dostepnych int not null
, liczba_zakupionych int not null)

insert do tej tabeli przepisuje liczba_xakupionych do liczba dostepnych
update na zakupionych dodaje roznice do liczba_dostepnych

przyklad
a1
zakupionych 10
dotepnych 8 (bo 2 nie oddne jeszcze)

robimy update na zakupionych na 13 - czyli stan zwiekszamy o 3
do dostepnych musimy dodac 8+3 = 11

jeden rekord w auta to jakby jeden redzaj auta

klient (nazwa nv(100) not null, adres nv(100) not null
, id_klienta int not null identity (klucz))

wypozycz (id_wyp int not null identity (klucz)
, id_klienta (klucz obcy)
, id_a (klucz obcy)
, liczba int not null
)

insert do tabeli wypozycz musi zmodyfikowac odpowiednie rekordy w tabeli auta
kolumnê liczba_dostepnych

np wstawiamy na raz dwa rekordy
id_a = 1
id_klient = 1
liczba = 2

oraz id_a = 1
id_klient = 2
liczba = 3

Czyli dwu róznych klientów wypozycza te same rodzaje aut w totalu 5
w jednej instrukcji INSERT czyli w jednym triggerze

Ten trigger musi zmniejszyæ o 5 liczba_dostepnych w auta o id=1

trigger na kasowanie z wypozycz ma powiêkszaæ odpowiednie liczniki w tabeli auta

tabela zwrot (id_zwr int not null identity (klucz)
, id_klienta (klucz obcy)
, id_a (klucz obcy)
, liczba int not null
)

insert do zwrot ma zwiekszac liczba_dostepna w tabeli auta
kasowanie ze zwrot ma zmniejszaæ liczba_dostepna w tabeli auta

Bradzo duzo testow, wstawiannie kilu rekordów do auta
wstawianie w jednym insert kilku wypozyczen
wstawianie na raz kilku zwrotów w jednym insert
aktualizacja liczba_zakupionych w tabeli auta dla aut, które maj¹ zwroty i wypozyczenia
zabezpieczenie w trigerach na update hust aby liczba_dostêpnych nie by³a mniejsza od zera ani wiêksza od liczba_zakupionych (tzn liczba)dostepnych nie mo¿e byæ wiêksza od liczby_zakupionych)

INSERT INTO tabela (kol1, ... kolN) VALUES (v, ...vN), (w1, ...wN)
kasowanie po kila rekordów

DELETE FROM ZWROT WHERE id_zwr IN (a,b,c)

i po kazdym dzia³aniu pokazywanie, ze poprawne sa liczby w auta

*/

IF OBJECT_ID('dbo.zwrot1') IS NOT NULL
	DROP TABLE zwrot1
IF OBJECT_ID('dbo.wypozycz1') IS NOT NULL
	DROP TABLE wypozycz1
IF OBJECT_ID('dbo.auta1') IS NOT NULL
	DROP TABLE auta1
IF OBJECT_ID('dbo.klient1') IS NOT NULL
	DROP TABLE klient1

CREATE TABLE dbo.auta1 
(	id_a int not null identity CONSTRAINT PK_ID_AUT PRIMARY KEY
,	model nvarchar(60)
,	liczba_dostepnych int not null
,	liczba_zakupionych int not null
)
GO
CREATE TABLE dbo.klient1
(	nazwa nvarchar(100) not null
,	adres nvarchar(100) not null
,	id_klienta int not null identity CONSTRAINT PK_ID_KLIENTA PRIMARY KEY
)
GO
CREATE TABLE dbo.zwrot1
(	id_zwr int not null identity CONSTRAINT PK_ID_ZWR PRIMARY KEY
,	id_klienta int 
		CONSTRAINT FK_ZWROT_KLIENT FOREIGN KEY
		REFERENCES klient1(id_klienta)
,	id_a int 
		CONSTRAINT FK_ZWROT_AUTA FOREIGN KEY
		REFERENCES auta1(id_a)
,	liczba int not null
)
GO
CREATE TABLE dbo.wypozycz1
(	id_wyp int not null identity CONSTRAINT PK_ID_WYP PRIMARY KEY
,	id_klienta int
		CONSTRAINT FK_WYPOZYCZ_KLIENT FOREIGN KEY
		REFERENCES klient1(id_klienta)
,	id_a int
		CONSTRAINT FK_WYPOZYCZ_AUTA FOREIGN KEY
		REFERENCES auta1(id_a)
,	liczba int not null
)
GO
CREATE TRIGGER dbo.auta_insrt_zakup ON dbo.auta1 FOR INSERT
AS
	UPDATE auta1
	SET
		liczba_dostepnych = auta1.liczba_zakupionych
	FROM auta1 
		JOIN inserted i ON auta1.id_a = i.id_a
GO
CREATE TRIGGER dbo.auta_upd_zakup ON dbo.auta1 FOR UPDATE
AS
	IF UPDATE(liczba_zakupionych) 
		UPDATE auta1
		SET 
			liczba_dostepnych += i.liczba_zakupionych-d.liczba_zakupionych
		FROM auta1 a
			JOIN inserted i ON a.id_a=i.id_a
			JOIN deleted d ON a.id_a=d.id_a
GO
CREATE TRIGGER dbo.auta_update_dost ON dbo.auta1 FOR UPDATE
AS
	IF UPDATE(liczba_dostepnych)
		IF EXISTS (SELECT TOP(1) 1 FROM inserted i WHERE i.liczba_dostepnych>i.liczba_zakupionych OR i.liczba_dostepnych<0)
		BEGIN
			RAISERROR(N'Niepoprawna liczba dostêpnych aut!', 16, 3)
			ROLLBACK TRAN
		END
GO
CREATE TRIGGER dbo.wypozycz_insrt_auta ON dbo.wypozycz1 FOR INSERT
AS
	UPDATE auta1
	SET
		liczba_dostepnych -= li.liczba
	FROM auta1 a
		JOIN (SELECT id_a, SUM(liczba) AS liczba from inserted i GROUP BY id_a) li ON li.id_a=a.id_a 
GO
CREATE TRIGGER dbo.wypozycz_del_auta ON dbo.wypozycz1 FOR DELETE
AS
	UPDATE auta1
	SET
		liczba_dostepnych += li.liczba
	FROM auta1 a
		JOIN (SELECT id_a, SUM(liczba) AS liczba from deleted d GROUP BY id_a) li ON li.id_a=a.id_a 
GO
CREATE TRIGGER dbo.zwrot_insrt_auta ON dbo.zwrot1 FOR INSERT
AS
	UPDATE auta1
	SET
		liczba_dostepnych += li.liczba
	FROM auta1 a
		JOIN (SELECT id_a, SUM(liczba) AS liczba from inserted i GROUP BY id_a) li ON li.id_a=a.id_a 
	
GO
CREATE TRIGGER dbo.zwrot_del_auta ON dbo.zwrot1 FOR DELETE
AS
	UPDATE auta1
	SET
		liczba_dostepnych -= li.liczba
	FROM auta1 a
		JOIN (SELECT id_a, SUM(liczba) AS liczba from deleted d GROUP BY id_a) li ON li.id_a=a.id_a 
GO

INSERT INTO auta1 (model, liczba_dostepnych, liczba_zakupionych) VALUES ('szybkie', 8, 10), ('mniej szybkie', 5, 13), ('wolne', 11, 11)
SELECT * from auta1 -----------------
/*
id_a        model                                                        liczba_dostepnych liczba_zakupionych
----------- ------------------------------------------------------------ ----------------- ------------------
1           szybkie                                                      10                10
2           mniej szybkie                                                13                13
3           wolne                                                        11                11

(3 rows affected)
*/

UPDATE auta1 SET liczba_zakupionych=13
SELECT * from auta1 ---------------
/*
id_a        model                                                        liczba_dostepnych liczba_zakupionych
----------- ------------------------------------------------------------ ----------------- ------------------
1           szybkie                                                      13                13
2           mniej szybkie                                                13                13
3           wolne                                                        13                13

(3 rows affected)
*/

UPDATE auta1 SET liczba_zakupionych=7
SELECT * from auta1 ----------------

/*
id_a        model                                                        liczba_dostepnych liczba_zakupionych
----------- ------------------------------------------------------------ ----------------- ------------------
1           szybkie                                                      7                 7
2           mniej szybkie                                                7                 7
3           wolne                                                        7                 7

(3 rows affected)
*/

INSERT INTO klient1 (nazwa, adres) VALUES ('Amadeusz Ferrari', 'ul.FAME MMA 13')
INSERT INTO klient1 (nazwa, adres) VALUES ('Wojtek Gola', 'ul.lowelowa 2')
INSERT INTO klient1 (nazwa, adres) VALUES ('BOXDEL', 'ul.masnego bena 420')
INSERT INTO wypozycz1(id_a, id_klienta, liczba) VALUES (1,1,2), (1,2,3)

SELECT * FROM auta1 -----------------------
/*
id_a        model                                                        liczba_dostepnych liczba_zakupionych
----------- ------------------------------------------------------------ ----------------- ------------------
1           szybkie                                                      2                 7
2           mniej szybkie                                                7                 7
3           wolne                                                        7                 7

(3 rows affected)
*/

DELETE FROM wypozycz1 WHERE id_klienta=2
SELECT * FROM auta1 --------------------------
/*
id_a        model                                                        liczba_dostepnych liczba_zakupionych
----------- ------------------------------------------------------------ ----------------- ------------------
1           szybkie                                                      5                 7
2           mniej szybkie                                                7                 7
3           wolne                                                        7                 7

(3 rows affected)
*/

/*wiêcej aut dostêpnych ni¿ kupionych*/
/*INSERT INTO zwrot1(id_a, id_klienta, liczba) VALUES (1,1,2), (1,2,3) - wiêcej 
SELECT * FROM auta1*/
/*
Msg 50000, Level 16, State 3, Procedure auta1_update_dost, Line 6
Niepoprawna liczba dostêpnych aut!
Msg 3609, Level 16, State 1, Procedure zwrot1_insrt_auta, Line 3
The transaction ended in the trigger. The batch has been aborted.
*/

/*ujemna liczba aut dostêpnych*/
/*INSERT INTO wypozycz1(id_a, id_klienta, liczba) VALUES (1,1,2), (1,2,4)
Msg 50000, Level 16, State 3, Procedure auta1_update_dost, Line 6
Niepoprawna liczba dostêpnych aut!
Msg 3609, Level 16, State 1, Procedure wypozycz1_insrt_auta, Line 3
The transaction ended in the trigger. The batch has been aborted.
*/

INSERT INTO zwrot1(id_a, id_klienta, liczba) VALUES (1,2,2)
SELECT * FROM auta1 -------------------
/*
id_a        model                                                        liczba_dostepnych liczba_zakupionych
----------- ------------------------------------------------------------ ----------------- ------------------
1           szybkie                                                      7                 7
2           mniej szybkie                                                7                 7
3           wolne                                                        7                 7

(3 rows affected)
*/
DELETE FROM zwrot1 WHERE id_klienta=2
SELECT * FROM auta1 --------------------
/*

id_a        model                                                        liczba_dostepnych liczba_zakupionych
----------- ------------------------------------------------------------ ----------------- ------------------
1           szybkie                                                      5                 7
2           mniej szybkie                                                7                 7
3           wolne                                                        7                 7

(3 rows affected)

*/

INSERT INTO wypozycz1(id_a, id_klienta, liczba) VALUES (1,1,2), (1,2,3), (2,3,4)
SELECT * FROM auta1
INSERT INTO zwrot1(id_a, id_klienta, liczba) VALUES (1,1,2), (1,2,3)
SELECT * FROM auta1
/*

id_a        model                                                        liczba_dostepnych liczba_zakupionych
----------- ------------------------------------------------------------ ----------------- ------------------
1           szybkie                                                      0                 7
2           mniej szybkie                                                3                 7
3           wolne                                                        7                 7

(3 rows affected)

(1 row affected)

(2 rows affected)

id_a        model                                                        liczba_dostepnych liczba_zakupionych
----------- ------------------------------------------------------------ ----------------- ------------------
1           szybkie                                                      5                 7
2           mniej szybkie                                                3                 7
3           wolne                                                        7                 7

(3 rows affected)
*/

SELECT * FROM wypozycz1
SELECT * FROM auta1
DELETE FROM wypozycz1 WHERE id_wyp = 1 OR id_wyp = 5
SELECT * FROM wypozycz1
SELECT * FROM auta1
/*
id_wyp      id_klienta  id_a        liczba
----------- ----------- ----------- -----------
1           1           1           2
3           1           1           2
4           2           1           3
5           3           2           4

(4 rows affected)

id_a        model                                                        liczba_dostepnych liczba_zakupionych
----------- ------------------------------------------------------------ ----------------- ------------------
1           szybkie                                                      5                 7
2           mniej szybkie                                                3                 7
3           wolne                                                        7                 7

(3 rows affected)

(2 rows affected)

(2 rows affected)

id_wyp      id_klienta  id_a        liczba
----------- ----------- ----------- -----------
3           1           1           2
4           2           1           3

(2 rows affected)

id_a        model                                                        liczba_dostepnych liczba_zakupionych
----------- ------------------------------------------------------------ ----------------- ------------------
1           szybkie                                                      7                 7
2           mniej szybkie                                                7                 7
3           wolne                                                        7                 7

(3 rows affected)
*/

SELECT * FROM ZWROT1
SELECT * FROM auta1
DELETE FROM zwrot1 WHERE id_klienta = 1 OR id_klienta = 2
SELECT * FROM ZWROT1
SELECT * FROM auta1
/*
id_zwr      id_klienta  id_a        liczba
----------- ----------- ----------- -----------
2           1           1           2
3           2           1           3

(2 rows affected)

id_a        model                                                        liczba_dostepnych liczba_zakupionych
----------- ------------------------------------------------------------ ----------------- ------------------
1           szybkie                                                      7                 7
2           mniej szybkie                                                7                 7
3           wolne                                                        7                 7

(3 rows affected)

(1 row affected)

(2 rows affected)

id_zwr      id_klienta  id_a        liczba
----------- ----------- ----------- -----------

(0 rows affected)

id_a        model                                                        liczba_dostepnych liczba_zakupionych
----------- ------------------------------------------------------------ ----------------- ------------------
1           szybkie                                                      2                 7
2           mniej szybkie                                                7                 7
3           wolne                                                        7                 7

(3 rows affected)
*/

INSERT INTO wypozycz1(id_a, id_klienta, liczba) VALUES (1,1,2), (2,3,4)
INSERT INTO zwrot1(id_a, id_klienta, liczba) VALUES (1,1,2), (2,3,3)
SELECT * FROM auta1
UPDATE auta1 SET liczba_zakupionych=15 WHERE id_a = 1 OR id_a=2
SELECT * FROM auta1
/*
id_a        model                                                        liczba_dostepnych liczba_zakupionych
----------- ------------------------------------------------------------ ----------------- ------------------
1           szybkie                                                      2                 7
2           mniej szybkie                                                6                 7
3           wolne                                                        7                 7

(3 rows affected)

(2 rows affected)

(2 rows affected)

id_a        model                                                        liczba_dostepnych liczba_zakupionych
----------- ------------------------------------------------------------ ----------------- ------------------
1           szybkie                                                      10                15
2           mniej szybkie                                                14                15
3           wolne                                                        7                 7

(3 rows affected)*/