-- set sql_set_updates = 0; -- Para poder excluir sem Where. 
drop database dbDistribuidora;
create database dbDistribuidora;
use dbDistribuidora;

CREATE TABLE tbCliente(
	IdCli INT PRIMARY KEY AUTO_INCREMENT,
    NomeCli VARCHAR(200) NOT NULL,
    NumEnd NUMERIC(6) NOT NULL,
    CompEnd VARCHAR(50),
    CepCli NUMERIC(8) NOT NULL
);

CREATE TABLE tbClientePF(
	CPF NUMERIC(11) PRIMARY KEY,
    RG NUMERIC(9) NOT NULL,
    RG_Dig CHAR(1) NOT NULL,
    Nasc DATE NOT NULL,
    IdCli INT UNIQUE NOT NULL 
); 

CREATE TABLE tbClientePJ(
	CNPJ NUMERIC(14) PRIMARY KEY,
    IE NUMERIC(11) UNIQUE,
    IdCli INT UNIQUE NOT NULL 
);

create table tbProduto(
    CodigoBarras numeric(14) primary key,
    NomeProd varchar(200) not null,
    Valor decimal(5,2) not null,
    Qtd int
);

create table tbCompra(
	CodigoCompra numeric(10) primary key,
    DataCompra date default(current_timestamp()),
    ValorTotal decimal(6,2) not null,
    QtdTotal int not null,
    NotaFiscal int,
    IdCli int
);

create table tbNotaFiscal(
	NotaFiscal int primary key,
    TotalNota decimal(5,2) not null,
    DataEmissao date not null
);

create table tbItemCompra(
	NotaFiscal int,
    CodigoBarras numeric(14),
    ValorItem decimal(5,2) not null,
    Qtd int not null,
    primary key(NotaFiscal,CodigoBarras)
);

create table tbFornecedor(
	IdFornecedor int auto_increment primary key,
    CNPJ numeric(13) not null unique,
    NomeFornecedor varchar(100) not null,
    telefone numeric(11)
);

create table tbPedido(
	NotaFiscalPedido int primary key,
    DataCompra date not null,
    ValorTotal decimal (6,2) not null,
    QtdTotal int not null,
    IdFornecedor int
);

create table tbPedidoProduto(
	NotaFiscalPedido int,
    CodigoBarras numeric(14),
    primary key(NotaFiscalPedido,CodigoBarras)
);

CREATE TABLE tbEndereco(
	CEP NUMERIC(8) PRIMARY KEY,
    Logradouro VARCHAR(200),
    IdBairro INT NOT NULL,
    IdCidade INT NOT NULL,
    IdUF INT NOT NULL
);

CREATE TABLE tbBairro(
    IdBairro INT PRIMARY KEY AUTO_INCREMENT,
    Bairro VARCHAR(200) NOT NULL
);

create table tbCidade(
    IdCidade int primary key auto_increment,
    Cidade varchar(200) not null
);

create table tbUF(
    IdUF int primary key auto_increment,
    UF varchar(200) not null
);

alter table tbCliente add foreign key (CepCli) references tbEndereco(CEP);

alter table tbClientePF add foreign key (IdCli) references tbCliente(IdCli);

alter table tbClientePJ add foreign key (IdCli) references tbCliente(IdCli);

alter table tbCompra add foreign key (NotaFiscal) references tbNotaFiscal(NotaFiscal);
alter table tbCompra add foreign key (IdCli) references tbCliente(IdCli);

alter table tbItemCompra add foreign key (NotaFiscal) references tbCompra(NotaFiscal);
alter table tbItemCompra add foreign key (CodigoBarras) references tbProduto(CodigoBarras);

alter table tbPedido add foreign key (IdFornecedor) references tbFornecedor(IdFornecedor);

alter table tbPedidoProduto add foreign key (NotaFiscalPedido) references tbPedido(NotaFiscalPedido);
alter table tbPedidoProduto add foreign key (CodigoBarras) references tbProduto(CodigoBarras);

