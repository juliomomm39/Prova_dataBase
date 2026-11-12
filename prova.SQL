CREATE TABLE investidores (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(11) NOT NULL UNIQUE CHECK (CHAR_LENGTH(cpf) = 11),
    nivel_experiencia INT DEFAULT 0 CHECK (nivel_experiencia >= 0)
);


CREATE TABLE carteiras (
    id SERIAL PRIMARY KEY,
    investidor_id INT NOT NULL REFERENCES investidores(id),
    endereco_wallet VARCHAR(100) NOT NULL UNIQUE,
    rede_blockchain VARCHAR(50) NOT NULL,
    saldo_usd DECIMAL(15,2) NOT NULL CHECK (saldo_usd > 0),
    status VARCHAR(20) DEFAULT 'Ativa'
    CHECK (status IN ('Ativa', 'Em Analise', 'Bloqueada', 'Pausada'))
);


CREATE TABLE corretoras (
    id SERIAL PRIMARY KEY,
    nome_exchange VARCHAR(100) NOT NULL,
    cnpj VARCHAR(14) NOT NULL UNIQUE CHECK (CHAR_LENGTH(cnpj) = 14),
    email_suporte VARCHAR(100) NOT NULL UNIQUE
);


CREATE TABLE criptomoedas (
    id SERIAL PRIMARY KEY,
    corretora_id INT NOT NULL REFERENCES corretoras(id),
    nome_moeda VARCHAR(50) NOT NULL,
    preco_unitario_usd DECIMAL(15,2) NOT NULL CHECK (preco_unitario_usd > 0),
    categoria VARCHAR(20) DEFAULT 'Layer1'
    CHECK (categoria IN ('Layer1', 'DeFi', 'Memecoin', 'Stablecoin'))
);


CREATE TABLE transacoes_cripto (
    id SERIAL PRIMARY KEY,
    carteira_id INT NOT NULL REFERENCES carteiras(id),
    criptomoeda_id INT NOT NULL REFERENCES criptomoedas(id),
    quantidade DECIMAL(15,8) NOT NULL CHECK (quantidade > 0),
    valor_pago DECIMAL(15,2) NOT NULL CHECK (valor_pago > 0),
    data_transacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


INSERT INTO investidores (nome, cpf, nivel_experiencia) VALUES
('Joao Silva', '12345678901', 2),
('Maria Santos', '23456789012', 3),
('Pedro Oliveira', '34567890123', 1),
('Ana Costa', '45678901234', 4),
('Lucas Pereira', '56789012345', 0);


INSERT INTO carteiras (investidor_id, endereco_wallet, rede_blockchain, saldo_usd, status) VALUES
(1, '0x71C001ABC', 'Ethereum', 2500.00, 'Ativa'),
(2, '0x71C002DEF', 'Bitcoin', 5000.00, 'Em Analise'),
(3, '0x71C003GHI', 'Solana', 1200.00, 'Bloqueada'),
(4, '0x71C004JKL', 'Ethereum', 3500.00, 'Pausada'),
(5, '0x71C005MNO', 'Bitcoin', 1800.00, 'Ativa');


INSERT INTO corretoras (nome_exchange, cnpj, email_suporte) VALUES
('Binance', '12345678000190', 'suporte@binance.com'),
('Coinbase', '23456789000191', 'suporte@coinbase.com'),
('Kraken', '34567890000192', 'suporte@kraken.com'),
('Bybit', '45678901000193', 'suporte@bybit.com'),
('OKX', '56789012000194', 'suporte@okx.com');


INSERT INTO criptomoedas (corretora_id, nome_moeda, preco_unitario_usd, categoria) VALUES
(1, 'Bitcoin', 95000.00, 'Layer1'),
(2, 'Ethereum', 3200.00, 'Layer1'),
(3, 'Solana', 180.00, 'Layer1'),
(4, 'Uniswap', 12.00, 'DeFi'),
(5, 'Dogecoin', 0.25, 'Memecoin');


INSERT INTO transacoes_cripto (carteira_id, criptomoeda_id, quantidade, valor_pago) VALUES
(1, 1, 0.02, 1900.00),
(2, 2, 0.50, 1600.00),
(3, 3, 10.00, 1800.00),
(4, 4, 60.00, 720.00),
(5, 5, 3000.00, 750.00);


SELECT
    carteiras.endereco_wallet,
    carteiras.rede_blockchain,
    carteiras.saldo_usd,
    investidores.nome,
    investidores.cpf
FROM carteiras
INNER JOIN investidores
ON carteiras.investidor_id = investidores.id
WHERE carteiras.status = 'Ativa'
OR carteiras.status = 'Em Analise';


SELECT
    corretoras.nome_exchange,
    SUM(transacoes_cripto.valor_pago) AS total_movimentado
FROM corretoras
LEFT JOIN criptomoedas
ON corretoras.id = criptomoedas.corretora_id
LEFT JOIN transacoes_cripto
ON criptomoedas.id = transacoes_cripto.criptomoeda_id
GROUP BY corretoras.id, corretoras.nome_exchange
ORDER BY total_movimentado DESC;


SELECT
    carteiras.endereco_wallet,
    criptomoedas.nome_moeda,
    transacoes_cripto.quantidade,
    transacoes_cripto.valor_pago,
    transacoes_cripto.data_transacao
FROM transacoes_cripto
INNER JOIN carteiras
ON transacoes_cripto.carteira_id = carteiras.id
INNER JOIN criptomoedas
ON transacoes_cripto.criptomoeda_id = criptomoedas.id
WHERE transacoes_cripto.valor_pago > 500
ORDER BY transacoes_cripto.valor_pago DESC;


CREATE VIEW vw_painel_carteiras AS
SELECT
    carteiras.endereco_wallet,
    carteiras.rede_blockchain,
    carteiras.status,
    carteiras.saldo_usd,
    investidores.nome,
    investidores.cpf
FROM carteiras
INNER JOIN investidores
ON carteiras.investidor_id = investidores.id;


CREATE VIEW vw_investimento_total_carteiras AS
SELECT
    carteiras.id,
    carteiras.endereco_wallet,
    carteiras.saldo_usd,
    COUNT(transacoes_cripto.id) AS quantidade_transacoes,
    COALESCE(SUM(transacoes_cripto.valor_pago), 0) AS custo_total
FROM carteiras
LEFT JOIN transacoes_cripto
ON carteiras.id = transacoes_cripto.carteira_id
GROUP BY
    carteiras.id,
    carteiras.endereco_wallet,
    carteiras.saldo_usd;