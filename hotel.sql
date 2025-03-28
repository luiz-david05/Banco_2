CREATE TABLE HOSPEDE (
	cod_hosp INT PRIMARY KEY NOT NULL,
	dt_nasc DATE NOT NULL,
	nome VARCHAR(100) NOT NULL
);

CREATE TABLE FUNCIONARIO (
	cod_func INT PRIMARY KEY NOT NULL,
	dt_nasc DATE NOT NULL,
	nome VARCHAR(100) NOT NULL
);

CREATE TABLE CATEGORIA (
	cod_cat INT PRIMARY KEY NOT NULL,
	preco DECIMAL(10, 2) NOT NULL,
	nome VARCHAR(20) NOT NULL
);

CREATE TABLE APARTAMENTO (
	num_ap INT PRIMARY KEY NOT NULL,
	cod_cat INT,
	FOREIGN KEY (cod_cat) REFERENCES CATEGORIA(cod_cat)
);

CREATE TABLE HOSPEDAGEM (
	cod_hospedagem INT PRIMARY KEY,
	cod_func INT,
	cod_hosp INT,
	num_ap INT,
	dt_ent DATE NOT NULL,
	dt_saida DATE,
	FOREIGN KEY (cod_func) REFERENCES FUNCIONARIO(cod_func),
	FOREIGN KEY (cod_hosp) REFERENCES HOSPEDE(cod_hosp),
	FOREIGN KEY (num_ap) REFERENCES APARTAMENTO(num_ap)
);


-- INSERTS

INSERT INTO HOSPEDE (cod_hosp, dt_nasc, nome) VALUES
(1, '1990-05-15', 'Carlos Silva'),
(2, '1985-09-23', 'Maria Oliveira'),
(3, '2000-11-10', 'João Santos');

INSERT INTO FUNCIONARIO (cod_func, dt_nasc, nome) VALUES
(1, '1980-07-20', 'Ana Souza'),
(2, '1995-03-14', 'Pedro Lima');

INSERT INTO CATEGORIA (cod_cat, preco, nome) VALUES
(1, 150.00, 'Standard'),
(2, 250.00, 'Luxo'),
(3, 400.00, 'Presidencial');

INSERT INTO APARTAMENTO (num_ap, cod_cat) VALUES
(200, 1),
(201, 1),
(202, 2),
(203, 2),
(204, 3);

INSERT INTO HOSPEDAGEM (cod_hospedagem, cod_func, cod_hosp, num_ap, dt_ent, dt_saida) VALUES
(1, 1, 1, 200, '2024-03-01', '2024-03-05'),
(2, 2, 2, 201, '2024-03-02', '2024-03-06'),
(3, 1, 3, 202, '2024-03-03', NULL);


-- 1 Nomes das categorias que possuam preços entre R$ 100,00 e R$ 200,00.
SELECT nome FROM CATEGORIA WHERE preco BETWEEN 100.00 AND 200.00;

-- 2  Nomes das categorias cujos nomes possuam a palavra ‘Luxo’.
SELECT nome FROM CATEGORIA WHERE nome LIKE '%Luxo%'

-- 3  Número dos apartamentos que estão ocupados, ou seja, a data de saída está vazia. 
SELECT num_ap FROM HOSPEDAGEM WHERE dt_saida IS NULL;

-- 4  Número dos apartamentos cuja categoria tenha código 1, 2, 3, 11, 34, 54, 24, 12. 
SELECT num_ap FROM APARTAMENTO WHERE cod_cat IN (1, 2, 3, 11, 34, 54, 24, 12);

-- 5 Todas as informações dos apartamentos cujas categorias iniciam com a palavra ‘Luxo’.
SELECT * 
FROM APARTAMENTO 
WHERE cod_cat IN (SELECT cod_cat FROM CATEGORIA WHERE nome LIKE 'Luxo%');

-- 6 Quantidade de apartamentos cadastrados no sistema

SELECT COUNT(*) FROM APARTAMENTO;

-- 7. Somatório dos preços das categorias. 

SELECT SUM(preco) FROM CATEGORIA;

-- 8. Média de preços das categorias. 

SELECT AVG(preco) FROM CATEGORIA;