alter table tbEndereco add foreign key (IdBairro) references tbBairro(IdBairro);
alter table tbEndereco add foreign key (IdCidade) references tbCidade(IdCidade);
alter table tbEndereco add foreign key (IdUF) references tbUF(IdUF);

 -- drop procedure spInsertCidade; -- Salvação

delimiter $$
create procedure spInsertFornecedor (vCNPJ numeric(13), vNomeFornecedor varchar(100) , vTelefone numeric(11))
begin
	insert into tbFornecedor(CNPJ, NomeFornecedor, telefone) values(vCNPJ, vNomeFornecedor, vTelefone);
end
$$

describe tbCidade;
delimiter $$
create procedure spInsertCidade(vIdCidade int, vCidade varchar(200))
begin
	insert into tbCidade(idCidade, Cidade) values (vIdCidade, vCidade);
end
$$

describe tbUF;
delimiter $$
create procedure spInsertUF(vIdUf int, vEstado varchar(200))
begin
	insert into tbUF(IdUf,UF) values (vIdUf,vEstado);
end
$$

describe tbBairro;
delimiter $$
create procedure spInsertBairro(vIdBairro int, vBairro varchar(200))
begin
	insert into tbBairro(IdBairro,Bairro) values (vIdBairro,vBairro);
end
$$

describe tbProduto;
delimiter $$
create procedure spInsertProduto(vCodigoBarras decimal(14,0), vNome varchar(200), vValor decimal(5,2), vQtd int)
begin
	insert into tbProduto(CodigoBarras,NomeProd,Valor,Qtd) values (vCodigoBarras,vNome,vValor,vQtd);
end
$$


drop procedure spInsertEndereco;
describe tbEndereco;

delimiter $$
CREATE PROCEDURE spInsertEndereco(vCep DECIMAL(8,0),vLogradouro VARCHAR(200),vBairro VARCHAR(200), vCidade VARCHAR(200), vEstado VARCHAR(200))
BEGIN

	DECLARE dBairro INT;
	DECLARE dCidade INT;
	DECLARE dEstado INT;
    
    -- BAIRRO
    IF NOT EXISTS (SELECT idBairro FROM tbBairro WHERE bairro = vBairro) THEN 
		INSERT INTO tbBairro(bairro)
        VALUES(vBairro);
    END IF;
    
    SET dBairro := (SELECT idBairro FROM tbBairro WHERE bairro = vBairro);
    
    -- CIDADE
    IF NOT EXISTS (SELECT idCidade FROM tbCidade WHERE cidade = vCidade) THEN 
		INSERT INTO tbCidade(cidade)
        VALUES(vCidade);
    END IF;
    
    SET dCidade := (SELECT idCidade FROM tbCidade WHERE cidade = vCidade);
        
    -- UF
    IF NOT EXISTS (SELECT idUF FROM tbUF WHERE UF = vEstado) THEN 
		INSERT INTO tbUF(UF)
        VALUES(vEstado);
    END IF;
    
    SET dEstado := (SELECT idUF FROM tbUF WHERE UF = vEstado);
    
    insert into tbEndereco
    values(vCep, vLogradouro, dBairro, dCidade, dEstado);
    
END
$$

call spInsertFornecedor(1245678937123, "Revenda Chico Loco", 11934567897);
call spInsertFornecedor(1345678937123, "José Faz Tudo S/A", 11934567898);
call spInsertFornecedor(1445678937123, "Vadalto Entregas", 11934567899);
call spInsertFornecedor(1545678937123, "Astrogildo das Estrelas", 11934567800);
call spInsertFornecedor(1645678937123, "Amoroso e Doce", 11934567801);
call spInsertFornecedor(1745678937123, "Marcelo Dedal", 11934567802);
call spInsertFornecedor(1845678937123, "Franciscano Cachaça", 11934567803);
call spInsertFornecedor(1945678937123, "Joãozinho Chupeta", 11934567804);

