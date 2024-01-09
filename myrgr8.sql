DROP DATABASE rgr;
CREATE DATABASE rgr;
USE rgr;
DROP TABLE IF EXISTS Clients, Orders, Services, OrderItems, ServiceProviders;

CREATE TABLE `Clients` (
    `ClientID` INT PRIMARY KEY AUTO_INCREMENT,
    `FirstName` VARCHAR(50) NOT NULL,
    `LastName` VARCHAR(50) NOT NULL,
    `Phone` VARCHAR(20),
    `Email` VARCHAR(50)
);

CREATE TABLE `Orders` (
    `OrderID` INT PRIMARY KEY AUTO_INCREMENT,
    `ClientID` INT,
    `OrderDate` DATE,
    `TotalAmount` DECIMAL(10, 2),
    FOREIGN KEY (`ClientID`) REFERENCES `Clients`(`ClientID`)
);

CREATE TABLE `Services` (
    `ServiceID` INT PRIMARY KEY AUTO_INCREMENT,
    `ServiceName` VARCHAR(100) NOT NULL,
    `ServiceDescription` TEXT,
    `Price` DECIMAL(10, 2)
);

CREATE TABLE `OrderItems` (
    `OrderItemID` INT PRIMARY KEY AUTO_INCREMENT,
    `OrderID` INT,
    `ServiceID` INT,
    `Quantity` INT,
    FOREIGN KEY (`OrderID`) REFERENCES `Orders`(`OrderID`),
    FOREIGN KEY (`ServiceID`) REFERENCES `Services`(`ServiceID`)
);

CREATE TABLE `ServiceProviders` (
    `ServiceProviderID` INT PRIMARY KEY AUTO_INCREMENT,
    `ServiceProviderName` VARCHAR(100) NOT NULL,
    `ContactPerson` VARCHAR(50),
    `ContactPhone` VARCHAR(20),
    `ContactEmail` VARCHAR(50)
);

INSERT INTO Clients (FirstName, LastName, Phone, Email)
VALUES
    ('Евгений', 'Потемкин', '+79835487979', 'jekatema@mail.ru'),
    ('Фёдор', 'Архипов', '+79812587951', 'fedar@mail.ru'),
    ('Степан', 'Разин', '+79123476547', 'steralka@mail.ru'),
    ('Данила', 'Козловский', '+79181654848', 'dakaka@mail.ru'),
    ('Евгений', 'Потемкин', '+79835487979', 'evpatiy@mail.ru'),
    ('Константин', 'Еремин', '+79535137979', 'koneremeev@mail.ru'),
    ('Савелий', 'Старопенькин', '+79735489999', 'savsta@mail.ru'),
    ('Тимур', 'Васькин', '+79835488888', 'timkin@mail.ru'),
    ('Иван', 'Угарнов', '+79835487777', 'ivyga@mail.ru'),
    ('Дымок', 'Меньшов', '+79835486666', 'dimanet@mail.ru');
    
INSERT INTO Orders (ClientID, OrderDate)
VALUES
    (1, '2023-01-01'),
    (2, '2023-02-03'),
    (3, '2023-03-05'),
    (4, '2023-04-07'),
    (5, '2023-05-10'),
    (6, '2023-06-14'),
    (7, '2023-07-20'),
    (8, '2023-08-21'),
    (9, '2023-09-25'),
    (10, '2023-10-28');
       
INSERT INTO Services (ServiceName, ServiceDescription, Price)
VALUES
    ('Ритуальные уси', 'Услуги агента', 15000.00),
    ('Ритуальные усги', 'Кремация', 20000.00),
    ('Ритуальные улуги', 'Захоронение', 17000.00),
    ('Ритуальные услуги', 'Перезахоронение', 30000.00),
    ('Ритуальные уси', 'Подготовка могилы', 10000.00),
    ('Ритуальные услуи', 'Похоронные пренадлежности', 5000.00),
    ('Мемориальная церемония', 'Проведение церемонии памяти', 8000.00),
    ('Ритуальный трспорт', 'Предоставление транспорта', 3000.00),
    ('Ритуальный транспорт', 'Трансфер', 7000.00),
    ('Кладбищенская служба', 'Уход за местом захоронения', 10000.00);

INSERT INTO OrderItems (OrderID, ServiceID, Quantity)
VALUES
    (1, 2, 1),
    (1, 2, 2),
    (2, 4, 1),
    (2, 3, 1),
    (3, 2, 1),
    (3, 5, 1),
    (4, 2, 2),
    (4, 1, 1),
    (5, 2, 2),
    (5, 3, 1),
    (6, 8, 2),
    (6, 1, 1),
    (7, 10, 2),
    (7, 2, 1),
    (8, 1, 2),
    (8, 2, 1),
    (9, 1, 2),
    (9, 8, 1),
    (10, 9, 1),
    (10, 1, 1);

