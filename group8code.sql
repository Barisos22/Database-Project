CREATE TABLE Country(
c_id CHAR(3),
c_name CHAR(50),
PRIMARY KEY (c_id)
);

CREATE TABLE Healthcare_Spending(
c_id CHAR(3),
date INTEGER,
percent_gdp DOUBLE,
PRIMARY KEY (c_id, date),
FOREIGN KEY (c_id) REFERENCES Country(c_id) ON DELETE CASCADE
);

CREATE TABLE Cancer_Death_Reported(
c_id CHAR(3),
date INTEGER,
lungc_amount INTEGER,
liporalc_amount INTEGER,
liverc_amount INTEGER,
total_percent DOUBLE,
PRIMARY KEY (c_id, date),
FOREIGN KEY (c_id) REFERENCES Country(c_id) ON DELETE CASCADE
);

CREATE TABLE Housed_Population(
c_id CHAR(3),
date INTEGER,
amount_urban INTEGER,
amount_rural INTEGER,
PRIMARY KEY (c_id, date),
FOREIGN KEY (c_id) REFERENCES Country(c_id) ON DELETE CASCADE
);

CREATE TABLE Air_Pol_Deaths_Reported(
c_id CHAR(3),
date INTEGER,
death_amount INTEGER,
death_percentage DOUBLE,
PRIMARY KEY (c_id, date),
FOREIGN KEY (c_id) REFERENCES Country(c_id) ON DELETE CASCADE
);

CREATE TABLE Mental_Disorder(
c_id CHAR(3),
date INTEGER,
percent_anxiety DOUBLE,
percent_druguse DOUBLE,
percent_alcohol DOUBLE,
percent_depression DOUBLE,
PRIMARY KEY (c_id, date),
FOREIGN KEY (c_id,date) REFERENCES Housed_Population(c_id,date) ON DELETE CASCADE
);