-- 9. Maior preço de categoria. 

SELECT MAX(preco) FROM CATEGORIA;

-- 10. Menor preço de categoria. 

SELECT MIN(preco) FROM CATEGORIA;

-- 11. Nome dos hóspedes que nasceram após 1° de janeiro de 1970. 

SELECT nome FROM HOSPEDE WHERE dt_nasc > '1970-01-01';

-- 12. Quantidade de hóspedes. 

-- dos que ainda estao hospedados 
SELECT COUNT(DISTINCT cod_hosp) AS qtd_hosp_hospedados FROM HOSPEDAGEM
WHERE dt_saida IS NULL;

-- de todos cadastrados no sistema

SELECT COUNT(*) AS qtd_hosp_cadastrados FROM HOSPEDE;

-- 13. Altere a tabela Hóspede, acrescentando o campo "Nacionalidade". 

ALTER TABLE HOSPEDE ADD COLUMN nacionalidade VARCHAR(50) NOT NULL DEFAULT 'brasileiro(a)';

-- 14. A data de nascimento do hóspede mais velho. 

SELECT MIN(dt_nasc) AS dt_nasc_mais_velho FROM HOSPEDE;

-- 15. A data de nascimento do hóspede mais novo. 

SELECT MAX(dt_nasc) AS dt_nasc_mais_novo FROM HOSPEDE;

-- 16. O nome do hóspede mais velho 

-- com subquery
SELECT nome AS nome_hosp_mais_velho
FROM HOSPEDE WHERE dt_nasc IN (SELECT MIN(dt_nasc) FROM HOSPEDE);

-- com ORDER BY, LIMIT E ASC(ASCENDING)
SELECT nome AS nome_hosp_mais_velho
FROM HOSPEDE ORDER BY dt_nasc ASC LIMIT 1;

-- 17. Reajuste em 10% o valor das diárias das categorias. 

-- vendo o preco atual das diarias 
SELECT * FROM CATEGORIA

-- aplicando o reajuste
UPDATE CATEGORIA SET preco = preco * 1.10;

-- 18. O número do apartamento mais caro ocupado pelo João.

--  h alias de HOSPEDAGEM, a alias de APARTAMENTO, hs alias de HOSPEDAGEM e 
--  c alias de CATEGORIA
--  o LIKE eh opcional, pq no meu banco so tinha um joao e 
--  eu n queria por o nome especifico
SELECT h.num_ap AS num_ap_mais_caro_ocupado_pelo_joao
FROM HOSPEDAGEM h
JOIN APARTAMENTO a ON h.num_ap = a.num_ap
JOIN HOSPEDE hs ON h.cod_hosp = hs.cod_hosp
JOIN CATEGORIA c ON a.cod_cat = c.cod_cat
WHERE hs.nome LIKE '%João%'
AND c.preco = (
    SELECT MAX(c2.preco)
    FROM CATEGORIA c2
    JOIN APARTAMENTO a2 ON c2.cod_cat = a2.cod_cat
    JOIN HOSPEDAGEM h2 ON a2.num_ap = h2.num_ap
    JOIN HOSPEDE hs2 ON h2.cod_hosp = hs2.cod_hosp
    WHERE hs2.nome LIKE '%João%'
);

-- 19. O nome dos hóspedes que nunca se hospedaram no apartamento 201.

SELECT nome AS hosp_que_nunca_se_hospedaram_no_201 FROM HOSPEDE
WHERE cod_hosp NOT IN (
	SELECT cod_hosp FROM HOSPEDAGEM WHERE num_ap = 201
);

-- 20. O nome dos hóspedes que nunca se hospedaram em apartamentos da categoria LUXO.

-- usando subquery
SELECT nome AS hosp_que_nunca_se_hospedaram_cat_luxo
FROM HOSPEDE
WHERE cod_hosp NOT IN (
    SELECT cod_hosp
    FROM HOSPEDAGEM
    WHERE num_ap IN (
        SELECT num_ap
        FROM APARTAMENTO
        WHERE cod_cat = (SELECT cod_cat FROM CATEGORIA WHERE nome = 'Luxo')
    )
);

--  O nome do hóspede mais velho que foi atendido pelo atendente mais novo.