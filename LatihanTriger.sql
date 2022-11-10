CREATE TABLE Produk
(
    id_produk NUMBER,
    produk VARCHAR(20),
    stok NUMBER,
    satuan VARCHAR(20),
    CONSTRAINT id_produk_pk PRIMARY KEY(id_produk)
);

CREATE TABLE Pesanan
(
    id_pesanan NUMBER,
    id_produk NUMBER,
    jumlah NUMBER,
    tgl_pesanan DATE,
    CONSTRAINT id_pesanan_pk PRIMARY KEY(id_pesanan),
    CONSTRAINT id_produk_fk FOREIGN KEY(id_produk) REFERENCES Produk(id_produk)
);

--Insert Produk ke table Produk
INSERT INTO Produk(id_produk, produk, stok, satuan)
    VALUES(1, 'Choki-Choki', 20, 'pcs');
INSERT INTO Produk(id_produk, produk, stok, satuan)
    VALUES(2, 'Potato Stick', 15, 'pcs');
INSERT INTO Produk(id_produk, produk, stok, satuan)
    VALUES(3, 'Silver Queen', 25, 'pcs');
INSERT INTO Produk(id_produk, produk, stok, satuan)
    VALUES(4, 'Pocky', 5, 'box');

--Insert Pesanan
INSERT INTO Pesanan(id_pesanan, id_produk, jumlah, tgl_pesanan)
    VALUES(1, 1, 2, CURRENT_DATE);


-- Membuat Trigger 1
CREATE OR REPLACE TRIGGER trg_update_stok
AFTER INSERT OR DELETE OR UPDATE ON Pesanan
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        UPDATE Produk SET stok = (stok - :new.jumlah) WHERE id_produk = :new.id_produk;
    ELSIF DELETING THEN
        UPDATE Produk SET stok = (stok + :old.jumlah) WHERE id_produk = :old.id_produk;
    ELSIF UPDATING THEN
        UPDATE Produk SET stok = ((stok + :old.jumlah) - :new.jumlah) WHERE id_produk = :old.id_produk;
    END IF;
END;


-- Membuat Trigger kedua dengan Prosedur Exception RAISE_APPLICATION_ERROR
CREATE OR REPLACE TRIGGER trg_update_stok
AFTER INSERT OR DELETE OR UPDATE ON Pesanan
FOR EACH ROW
DECLARE
tmp_stok NUMERIC;
BEGIN
    IF INSERTING THEN
        SELECT stok INTO tmp_stok FROM Produk WHERE id_produk = :new.id_produk;
    IF (:new.jumlah <= tmp_stok) THEN
        UPDATE Produk SET stok = (tmp_stok - :new.jumlah) WHERE id_produk = :new.id_produk;
    ELSE
        RAISE_APPLICATION_ERROR(-20000, 'Stok tidak mencukupi');
    END IF;
    ELSIF UPDATING THEN
    SELECT stok INTO tmp_stok FROM Produk WHERE id_produk = :new.id_produk;
    IF (:new.jumlah <= tmp_stok + :old.jumlah) THEN
        UPDATE Produk SET stok = ((tmp_stok + :old.jumlah) - :new.jumlah) WHERE id_produk = :old.id_produk;
    ELSE
        RAISE_APPLICATION_ERROR(-20000, 'Stok tidak mencukupi');
    END IF;
    ELSIF DELETING THEN
        UPDATE Produk SET stok = (stok + :old.jumlah) WHERE id_produk = :old.id_produk;
    END IF;
END;

--Insert Pesanan untuk memunculkan pesan stok tidak mencukupi
INSERT INTO Pesanan(id_pesanan, id_produk, jumlah, tgl_pesanan)
    VALUES(2, 1, 19, CURRENT_DATE);
