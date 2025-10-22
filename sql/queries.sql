-- DQL - Data Query Language
-- Consultas complexas para análise de dados

USE ecommerce;

-- --------------------------------------------------------------------------------------
-- 1. Quantos pedidos foram feitos por cada cliente (PJ e PF)?
-- Requisitos: SELECT, JUNÇÕES (LEFT JOIN), ATRIBUTO DERIVADO (COALESCE/COUNT), ORDER BY
-- --------------------------------------------------------------------------------------
SELECT
    C.idClient,
    -- COALESCE: Atributo Derivado para exibir o nome de PF ou Razão Social de PJ
    COALESCE(PF.Lname, PJ.Razao_Social) AS Nome_Cliente,
    COUNT(O.idOrder) AS Total_Pedidos
FROM clients C
LEFT JOIN clientPF PF ON C.idClient = PF.FK_idClient
LEFT JOIN clientPJ PJ ON C.idClient = PJ.FK_idClient
LEFT JOIN orders O ON C.idClient = O.idOrderClient
GROUP BY C.idClient, Nome_Cliente
ORDER BY Total_Pedidos DESC;


-- --------------------------------------------------------------------------------------
-- 2. Algum vendedor (Seller) também é fornecedor (Supplier)?
-- Requisitos: SELECT, JUNÇÕES (JOIN), FILTRO
-- --------------------------------------------------------------------------------------
SELECT 
    S.SocialName AS Nome_Vendedor_Fornecedor,
    S.CNPJ
FROM seller S
INNER JOIN supplier SU ON S.CNPJ = SU.CNPJ
WHERE S.CNPJ IS NOT NULL; -- Filtra apenas aqueles que têm CNPJ para a comparação


-- --------------------------------------------------------------------------------------
-- 3. Relação de produtos fornecidos e a quantidade total em estoque.
-- Requisitos: SELECT, JUNÇÕES (JOIN, LEFT JOIN), ATRIBUTO DERIVADO (SUM), ORDER BY
-- --------------------------------------------------------------------------------------
SELECT
    P.Pname AS Nome_Produto,
    S.SocialName AS Nome_Fornecedor,
    -- COALESCE para garantir que produtos sem estoque registrado retornem 0
    COALESCE(SUM(SL.quantity), 0) AS Quantidade_Total_Em_Estoque
FROM product P
JOIN productSupplier PS ON P.idProduct = PS.idPsProduct
JOIN supplier S ON PS.idPsSupplier = S.idSupplier
LEFT JOIN storageLocation SL ON P.idProduct = SL.idLproduct
GROUP BY P.Pname, S.SocialName
ORDER BY Quantidade_Total_Em_Estoque DESC;


-- --------------------------------------------------------------------------------------
-- 4. Quais clientes (PJ ou PF) tiveram um valor médio de pedido superior a R$ 100,00?
-- Requisitos: SELECT, JUNÇÕES (JOIN), AGRUPAMENTO (GROUP BY), FILTRO EM GRUPOS (HAVING), ATRIBUTO DERIVADO (AVG)
-- --------------------------------------------------------------------------------------
SELECT
    COALESCE(PF.Lname, PJ.Razao_Social) AS Cliente,
    COUNT(O.idOrder) AS Num_Pedidos,
    AVG(T.Valor_Total_Pedido) AS Ticket_Medio_Pedido
FROM clients C
LEFT JOIN clientPF PF ON C.idClient = PF.FK_idClient
LEFT JOIN clientPJ PJ ON C.idClient = PJ.FK_idClient
JOIN orders O ON C.idClient = O.idOrderClient
JOIN (
    -- Subconsulta para calcular o valor total de cada pedido (devido aos múltiplos pagamentos)
    SELECT FK_idOrder, SUM(valuePayment) AS Valor_Total_Pedido
    FROM payments
    GROUP BY FK_idOrder
) AS T ON O.idOrder = T.FK_idOrder
GROUP BY Cliente
HAVING AVG(T.Valor_Total_Pedido) > 100.00 -- Filtro de grupo: Ticket Médio > 100
ORDER BY Ticket_Medio_Pedido DESC;


-- --------------------------------------------------------------------------------------
-- 5. Qual o status e o tempo de envio (em dias) para todos os pedidos rastreáveis?
-- Requisitos: SELECT, JUNÇÕES (JOIN), ATRIBUTO DERIVADO (DATEDIFF)
-- --------------------------------------------------------------------------------------
SELECT
    O.idOrder AS Pedido,
    D.Status_Entrega,
    D.Codigo_Rastreio,
    DATEDIFF(D.Data_Previsao, CURDATE()) AS Dias_Restantes_Para_Previsao,
    -- Atributo Derivado que mostra se a previsão está no passado (atraso)
    CASE 
        WHEN DATEDIFF(D.Data_Previsao, CURDATE()) < 0 AND D.Status_Entrega != 'Entregue' THEN 'ATRASADO'
        WHEN DATEDIFF(D.Data_Previsao, CURDATE()) < 0 AND D.Status_Entrega = 'Entregue' THEN 'Entregue com Atraso'
        WHEN DATEDIFF(D.Data_Previsao, CURDATE()) = 0 THEN 'Entrega Hoje'
        ELSE 'No Prazo'
    END AS Status_Prazo
FROM delivery D
JOIN orders O ON D.FK_idOrder = O.idOrder
ORDER BY D.Status_Entrega, Dias_Restantes_Para_Previsao;
