# Data Science Verseny Projekt: A Teleprompter.com logfájlok elemzése

Ez a repository a **Data Science Klub data science versenyén** elért projektemet mutatja be, amellyel a **junior kategóriában 3. helyezést** értem el.

---

### A Kihívás

A feladat a Teleprompter.com nevű startup cég logfájljainak elemzése volt, azzal a céllal, hogy a felhasználói viselkedés feltérképezésével növeljük a fizetős előfizetők számát. A rendelkezésre álló adatbázis több mint **28 millió eseményt** tartalmazott, amelyek ~190 000 felhasználó tevékenységét rögzítették két hónap alatt.

---

### Módszertan és megközelítés

A projekt legnagyobb kihívása a hatalmas adatmennyiség feldolgozása és az adatokból levont értelmezhető következtetések megfogalmazása volt. 

A munkafolyamat során a következő lépéseket követtem:
1.  **Adatfeldolgozás:** A nagyméretű, strukturálatlan logfájlok feldolgozása és tisztítása, ami a legidőigényesebb feladat volt.
2.  **Idősoros elemzés:** Felhasználói események és konverziós trendek vizsgálata a hét napjaira és a napszakokra lebontva, az idényjellegű viselkedési minták (pl. újévi fogadalmak) feltárása érdekében.
3.  **Felhasználói szegmentáció:** A felhasználók csoportosítása (pl. fizetős vs. nem fizetős) a viselkedési mintázataik alapján, hogy megértsük, mi tesz valakit fizetőssé.
4.  **Tölcsérelemzés:** A kulcsfontosságú felhasználói útvonalak elemzése a konverziós tölcséren keresztül, az előfizetésig vezető lépések és a lemorzsolódás okainak feltárása.

---

### Főbb Megállapítások és Javaslatok

Az elemzés rávilágított a felhasználók útvonalában lévő kritikus pontokra és a fizetőssé válási szokásokra. A legfontosabb felismerések a következők voltak:

* A felhasználók **viselkedése jelentősen eltér** a hétköznapokon és a hétvégéken.
* Az előfizetési hajlandóság szorosan összefügg bizonyos kulcsfontosságú eseményekkel (például AI támogatás a program keretein belül).
* Az elemzés alapján azonosítottam a legígéretesebb célpiacokat is, mint például az **USA, az Egyesült Királyság, Spanyolország és Mexikó.**

Javaslatokat tettem a marketing stratégia optimalizálására, a felhasználói felület javítására, valamint a márkanév és a vizuális kommunikáció újragondolására.

---

### A Repozitórium Tartalma

* `1_prezi.pdf`: A versenyen bemutatott prezentációm.
* `2_osszefoglalo.pdf`: A projekt főbb megállapításait és javaslatait részletező összefoglaló dokumentum.
* `3_teleprompter.ipynb`: A projekt elemzését bemutató Jupyter notebook.

Ezzel a projekttel sikerült bebizonyítanom, hogy a big data elemzése nemcsak technikai kihívás, hanem a stratégiai döntések meghozatalához elengedhetetlen, értékes tudást is adhat.
