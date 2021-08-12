drop table if exists project cascade;
drop table if exists house cascade;
drop table if exists builder cascade;
drop table if exists flat cascade;
drop table if exists clients cascade;
drop table if exists house_builder_relation cascade;

CREATE TABLE IF NOT EXISTS project (id_obj serial primary key not null, status varchar(100));
CREATE TABLE IF NOT EXISTS house (id_house serial primary key not null, floors int, id_obj int references project(id_obj) on delete cascade);
CREATE TABLE IF NOT EXISTS builder  (id_builder serial primary key not null, position varchar(100), salary int);
CREATE TABLE IF NOT EXISTS clients  (id_client serial primary key not null, age int);
CREATE TABLE IF NOT EXISTS flat  (id_flat serial primary key not null, rooms int, price int, id_client int references clients(id_client) on delete cascade, id_house int references house(id_house) on delete cascade);

CREATE TABLE if not exists house_builder_relation(
                                                     id_house int not null,
                                                     id_builder int not null,
                                                     FOREIGN KEY (id_house) REFERENCES house(id_house),
    FOREIGN KEY (id_builder) REFERENCES builder(id_builder),
    UNIQUE (id_house, id_builder)
    );

CREATE OR REPLACE FUNCTION set_salary() RETURNS TRIGGER AS $$
BEGIN

if new.position like 'Build%' then
new.salary:= 15000;
return new;

elseif new.position like 'Crane%' then
new.salary:= 30000;
return new;


elseif new.position like 'Task%' then
new.salary:= 60000;
return new;

else new.salary:= 0;
return new;
end if;

end;
$$ LANGUAGE plpgsql;

drop trigger if exists salary on builder;

create trigger salary
    before insert or update on builder
                         for each row
                         execute procedure set_salary();






insert into project(status) values('On build'),('Finished'), ('Prepare for building');
insert into house(floors, id_obj) values('50', 1),('170', 1), ('68', 2),('500', 3),('120', 3);
insert into builder(position) values('Builder №1'),('Builder №2'), ('Crane operator'),('Taskmaster №1'),('Taskmaster №2');
insert into clients(age) values (55), (23), (44),(35),(34),(29), (60),(79),(86),(88);
insert into flat(rooms,price, id_client, id_house) values(3, 50000, 1, 1),(2, 30000, 1, 1), (1, 15000, 10, 2),(3, 150000, 10, 3),(2, 564748, 10, 4), (3, 58589, 5, 4), (2, 85854, 5, 4);

insert into house_builder_relation values(1,1),(1,2),(1,3),(1,4),(2,2),(3,5),(5,1),(4,4);

/*SELECT house.floors, house.id_obj as project_number, builder.position, builder.salary
	FROM house JOIN house_builder_relation ON house.id_house = house_builder_relation.id_house
	JOIN builder ON house_builder_relation.id_builder = builder.id_builder;*/

SELECT house.floors, house.id_obj as project_number, builder.position, builder.salary
FROM house JOIN house_builder_relation ON house.id_house = house_builder_relation.id_house
           JOIN builder ON house_builder_relation.id_builder = builder.id_builder
where builder.salary > 15000;