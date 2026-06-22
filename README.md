# Keskmine autode arv tööpäevadel

## Ülevaade

Antud projekt modelleerib liiklusandmeid Valukoja–Lõõtsa ristmikult kasutades dbt-d ja PostgreSQL andmebaasi.

Eesmärk on vastata äriküsimusele:

Mitu autot liigub keskmiselt nädalas tööpäevadel läbi Valukoja–Lõõtsa ristmiku?

Lisaks keskmisele arvutatakse ka mediaan, et vähendada üksikute väga suure liiklusmahuga päevade mõju tulemusele.

## Äriküsimus

Analüüsi eesmärk on hinnata ristmiku liiklusintensiivsust tööpäevadel.

Lõpptulemusena luuakse mart-tabel, mis sisaldab:

- nädala alguskuupäeva (week_start)
- keskmist tööpäevast autode arvu (avg_vehicle_count)
- mediaanset tööpäevast autode arvu (median_vehicle_count)

## Eeldused

Liiklusintensiivsuse mõõtmiseks kasutati välja count, mitte unique_count.

Põhjendus:

- count näitab kõiki sõidukite läbimisi ristmikul; 
- sama sõiduki korduvad läbimised mõjutavad samuti liikluskoormust;
- eesmärk on mõõta liiklusmahtu, mitte unikaalsete sõidukite arvu.

Analüüsist jäeti välja:

- nädalavahetused;
- Eesti riigipühad.

## Arhitektuur

Projekt kasutab klassikalist dbt kihistust:

Seeds
  ↓
Staging
  ↓
Intermediate
  ↓
Mart


Toorandmed laetakse dbt seed mehhanismi abil CSV failidest.

- lootsa_valukoja_02_2026.csv
- dim_holidays.csv

Staging kihis:

- korrastatakse veerunimed;
- määratakse andmetüübid;
- tehakse minimaalsed puhastused.

Intermediate kihis:

- eemaldatakse nädalavahetused;
- eemaldatakse riigipühad;

Mart kihis arvutatakse ärimõõdikud ja filtreeritakse sõidukitüübid. Antud mudelis kasutatakse ainult tüüpi car. Kui äriküsimus muutub, siis saab teha vastavaid muudatusi. 

## Tehniline stack

| Komponent | Tööriist |
|---------|------------|
| **Andmebaas** | PostgreSQL (pgduckdb image) | 
| **Transformatsioonid**| dbt|
| **Konteinerid** | Docker |
| **Andmekvaliteet** | dbt tests|

## Andmekvaliteet

Projekt sisaldab järgmisi teste.

### stg_traffic: 
- NULL väärtuseid ei tohi olla 
- direction väärtus peab olema A või B
- sama liiklussündmus ei tohi esineda mitu korda

### stg_holidays: 
- holiday_date ei tohi olla NULL
- holiday_date peab olema unikaalne

### int_traffic: 
- NULL väärtusi ei tohi olla 
- direction väärtus peab olema A või B

### mart_avg_weekday_cars: 
- NULL väärtusi ei tohi olla 

### Custom testid
- liiklusloenduri väärtus ei tohi olla negatiivne


## Projekti struktuur

Kodutöö/
├── compose.yml
├── .env.example
├── Dockerfile.dbt
│
├── seeds/
│   ├── lootsa_valukoja_02_2026.csv
│   └── dim_holidays.csv
│
├── tests/
│   └── no_negative_count.sql
│
└── dbt_project/
    ├── dbt_project.yml
    ├── profiles.yml
    │
    └── models/
        ├── staging/
        │   ├── stg_traffic.sql
        │   ├── stg_traffic.yml
        │   ├── stg_riigipuha.sql
        │   └── stg_riigipuha.yml
        │
        ├── intermediate/
        │   ├── int_traffic.sql
        │   └── int_traffic.yml
        │
        └── marts/
            ├── mart_avg_weekday_cars.sql
            └── mart_avg_weekday_cars.yml

## Käivitamine

### 1. Kopeeri .env

 ```bash
cp .env.example .env
```
### 2. Käivita konteinerid

```bash
docker compose up -d
```
### 3. Lae seed andmed 

```bash
docker compose exec dbt dbt seed
```
### 4. Käivita mudelid 

```bash
docker compose exec dbt dbt run --select +mart_avg_weekday_cars
```

### 5. Päri andmeid martist 

Lisatud limiit 5

```bash
docker compose exec db psql -U projekt -d projekt -c "SELECT * FROM public_marts.mart_avg_weekday_cars LIMIT 5"
```
## Keskkonna sulgemine

```bash
# Peata konteinerid
docker compose down

# Peata konteinerid JA kustuta andmed (andmebaasi sisu kaob)
docker compose down -v
```