INSERT INTO ServiceProviders (ServiceProviderName, ContactPerson, ContactPhone, ContactEmail)
VALUES
    ('Ритуальные услуги', 'Петров Степан', '+78941231187', 'petstep@gmail.com'),
    ('Ритуальные услуги', 'Ступкин Дмитрий', '+79131311411', 'stypdim@gmail.com'),
    ('Ритуальные услуги', 'Коложина Анна', '+79411748913', 'kolan@gmail.com'),
    ('Церковь', 'Степанюк Михаил', '+79813157958', 'stepmix@gmail.com'),
    ('Транспортные услуги', 'Сидоров Владимир', '+79213854798', 'sidv@gmail.com'),
    ('Транспортные услуги', 'Кудак Базыр', '+79277778866', 'kydba@gmail.com'),
    ('Гробы', 'Иванов Иван', '+79813157891', 'iviva@gmail.com'),
    ('Гробы', 'Козлов Степан', '+79609674217', 'kozsepa@gmail.com'),
    ('Гробы', 'Юдин Тимур', '+79898485858', 'youtima@gmail.com'),
    ('Услуги по уходу за местами', 'Морозов Артем', '+79841131111', 'moriarti@gmail.com');
    

   
   UPDATE Orders
SET TotalAmount = (
    SELECT COALESCE(SUM(Services.Price * OrderItems.Quantity), 0)
    FROM OrderItems
    JOIN Services ON OrderItems.ServiceID = Services.ServiceID
    WHERE OrderItems.OrderID = Orders.OrderID
)
WHERE Orders.OrderID IN (SELECT DISTINCT OrderID FROM OrderItems);

DROP TRIGGER IF EXISTS trig_DeleteOrders;
DELIMITER //
CREATE TRIGGER trig_DeleteOrders
BEFORE DELETE ON Clients
FOR EACH ROW 
BEGIN
    IF ((SELECT COUNT(Orders.ClientID) FROM Orders WHERE Orders.ClientID = OLD.ClientID) != 0)
    THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Вы не можете удалить этого клиента, т.к в таблице Orders есть его заказы. Для начала удалите заказы.';
    END IF;
END //
DELIMITER ;


DROP TRIGGER IF EXISTS trig_DeleteOrderItems;
DELIMITER //
CREATE TRIGGER trig_DeleteOrderItems
BEFORE DELETE ON Orders
FOR EACH ROW 
BEGIN
    IF ((SELECT COUNT(OrderItems.OrderID) FROM OrderItems WHERE OrderItems.OrderID = OLD.OrderID) != 0)
    THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Вы не можете удалить этот заказ, т.к в таблице OrderItems есть данные этого заказа. Для начала удалите данные заказа.';
    END IF;
END //
DELIMITER ;


DROP TRIGGER IF EXISTS trig_DeleteOrderItems_Service;
DELIMITER //
CREATE TRIGGER trig_DeleteOrderItems_Service
BEFORE DELETE ON Services
FOR EACH ROW 
BEGIN
    IF ((SELECT COUNT(OrderItems.ServiceID) FROM OrderItems WHERE OrderItems.ServiceID = OLD.ServiceID) != 0)
    THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Вы не можете удалить эту услугу, т.к он используется в данных какого-либо заказа. Для начала удалите данные заказа.';
    END IF;
END //
DELIMITER ;


DROP TRIGGER IF EXISTS before_insert_Client;
DELIMITER //
CREATE TRIGGER before_insert_Client BEFORE INSERT ON Clients
FOR EACH ROW 
BEGIN
   
    IF EXISTS (SELECT 1 FROM Clients WHERE FirstName = NEW.FirstName AND LastName = NEW.LastName)
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Клиент с таким именем уже существует.';
    END IF;
 
END //
DELIMITER ;


DROP TRIGGER IF EXISTS before_insert_Order;
DELIMITER //
CREATE TRIGGER before_insert_Order BEFORE INSERT ON Orders
FOR EACH ROW 
BEGIN
    
    IF NEW.OrderDate > CURDATE()
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'OrderDate не может быть создано в будущем.';
    END IF;

    IF EXISTS (SELECT 1 FROM Orders WHERE ClientID = NEW.ClientID AND OrderDate = NEW.OrderDate)
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Заказ для того же клиента на ту же дату уже существует.';
    END IF;
    
    
    IF (NOT EXISTS (SELECT 1 FROM Clients WHERE ClientID = NEW.ClientID)) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Невозможно вставить заказ. ClientID не существует в таблице «Клиенты».';
    END IF;

END //
DELIMITER ;

DROP TRIGGER IF EXISTS before_insert_Service;
DELIMITER //
CREATE TRIGGER before_insert_Service BEFORE INSERT ON Services
FOR EACH ROW 
BEGIN
   
    IF NEW.Price < 0
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Цена не может быть отрицательной.';
    END IF;

    IF EXISTS (SELECT 1 FROM Services WHERE ServiceName = NEW.ServiceName)
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Service с таким названием уже существует.';
    END IF;

END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER before_insert_OrderItems
BEFORE INSERT ON OrderItems
FOR EACH ROW
BEGIN
    
    IF (NOT EXISTS (SELECT 1 FROM Orders WHERE OrderID = NEW.OrderID)) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Невозможно создать OrderItem, т.к данный OrderID не существует в таблице Orders.';
    END IF;
    
    IF (NOT EXISTS (SELECT 1 FROM Services WHERE ServiceID = NEW.ServiceID)) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Невозможно создать OrderItem, т.к данный ServiceID не существует в таблице Services.';
    END IF;
END //
DELIMITER ;


