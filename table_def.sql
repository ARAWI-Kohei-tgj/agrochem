/************************************************************
 * Master table `pesticide_regcode'
 *
 * 1| register_code: register code of MAFF(Ministry of Agriculture, Forestry and Fisheries)
 * 2| product_name: product name without manufacture name
 * 3| manufacture: manufacture name
 ************************************************************/
CREATE TABLE pesticide_regcode(
	register_code INTEGER PRIMARY KEY,	-- 農水省 登録番号
	product_name TEXT NOT NULL,	-- 屋号抜き製品名
	manufacture TEXT[] NOT NULL
);

/************************************************************
 * Master table `crop_history'
 *
 * 1| crop_id: 
 * 2| crop_name: 
 * 3| fields: list of field name
 ************************************************************/
CREATE TABLE crop_history(
	crop_id SMALLSERIAL PRIMARY KEY,
	crop_name TEXT NOT NULL,
	fields TEXT[] NOT NULL
);

/************************************************************
 * Master table `seeding_date'
 *
 * 1| crop_id: 
 * 2| the_date: date of the seeding
 ************************************************************/
CREATE TABLE seeding_date(
	crop_id SMALLINT NOT NULL,
	the_date DATE NOT NULL
);

/************************************************************
 * Master table `planting_date'
 *
 * 1| crop_id: 
 * 2| the_date: date of the planting
 ************************************************************/
CREATE TABLE planting_date(
	crop_id SMALLINT NOT NULL,
	the_date DATE NOT NULL
);

/************************************************************
 * Transaction table `spray_summary'
 *
 * 1| id_spray:
 * 2| spray_date:
 * 3| crop_id:
 * 4| spray_type:
 * 5| amount_num:
 * 6| amount_unit:
 ************************************************************/
CREATE TABLE spray_summary(
  id_spray SERIAL PRIMARY KEY,
  spray_date DATE NOT NULL,
  crop_id INTEGER NOT NULL,
  spray_type TEXT NOT NULL,
  amount_num FLOAT NOT NULL,
  amount_unit TEXT NOT NULL
);

/************************************************************
 * Transaction table `spray_detail'
 *
 * 1| id_spray:
 * 2| chem_code:
 * 3| dilution_num:
 * 4| dilution_unit:
 * 5| purpose:
 ************************************************************/
CREATE TABLE spray_detail(
  id_spray INTEGER NOT NULL,
  chem_code INTEGER NOT NULL,
  dilution_num INTEGER NOT NULL,
  dilution_unit TEXT NOT NULL,
  purpose TEXT NOT NULL
);
