DROP DATABASE IF EXISTS uvv;

DROP USER IF EXISTS leonardo;
-- 1. Criação de usuário específico


CREATE USER leonardo WITH
  NOSUPERUSER
  CREATEDB
  CREATEROLE
  LOGIN
  ENCRYPTED PASSWORD '123456'
;

-- 2. Criação do banco de dados "uvv"
CREATE DATABASE uvv WITH
  OWNER      = leonardo
  TEMPLATE   = template0
  ENCODING   = 'UTF-8'
  LC_COLLATE = 'pt_BR.UTF-8'
  LC_CTYPE   = 'pt_BR.UTF-8'
;

-- 3. Troca de usuário
\echo Conectando ao novo banco de dados:
\c "dbname=uvv user=leonardo password=123456"


-- 4. Criação do esquema "lojas"
\echo Criando e configurando o schema "lojas" restrito ao usuário "leonardo":
CREATE SCHEMA lojas AUTHORIZATION leonardo;

-- Ajusta o SEARCH_PATH da conexão atual ao banco de dados:
SET SEARCH_PATH TO lojas, "$user", public; 

-- Alterando o search_path permanentemente para o usuário
ALTER USER leonardo SET SEARCH_PATH TO lojas, "$user", public;

CREATE TABLE lojas.produto (
                produto_id NUMERIC(38) NOT NULL,
                nome VARCHAR(255) NOT NULL,
                preco_unitario NUMERIC(10,2),
                detalhes BYTEA,
                imagem BYTEA,
                imagem_mime_type VARCHAR(512),
                imagem_arquivo VARCHAR(512),
                imagem_charset VARCHAR(512),
                imagem_ultima_atualizacao DATE,
                CONSTRAINT produto_pk PRIMARY KEY (produto_id)
);
COMMENT ON COLUMN lojas.produto.nome IS 'nome do produto';
COMMENT ON COLUMN lojas.produto.imagem IS 'imagem do produto

';


CREATE SEQUENCE lojas.clientes_cliente_id_seq;

CREATE TABLE lojas.clientes (
                cliente_id NUMERIC(38) NOT NULL DEFAULT nextval('lojas.clientes_cliente_id_seq'),
                telefone1 VARCHAR(20),
                telefone2 VARCHAR(20),
                telefone3 VARCHAR(20),
                email VARCHAR(255) NOT NULL,
                nome VARCHAR(255) NOT NULL,
                CONSTRAINT clientes_pk PRIMARY KEY (cliente_id)
);
COMMENT ON COLUMN lojas.clientes.cliente_id IS 'id do cliente
';
COMMENT ON COLUMN lojas.clientes.nome IS 'nome do cliente
';


ALTER SEQUENCE lojas.clientes_cliente_id_seq OWNED BY lojas.clientes.cliente_id;

CREATE TABLE lojas.lojas (
                loja_id NUMERIC(38) NOT NULL,
                nome VARCHAR(255) NOT NULL,
                endereco_web VARCHAR(100),
                endereco_fisico VARCHAR(512),
                latitude NUMERIC,
                longitude NUMERIC,
                logo BYTEA,
                logo_mime_type VARCHAR(512),
                logo_arquivo VARCHAR(512),
                logo_charset VARCHAR(512),
                logo_ultima_atualizacao DATE,
                CONSTRAINT lojas_pk PRIMARY KEY (loja_id)
);
COMMENT ON COLUMN lojas.lojas.loja_id IS 'id da loja';
COMMENT ON COLUMN lojas.lojas.nome IS 'nome da loja';
COMMENT ON COLUMN lojas.lojas.endereco_web IS 'endereço web da loja
';
COMMENT ON COLUMN lojas.lojas.endereco_fisico IS 'endereco fisico da loja
';
COMMENT ON COLUMN lojas.lojas.logo IS 'logo da loja
';


CREATE TABLE lojas.envios (
                envio_id NUMERIC(38) NOT NULL,
                status VARCHAR(15) NOT NULL,
                endereco_entrega VARCHAR(512) NOT NULL,
                loja_id NUMERIC(38) NOT NULL,
                cliente_id NUMERIC(38) NOT NULL,
                CONSTRAINT envios_pk PRIMARY KEY (envio_id)
);
COMMENT ON COLUMN lojas.envios.endereco_entrega IS 'endereço da entrega';
COMMENT ON COLUMN lojas.envios.loja_id IS 'id da loja';
COMMENT ON COLUMN lojas.envios.cliente_id IS 'id do cliente
';


CREATE TABLE lojas.estoques (
                estoque_id NUMERIC(38) NOT NULL,
                produto_id NUMERIC(38) NOT NULL,
                loja_id NUMERIC(38) NOT NULL,
                quantidade NUMERIC(38) NOT NULL,
                CONSTRAINT estoques_pk PRIMARY KEY (estoque_id)
);
COMMENT ON COLUMN lojas.estoques.loja_id IS 'id da loja';


CREATE SEQUENCE lojas.pedidos_pedidos_id_seq;

CREATE TABLE lojas.pedidos (
                pedido_id NUMERIC(38) NOT NULL DEFAULT nextval('lojas.pedidos_pedidos_id_seq'),
                data_hora TIMESTAMP NOT NULL,
                cliente_id NUMERIC(38) NOT NULL,
                loja_id NUMERIC(38) NOT NULL,
                status VARCHAR(15) NOT NULL,
                CONSTRAINT pedidos_pk PRIMARY KEY (pedido_id)
);
COMMENT ON COLUMN lojas.pedidos.pedido_id IS 'id dos pedidos
';
COMMENT ON COLUMN lojas.pedidos.data_hora IS 'data e hora do pedido';
COMMENT ON COLUMN lojas.pedidos.cliente_id IS 'id do cliente
';
COMMENT ON COLUMN lojas.pedidos.loja_id IS 'id da loja';