select * from tbFornecedor;

call spInsertCidade(1, "Rio de Janeiro");
call spInsertCidade(2, "São Carlos");
call spInsertCidade(3, "Campinas");
call spInsertCidade(4, "Franco da Rocha");
call spInsertCidade(5, "Osasco");
call spInsertCidade(6, "Pirituba");
call spInsertCidade(7, "Lapa");
call spInsertCidade(8, "Ponta Grossa");
call spInsertCidade(9, "São Paulo");
call spInsertCidade(10, "Barra Mansa");



select * from tbCidade;

call spInsertUF(1, "SP");
call spInsertUF(2, "RJ");
call spInsertUF(3, "RS");

SELECT * FROM tbUF;

call spInsertBairro(1, "Aclimação");
call spInsertBairro(2, "Capão Redondo");
call spInsertBairro(4, "Liberdade");
call spInsertBairro(5, "Lapa");
call spInsertBairro(6, "Penha");
call spInsertBairro(7, "Consolação");

select * from tbBairro;

call spInsertProduto(12345678910111,'Rei de Papel Mache',54.61,120);
call spInsertProduto(12345678910112,'Bolinha de Sabão',100.45,120);
call spInsertProduto(12345678910113,'Barro Bate Bate',44.00,120);
call spInsertProduto(12345678910114,'Bola Furada',10.00,120);
call spInsertProduto(12345678910115,'Maçã Laranja',99.44,120);
call spInsertProduto(12345678910116,'Boneco do Hitler',124.00,200);
call spInsertProduto(12345678910117,'Farinha de Surui',50.00,200);
call spInsertProduto(12345678910118,'Zelador de Cemitério',24.50,100);

select * from tbProduto;

call spInsertEndereco(12345050, "Rua da Federal", "Lapa", "São Paulo", "SP");
call spInsertEndereco(12345051, "Av Brasil", "Lapa", "Campinas", "SP");
call spInsertEndereco(12345052, "Rua Liberdade", "Consolação", "São Paulo", "SP");
call spInsertEndereco(12345053, "Ab Paulista", "Penha", "Rio de Janeiro", "RJ");
call spInsertEndereco(12345054, "Rua Ximbú", "Penha", "Rio de Janeiro", "RJ");
call spInsertEndereco(12345055, "Rua Piu X1", "Penha", "Campinas", "SP");
call spInsertEndereco(12345056, "Rua chocolate", "Aclimação", "Barra Mansa", "RJ");
call spInsertEndereco(12345057, "Rua Pão na Chapa", "Barra Funda", "Ponta Grossa", "RS");
call spInsertEndereco(12345050, "Rua da Federal", "Lapa", "São Paulo", "SP");

drop procedure spInsertEndereco;

SELECT * FROM tbEndereco;
SELECT * FROM tbCidade;
SELECT * FROM tbUF;
SELECT * FROM tbBairro;

call sp_insertClientPF ("Paganada", 139, NULL, 12345051, 12345678912345, 12345678901);
drop procedure sp_insertClientPF;
select * from tbCliente;
select * from tbclientepj;

truncate tbcliente;
truncate tbclientepj;

DELIMITER $$
CREATE PROCEDURE sp_insertClientPF (vnome_cli VARCHAR(200), vnum_end NUMERIC(6), vcomp_end VARCHAR(50), vcep_cli NUMERIC(8),
									vCNPJ NUMERIC(14), vIE NUMERIC(11))
BEGIN
	DECLARE vId_cli INT;
    
	INSERT INTO tbCliente(NomeCli, NumEnd, CompEnd, CepCli)
    VALUES(vnome_cli, vnum_end, vcomp_end, vcep_cli);
    
    set vId_cli := (select idcli from tbcliente order by idcli DESC LIMIT 1);
    
    INSERT INTO tbclientePJ(CNPJ, IE, idCli)
    VALUES(vCNPJ, vIE, vId_cli);
END
$$