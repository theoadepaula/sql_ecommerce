-- DDL - Data Definition Language
-- Criação do esquema de banco de dados para o cenário de E-commerce (MySQL)

DROP DATABASE IF EXISTS ecommerce;
CREATE DATABASE ecommerce;
USE ecommerce;

-- --------------------------------------------------------
-- TABELA CLIENTES (Generalização)
-- Contém dados comuns a PF e PJ.
CREATE TABLE clients(
    idClient INT AUTO_INCREMENT PRIMARY KEY,
    Fname VARCHAR(10) NOT NULL,
    Minit CHAR(3),
    Lname VARCHAR(20),
    Address VARCHAR(255) NOT NULL 
);

-- TABELA CLIENTE PESSOA FÍSICA (Especialização)
CREATE TABLE clientPF(
    idClientPF INT AUTO_INCREMENT,
    CPF CHAR(11) NOT NULL,
    -- FK_idClient é PK para garantir relacionamento 1:1 e exclusividade
    FK_idClient INT NOT NULL, 
    PRIMARY KEY (idClientPF, FK_idClient),
    CONSTRAINT unique_cpf_client UNIQUE (CPF),
    CONSTRAINT fk_clientpf_client FOREIGN KEY (FK_idClient) REFERENCES clients(idClient)
        ON UPDATE CASCADE
);

-- TABELA CLIENTE PESSOA JURÍDICA (Especialização)
CREATE TABLE clientPJ(
    idClientPJ INT AUTO_INCREMENT,
    CNPJ CHAR(15) NOT NULL,
    Razao_Social VARCHAR(255) NOT NULL,
    -- FK_idClient é PK para garantir relacionamento 1:1 e exclusividade
    FK_idClient INT NOT NULL, 
    PRIMARY KEY (idClientPJ, FK_idClient),
    CONSTRAINT unique_cnpj_client UNIQUE (CNPJ),
    CONSTRAINT fk_clientpj_client FOREIGN KEY (FK_idClient) REFERENCES clients(idClient)
        ON UPDATE CASCADE
);

-- --------------------------------------------------------
-- TABELA PRODUTO
CREATE TABLE product(
    idProduct INT AUTO_INCREMENT PRIMARY KEY,
    Pname VARCHAR(255) NOT NULL, 
    classification_kids BOOL DEFAULT FALSE,
    category ENUM('Eletrônico', 'Vestimenta', 'Brinquedos', 'Alimentos', 'Móveis') NOT NULL,
    avaliacao FLOAT DEFAULT 0,
    size VARCHAR(10)
);

-- --------------------------------------------------------
-- TABELA FORNECEDOR (Supplier)
CREATE TABLE supplier(
    idSupplier INT AUTO_INCREMENT PRIMARY KEY,
    SocialName VARCHAR(255) NOT NULL,
    CNPJ CHAR(15) NOT NULL,
    contact CHAR(11) NOT NULL,
    CONSTRAINT unique_supplier UNIQUE (CNPJ)
);

-- --------------------------------------------------------
-- TABELA VENDEDOR (Seller - Terceiro)
CREATE TABLE seller(
    idSeller INT AUTO_INCREMENT PRIMARY KEY,
    SocialName VARCHAR(255) NOT NULL,
    AbstName VARCHAR(255),
    CNPJ CHAR(15), 
    CPF CHAR(11), 
    location VARCHAR(255),
    contact CHAR(11) NOT NULL,
    CONSTRAINT unique_cnpj_seller UNIQUE (CNPJ),
    CONSTRAINT unique_cpf_seller UNIQUE (CPF)
);

-- --------------------------------------------------------
-- TABELA DE ESTOQUE (Product Storage)
-- O seu print de INSERTs usa 'productStorage', mas a tabela de relacionamento usa 'idLstorage'
-- Focamos no seu print de INSERT (productStorage) para consistência.
CREATE TABLE productStorage(
    idProdStorage INT AUTO_INCREMENT PRIMARY KEY,
    storageLocation VARCHAR(255) NOT NULL
    -- A coluna 'quantity' foi movida para a tabela N:M (storageLocation)
);

-- --------------------------------------------------------
-- TABELA PEDIDO (Orders)
CREATE TABLE orders(
    idOrder INT AUTO_INCREMENT PRIMARY KEY,
    idOrderClient INT NOT NULL,
    orderStatus ENUM('Cancelado', 'Confirmado', 'Em processamento') DEFAULT 'Em processamento',
    orderDescription VARCHAR(255),
    sendValue FLOAT DEFAULT 10,
    -- paymentCash foi removido para ser tratado na nova tabela payments
    CONSTRAINT fk_ordes_client FOREIGN KEY (idOrderClient) REFERENCES clients(idClient)
        ON UPDATE CASCADE
);

-- --------------------------------------------------------
-- TABELA PAGAMENTO (Refinamento: Múltiplas formas por pedido)
-- Ligação 1:N com 'orders'.
CREATE TABLE payments(
    idPayment INT AUTO_INCREMENT PRIMARY KEY,
    FK_idOrder INT NOT NULL, -- Ligação com a tabela Pedido
    typePayment ENUM('Boleto', 'Cartão', 'Dois cartões', 'PIX') NOT NULL,
    valuePayment FLOAT NOT NULL,
    
    CONSTRAINT fk_payment_order FOREIGN KEY (FK_idOrder) REFERENCES orders(idOrder)
        ON UPDATE CASCADE
);

-- --------------------------------------------------------
-- TABELA ENTREGA (Refinamento: Status e Rastreio)
CREATE TABLE delivery(
    idDelivery INT AUTO_INCREMENT PRIMARY KEY,
    FK_idOrder INT NOT NULL,
    Status_Entrega ENUM('Pendente', 'Enviado', 'Em trânsito', 'Entregue') DEFAULT 'Pendente',
    Codigo_Rastreio VARCHAR(45),
    Data_Previsao DATE,
    CONSTRAINT fk_delivery_order FOREIGN KEY (FK_idOrder) REFERENCES orders(idOrder)
        ON UPDATE CASCADE
);

-- --------------------------------------------------------
-- TABELAS DE RELACIONAMENTO N:M

-- PRODUTO POR VENDEDOR
CREATE TABLE productSeller(
    idPseller INT NOT NULL,
    idProduct INT NOT NULL,
    prodQuantity INT DEFAULT 1,
    PRIMARY KEY (idPseller, idProduct),
    CONSTRAINT fk_product_seller FOREIGN KEY (idPseller) REFERENCES seller(idSeller),
    CONSTRAINT fk_product_product_s FOREIGN KEY (idProduct) REFERENCES product(idProduct)
);

-- PRODUTO POR FORNECEDOR
CREATE TABLE productSupplier(
    idPsSupplier INT NOT NULL,
    idPsProduct INT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (idPsSupplier, idPsProduct),
    CONSTRAINT fk_prod_supplier
