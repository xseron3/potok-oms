INSERT INTO couriers (id, name, vehicle, zones, capacity, phone, status) VALUES
('C-01','Артём Ковалёв','car',ARRAY['ЦАО','ЗАО'],8,'+7 916 204-11-08','busy'),
('C-02','Марина Соколова','bike',ARRAY['ЦАО','САО'],6,'+7 916 331-72-40','busy'),
('C-03','Дмитрий Ерохин','van',ARRAY['СВАО','ВАО'],12,'+7 925 118-63-25','busy'),
('C-04','Ольга Лебедева','car',ARRAY['ЮАО','ЮВАО'],8,'+7 903 559-04-17','busy'),
('C-05','Павел Гущин','foot',ARRAY['ЦАО'],5,'+7 926 707-38-91','free'),
('C-06','Никита Морозов','car',ARRAY['ЮЗАО','ЗАО'],8,'+7 985 442-19-63','free'),
('C-07','Егор Титов','bike',ARRAY['СЗАО','САО'],6,'+7 968 220-55-30','off')
ON CONFLICT (id) DO NOTHING;

INSERT INTO orders (id, seq, customer, phone, street, house, apt, zone, status, priority, courier_id, slot, created_at, eta) VALUES
('ORD-1041',1,'Анна Смирнова','+7 916 204-31-12','Тверская','12','45','ЦАО','new','normal',NULL,'09:00–12:00',now()-interval '3 hours',now()+interval '20 hours'),
('ORD-1042',2,'Игорь Петров','+7 903 118-42-77','Ленинградский проспект','68','12','САО','confirmed','express',NULL,'12:00–15:00',now()-interval '5 hours',now()+interval '6 hours'),
('ORD-1043',3,'Елена Кузнецова','+7 925 331-08-19','Арбат','24','8','ЦАО','picking','normal','C-02','15:00–18:00',now()-interval '8 hours',now()+interval '10 hours'),
('ORD-1044',4,'Максим Волков','+7 926 559-63-40','Дмитровское шоссе','15','77','СВАО','ready','normal','C-03','18:00–21:00',now()-interval '10 hours',now()+interval '4 hours'),
('ORD-1045',5,'Дарья Новикова','+7 985 707-25-08','Варшавское шоссе','132','19','ЮАО','in_transit','express','C-04','15:00–18:00',now()-interval '12 hours',now()+interval '2 hours'),
('ORD-1046',6,'Сергей Морозов','+7 916 442-19-63','Рублёвское шоссе','40','3','ЗАО','in_transit','critical','C-01','12:00–15:00',now()-interval '14 hours',now()-interval '1 hours'),
('ORD-1047',7,'Ксения Павлова','+7 903 220-55-30','Пятницкая','7','14','ЦАО','delivered','normal','C-05','09:00–12:00',now()-interval '2 days',now()-interval '1 days'),
('ORD-1048',8,'Роман Зайцев','+7 925 104-88-21','Профсоюзная','61','28','ЮЗАО','delivered','normal','C-06','18:00–21:00',now()-interval '2 days',now()-interval '1 days'),
('ORD-1049',9,'Алина Егорова','+7 926 307-14-95','Щёлковское шоссе','3','55','ВАО','cancelled','normal',NULL,'12:00–15:00',now()-interval '1 days',now()+interval '8 hours'),
('ORD-1050',10,'Виктор Соловьёв','+7 985 611-72-04','Маршала Бирюзова','22','9','СЗАО','returned','normal','C-07','15:00–18:00',now()-interval '3 days',now()-interval '2 days')
ON CONFLICT (id) DO NOTHING;

INSERT INTO order_items (order_id, name, sku, qty, price) VALUES
('ORD-1041','Кроссовки Nike Air Zoom','NK-AZ-42',1,8990),
('ORD-1041','Термокрутка Stanley 0.7','ST-TH-07',2,4590),
('ORD-1042','Наушники Sony WH-1000XM5','SN-XM5-B',1,32990),
('ORD-1043','Кофемашина DeLonghi ECAM','DL-EC-22',1,54900),
('ORD-1044','Пылесос Dyson V12','DY-V12-G',1,59990),
('ORD-1044','Коврик для йоги','SP-YM-6',1,1790),
('ORD-1045','Смартфон Redmi Note 13','XM-RN13',2,18990),
('ORD-1046','Монитор LG 27" 4K','LG-27U4',1,38900),
('ORD-1047','Клавиатура Keychron K2','KC-K2-R',1,9490),
('ORD-1047','Книга «Чистый код»','BK-CLCD',1,1890),
('ORD-1048','Набор посуды Tefal, 6 пр.','TF-CK6-R',1,7990),
('ORD-1049','Рюкзак городской 25 л','BG-CT-25',1,3490),
('ORD-1050','Часы Garmin Forerunner','GM-FR-55',1,24990)
ON CONFLICT (order_id, sku) DO NOTHING;

INSERT INTO status_history (order_id, changed_at, from_status, to_status, actor)
SELECT o.id, o.created_at, NULL, 'new', 'Интернет-магазин'
FROM orders o
WHERE NOT EXISTS (SELECT 1 FROM status_history h WHERE h.order_id = o.id);

INSERT INTO status_history (order_id, changed_at, from_status, to_status, actor)
SELECT o.id, o.created_at + interval '2 hours', 'new', o.status, 'Диспетчер'
FROM orders o
WHERE o.status <> 'new'
  AND NOT EXISTS (SELECT 1 FROM status_history h WHERE h.order_id = o.id AND h.to_status = o.status);