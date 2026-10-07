-- Seating plan for the Wedding event, matching the Lotus Ballroom & Foyer
-- floor plan (19 round tables + head table). Run once after schema.sql.
-- Safe to re-run: it clears any existing wedding seating plan first.
delete from seating_tables where event_id = 'wedding';

insert into seating_tables (event_id, label, zone, capacity, shape, pos_x, pos_y, col_span, sort_order) values
  ('wedding','1','Lotus Ballroom - Pink',10,'round',1,2,1,1),
  ('wedding','2','Lotus Ballroom - Pink',10,'round',2,2,1,2),
  ('wedding','3','Lotus Ballroom - Pink',10,'round',3,2,1,3),
  ('wedding','10','Lotus Ballroom - Pink',10,'round',1,5,1,10),
  ('wedding','11','Lotus Ballroom - Pink',10,'round',2,5,1,11),
  ('wedding','12','Lotus Ballroom - Pink',10,'round',3,5,1,12),
  ('wedding','4','Lotus Ballroom - Red',10,'round',4,2,1,4),
  ('wedding','5','Lotus Ballroom - Red',10,'round',5,2,1,5),
  ('wedding','6','Lotus Ballroom - Red',10,'round',4,3,1,6),
  ('wedding','7','Lotus Ballroom - Red',10,'round',5,3,1,7),
  ('wedding','8','Lotus Ballroom - Red',10,'round',4,4,1,8),
  ('wedding','9','Lotus Ballroom - Red',10,'round',5,4,1,9),
  ('wedding','13','Lotus Ballroom - Red',10,'round',4,5,1,13),
  ('wedding','14','Lotus Ballroom - Red',10,'round',5,5,1,14),
  ('wedding','Head table','Lotus Ballroom - White',8,'rect',6,2,2,0),
  ('wedding','15','Lotus Ballroom - Yellow',10,'round',8,2,1,15),
  ('wedding','19','Lotus Ballroom - Yellow',10,'round',9,2,1,19),
  ('wedding','16','Lotus Ballroom - Yellow',10,'round',8,3,1,16),
  ('wedding','17','Lotus Ballroom - Yellow',10,'round',8,5,1,17),
  ('wedding','18','Lotus Ballroom - Yellow',10,'round',9,5,1,18);
