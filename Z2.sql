/*
przydzadza sie notatki i narania z wczorajszego wykladu:
Z2.1 - prosz� wklei� do sprawozdania
prosze wybra� 2 firmy i 2 r�ne osoby i wstawi� tym osobom
po jeddnym etacie (w sumie 2 etaty) z t� sam� pensj� najni�sz� w bazie np 10 pln
zalozmy firmy xx i yy i osoby 43 i 44
insert into etaty(id_osoby,id_firmy,pensja) values (43,'xx',10)
insert into etaty(id_osoby,id_firwy,pensja) values (44,'yy',10)
nnapisac zapytanie znajdujace min pensje w firmie xx
i pokazujaca w jakiej firmie i kto j� posiada
*/

insert into ETATY(id_osoby,id_firmy,stanowisko,pensja,od) values (1,'PS', 'ogrodnik',10, '2018')

insert into ETATY(id_OSOBY,id_FIRMY,stanowisko,pensja,od) values (7,'UW', 'ogrodnik',10, '2019')

SELECT (e.pensja)   AS pensja
	, (o.imie)		AS imie
	, (o.nazwisko)	AS nazwisko
	, (f.nazwa)		AS firma
FROM etaty e
	JOIN osoby o	ON (e.id_osoby = o.id_osoby)
	JOIN firmy f	ON (e.id_firmy = f.nazwa_skr)
WHERE e.pensja = (SELECT MIN(e.pensja) FROM etaty e WHERE e.id_firmy = 'PS') and e.id_firmy = 'PS'

/*
pensja      imie                                     nazwisko                                 firma
----------- ---------------------------------------- ---------------------------------------- ----------------------------------------
10          Maciej                                   Stach                                    Politechnika Szczeci�ska

(1 row affected)
*/
/*
z2.2
pokazac dane etatu (pensja, stanowisko) iosoby (imie,azwisko, dane firmy: nazwa, miasto gdzie mieszka osoba
i kod wojewodztwa miasta w ktorym mieszka osoba
oraz nazwe miasta w kt�rym znajduje si� firma
oraz kod wojew�dztwa dla miasta w kt�rym znajdduje si� firma
tylko takie gdzie kod wojew�dztwa dla miasta osoby jest inny od kodu
wojewodztwa miasta w kt�rym jest firma

innymi s�owy ane etatu z danymi osob i firm ale tylko te gdzie osoba mieszka w innym wojewodztwie ni� firma na etacie kt�rej pracuje
*/

SELECT (e.pensja)			AS pensja
	, LEFT(e.stanowisko,15) AS stanowisko
	, LEFT(o.imie,15)		AS imie
	, LEFT(o.nazwisko,15)	AS nazwisko
	, LEFT(mo.nazwa,25)		AS nazwa_miasta_osoby
	, LEFT(mo.kod_woj,6)	AS kod_woj_osoby
	, LEFT(f.nazwa,30)		AS firma
	, LEFT(mf.nazwa,15)		AS nazwa_miasta_firmy
	, LEFT(mf.kod_woj,6)	AS kod_woj_firmy
FROM etaty e
	JOIN osoby o	ON (e.id_osoby = o.id_osoby)
	JOIN firmy f	ON (e.id_firmy = f.nazwa_skr)
	JOIN miasta mo	ON (o.id_miasta = mo.id_miasta)
	JOIN miasta mf	ON (mf.id_miasta = f.id_miasta)

WHERE mf.kod_woj != mo.kod_woj

/*
pensja      stanowisko      imie            nazwisko        nazwa_miasta_osoby        kod_woj_osoby firma                          nazwa_miasta_firmy kod_woj_firmy
----------- --------------- --------------- --------------- ------------------------- ------------- ------------------------------ ------------------ -------------
4000        analityk        Maciej          Stach           Weso�a                    MAZ           Politechnika Szczeci�ska       Szczecin           ZPM 
3000        magazynier      Jan             Kowalski        Kalisz                    WLKP          Politechnika Szczeci�ska       Szczecin           ZPM 
5000        dyrektor        Janusz          Star            Kalisz                    WLKP          Politechnika Szczeci�ska       Szczecin           ZPM 
5500        st.adjunkt      Micha�          Baran           Kalisz                    WLKP          Uniwersytet Warszawski         Warszawa           MAZ 
900         doktorant       Micha�          Baran           Kalisz                    WLKP          Uniwersytet Warszawski         Warszawa           MAZ 
3500        wyk�adowca      Olga            Zbucka          Weso�a                    MAZ           Politechnika Pozna�ska         Pozna�             WLKP
4500        st.adjunkt      Alicja          Rybkowska       Kalisz                    WLKP          Uniwersytet Warszawski         Warszawa           MAZ 
10          ogrodnik        Maciej          Stach           Weso�a                    MAZ           Politechnika Szczeci�ska       Szczecin           ZPM 
10          ogrodnik        Micha�          Baran           Kalisz                    WLKP          Uniwersytet Warszawski         Warszawa           MAZ 

(9 rows affected)
*/