-- DML - Data Manipulation Language
-- Inserção de dados nas tabelas para testes
USE ecommerce;

-- =========================================================
-- 1. CLIENTES (Generalização e Especialização PF/PJ)

-- Inserção em CLIENTS (Generalização)
INSERT INTO clients (Fname, Minit, Lname, Address) VALUES 
('Maria', 'M', 'Silva', 'rua silva de prata 29, Carangola - Cidade das flores'),
('Matheus', 'O', 'Pimentel', 'rua alemeda 289, Centro - Cidade das flores'),
('Ricardo', 'F', 'Silva', 'avenida alemeda vinha 1009, Centro - Cidade das flores'),
('Julia', 'S', 'França', 'rua lareijeiras 861, Centro - Cidade das flores'),
('Roberta', 'G', 'Assis', 'avenidade koller 19, Centro - Cidade das flores'),
('Isabela', 'M', 'Cruz', 'rua alemeda das flores 28, Centro - Cidade das flores'),
('Tecno Soluções', NULL, 'Ltda', 'Av. Central 500, Bairro Industrial'); -- Cliente PJ (idClient = 7)

-- Inserção em CLIENTEPF (Especialização)
INSERT INTO clientPF (FK_idClient, CPF) VALUES 
(1, '12345678912'), (2, '98765432198'), (3, '45678913912'), 
(4, '78912345678'), (5, '98745632198'), (6, '65478912398'); 

-- Inserção em CLIENTEPJ (Especialização)
INSERT INTO clientPJ (FK_idClient, CNPJ, Razao_Social) VALUES 
(7, '11111111000111', 'Tecno Soluções em Informática Ltda');

-- =========================================================
-- 2. PRODUTOS (7 produtos)
INSERT INTO product (Pname, classification_kids, category, avaliacao, size) VALUES 
('Fone de ouvido', FALSE, 'Eletrônico', 4, NULL), 
('Barbie Elsa', TRUE, 'Brinquedos', 3, NULL), 
('Body Carters', TRUE, 'Vestimenta', 5, NULL),
('Microfone Vedo - Youtuber', FALSE, 'Eletrônico', 4, NULL),
('Sofá retrátil', FALSE, 'Móveis', 3, '3x57x80'),
('Farinha de arroz', FALSE, 'Alimentos', 2, NULL),
('Fire Stick Amazon', FALSE, 'Eletrônico', 3, NULL);

-- =========================================================
-- 3. FORNECEDOR (Supplier)
INSERT INTO supplier (SocialName, CNPJ, contact) VALUES 
('Almeida e filhos', '123456789123456', '21985474'),
('Eletrônicos Silva', '854519649143457', '21985484'),
('Eletrônicos Valma', '934567893934695', '21975474'); 

-- =========================================================
-- 4. VENDEDOR (Seller - Terceiro)
INSERT INTO seller (SocialName, AbstName, CNPJ, CPF, location, contact) VALUES 
('Tech eletronics', NULL, '123456789456321', NULL, 'Rio de Janeiro', '219946287'),
('Botique Durgas', NULL, NULL, '12345678378', 'Rio de Janeiro', '219567895'),
('Kids World', 'Kids', '456789123654485', NULL, 'São Paulo', '1198657484'),
('Eletrônicos Valma', NULL, '934567893934695', NULL, 'São Paulo', '11911112222'); -- CNPJ igual ao do Fornecedor 3

-- =========================================================
-- 5. ESTOQUE (ProductStorage)
INSERT INTO productStorage (storageLocation) VALUES 
('Armazém RJ'), 
('Armazém SP'),     
('Armazém BSB');     

-- =========================================================
-- 6. PEDIDOS (Orders)
INSERT INTO orders (idOrderClient, orderStatus, orderDescription, sendValue) VALUES 
(1, 'Em processamento', 'compra via aplicativo', 1.0),   -- Maria (idOrder=1)
(2, 'Em processamento', 'compra via aplicativo', 50.0),  -- Matheus (idOrder=2)
(3, 'Confirmado', NULL, 1.0),                             -- Ricardo (idOrder=3)
(7, 'Em processamento', 'compra via web site', 150.0);   -- Cliente PJ (idOrder=4)

-- =========================================================
-- 7. PAGAMENTOS (Refinamento: Múltiplas Formas)
INSERT INTO payments (FK_idOrder, typePayment, valuePayment) VALUES 
(1, 'Cartão', 100.0), 
(2, 'PIX', 50.0),    
(3, 'Boleto', 250.0), 
(3, 'Cartão', 100.0), -- Múltiplos pagamentos no Pedido 3
(4, 'Cartão', 2000.0); 

-- =========================================================
-- 8. ENTREGA (Refinamento: Status e Rastreio)
INSERT INTO delivery (FK_idOrder, Status_Entrega, Codigo_Rastreio, Data_Previsao) VALUES 
(1, 'Enviado', 'TRACKBR12345', DATE_ADD(CURDATE(), INTERVAL 5 DAY)),
(2, 'Pendente', 'TRACKBR67890', DATE_ADD(CURDATE(), INTERVAL 10 DAY)),
(3, 'Entregue', 'TRACKBR11223', DATE_SUB(CURDATE(), INTERVAL 2 DAY)), 
(4, 'Em trânsito', 'TRACKBR44556', DATE_ADD(CURDATE(), INTERVAL 7 DAY));

-- =========================================================
-- 9. RELACIONAMENTOS N:M

-- Inserção em productOrder (ITEM DE PEDIDO)
INSERT INTO productOrder (idPOproduct, idPOorder, poQuantity, poStatus) VALUES
(1, 1, 2, 'Disponível'),  -- Pedido 1: 2 Fones de ouvido
(2, 1, 1, 'Disponível'),  -- Pedido 1: 1 Barbie Elsa
(3, 4, 1, 'Disponível');  -- Pedido 4 (PJ): 1 Body Carters

-- Inserção em productSeller (VENDEDOR <-> PRODUTO)
INSERT INTO productSeller (idPseller, idProduct, prodQuantity) VALUES
(1, 6, 80), 
(2, 7, 10); 

-- Inserção em productSupplier (FORNECEDOR <-> PRODUTO)
INSERT INTO productSupplier (idPsSupplier, idPsProduct, quantity) VALUES
(1, 5, 500), 
(1, 2, 400), 
(2, 4, 633), 
(3, 3, 5),   
(2, 5, 10);  

-- Inserção em storageLocation (PRODUTO <-> ESTOQUE)
-- Ajuste: O seu print original usava a coluna 'location' e não 'quantity'.
-- Usamos 'quantity' para que as queries de estoque funcionem corretamente.
INSERT INTO storageLocation (idLproduct, idLstorage, location, quantity) VALUES 
(1, 2, 'RJ', 500), -- Fone (id 1) no Armazém SP (id 2), 500 unidades
(2, 3, 'GO', 400), -- Barbie (id 2) no Armazém BSB (id 3), 400 unidades
(3, 1, 'MG', 10);  -- Body Carters (id 3) no Armazém RJ (id 1), 10 unidades