ALTER SEQUENCE lojas.pedidos_pedidos_id_seq OWNED BY lojas.pedidos.pedido_id;

CREATE TABLE lojas.pedidos_itens (
                pedido_id NUMERIC(38) NOT NULL,
                produto_id NUMERIC(38) NOT NULL,
                numero_da_linha NUMERIC(38) NOT NULL,
                preco_unitario NUMERIC(10,2) NOT NULL,
                quantidade NUMERIC(38) NOT NULL,
                envio_id NUMERIC(38) NOT NULL,
                CONSTRAINT pedidos_itens_pk PRIMARY KEY (pedido_id, produto_id)
);
COMMENT ON COLUMN lojas.pedidos_itens.pedido_id IS 'id dos pedidos
';


ALTER TABLE lojas.pedidos_itens ADD CONSTRAINT produto_pedidos_itens_fk
FOREIGN KEY (produto_id)
REFERENCES lojas.produto (produto_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE lojas.estoques ADD CONSTRAINT produto_estoques_fk
FOREIGN KEY (produto_id)
REFERENCES lojas.produto (produto_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE lojas.pedidos ADD CONSTRAINT clientes_pedidos_fk
FOREIGN KEY (cliente_id)
REFERENCES lojas.clientes (cliente_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE lojas.envios ADD CONSTRAINT clientes_envios_fk
FOREIGN KEY (cliente_id)
REFERENCES lojas.clientes (cliente_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE lojas.pedidos ADD CONSTRAINT lojas_pedidos_fk
FOREIGN KEY (loja_id)
REFERENCES lojas.lojas (loja_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE lojas.estoques ADD CONSTRAINT lojas_estoques_fk
FOREIGN KEY (loja_id)
REFERENCES lojas.lojas (loja_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE lojas.envios ADD CONSTRAINT lojas_envios_fk
FOREIGN KEY (loja_id)
REFERENCES lojas.lojas (loja_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE lojas.pedidos_itens ADD CONSTRAINT envios_pedidos_itens_fk
FOREIGN KEY (envio_id)
REFERENCES lojas.envios (envio_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE lojas.pedidos_itens ADD CONSTRAINT pedidos_pedidos_itens_fk
FOREIGN KEY (pedido_id)
REFERENCES lojas.pedidos (pedido_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

-- Restrições de valores permitidos
ALTER TABLE lojas.pedidos ADD CONSTRAINT ck_status_pedido CHECK (status IN ('CANCELADO', 'COMPLETO', 'ABERTO', 'PAGO', 'REEMBOLSADO', 'ENVIADO'));
ALTER TABLE lojas.envios ADD CONSTRAINT ck_status_envio CHECK (status IN ('CRIADO', 'ENVIADO', 'TRANSITO', 'ENTREGUE'));

-- Restrição de checagem específica
ALTER TABLE lojas.lojas ADD CONSTRAINT ck_endereco_fisico CHECK (endereco_web IS NOT NULL OR endereco_fisico IS NOT NULL);


-- 7. Inserção de dados 
-- Inserção de clientes
INSERT INTO lojas.clientes (email, nome, telefone1, telefone2, telefone3)
VALUES ('cliente1@example.com', 'Cliente 1', '123456789', NULL, NULL),
       ('cliente2@example.com', 'Cliente 2', '987654321', '987654322', NULL),
       ('cliente3@example.com', 'Cliente 3', '111111111', '222222222', '333333333');

-- Inserção de lojas
INSERT INTO lojas.lojas (nome, endereco_web, endereco_fisico, latitude, longitude, logo, logo_mime_type, logo_arquivo, logo_charset, logo_ultima_atualizacao)
VALUES ('Loja 1', 'www.loja1.com', 'Endereço 1', 123.456, 789.123, NULL, NULL, NULL, NULL, NULL),
       ('Loja 2', 'www.loja2.com', 'Endereço 2', 456.789, 321.987, NULL, NULL, NULL, NULL, NULL);

-- Inserção de produtos
INSERT INTO lojas.produtos (nome, preco_unitario, detalhes, imagem, imagem_mime_type, imagem_arquivo, imagem_charset, imagem_ultima_atualizacao)
VALUES ('Produto 1', 9.99, NULL, NULL, NULL, NULL, NULL, NULL),
       ('Produto 2', 19.99, NULL, NULL, NULL, NULL, NULL, NULL),
       ('Produto 3', 29.99, NULL, NULL, NULL, NULL, NULL, NULL);

-- Inserção de pedidos
INSERT INTO lojas.pedidos (data_hora, cliente_id, loja_id)
VALUES ('2023-05-19 10:00:00', 1, 1),
       ('2023-05-19 11:00:00', 2, 1),
       ('2023-05-19 12:00:00', 3, 2);

-- Inserção de pedidos_itens
INSERT INTO lojas.pedidos_itens (pedido_id, produto_id, numero_da_linha, preco_unitario, quantidade, envio_id)
VALUES (1, 1, 1, 9.99, 2, NULL),
       (1, 2, 2, 19.99, 1, NULL),
       (2, 2, 1, 19.99, 3, NULL),
       (3, 3, 1, 29.99, 1, NULL);

-- Inserção de estoques
INSERT INTO lojas.estoques (loja_id, produto_id, quantidade)
VALUES (1, 1, 10),
       (1, 2, 5),
       (2, 2, 8),
       (2, 3, 3);

-- Inserção de envios
INSERT INTO lojas.envios (loja_id, cliente_id)
VALUES (1, 1),
       (1, 2),
       (2, 3);
