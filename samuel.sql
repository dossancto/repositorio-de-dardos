drop database dbdistribuidora;
create database dbdistribuidora;
use dbdistribuidora;

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
	CodigoCompra int auto_increment primary key,
    DataCompra date default(current_timestamp()),
    ValorTotal decimal(7,2) not null,
    QtdTotal int not null,
    NotaFiscal int,
    IdCli int,
    IdFornecedor int not null
);

create table tbNotaFiscal(
	NotaFiscal int primary key,
    TotalNota decimal(7,2) not null,
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
alter table tbCompra add foreign key (IdFornecedor) references tbFornecedor(IdFornecedor);

alter table tbItemCompra add foreign key (NotaFiscal) references tbCompra(NotaFiscal);
alter table tbItemCompra add foreign key (CodigoBarras) references tbProduto(CodigoBarras);

alter table tbPedido add foreign key (IdFornecedor) references tbFornecedor(IdFornecedor);

alter table tbPedidoProduto add foreign key (NotaFiscalPedido) references tbPedido(NotaFiscalPedido);
alter table tbPedidoProduto add foreign key (CodigoBarras) references tbProduto(CodigoBarras);

ALTER TABLE tbEndereco ADD FOREIGN KEY (IdBairro) REFERENCES tbBairro(IdBairro);
ALTER TABLE tbEndereco ADD FOREIGN KEY (IdCidade) REFERENCES tbCidade(IdCidade);
ALTER TABLE tbEndereco ADD FOREIGN KEY (IdUF) REFERENCES tbUF(IdUF);

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
    DECLARE dLogradouro INT;
    
    if (not (select cep from tbendereco where cep = vCep)) then
		
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
    end if;
	
    
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

-- ======================================================

use dbdistribuidora;
drop procedure spInsertCliente;
delimiter $$
create procedure spInsertCliente (vNome varchar(50), vNumEnd decimal(6,0), vCompEnd varchar(50), vCEP decimal(8,0), vCPF decimal(11,0), vRG decimal(8,0), vRgDig char(1), vNasc date,
vLogradouro varchar(200), vBairro varchar(200), vCidade varchar(200), vUF char(2))
begin
    if not exists (select CEP from tbEndereco where CEP = vCEP) then
		if not exists (select IdBairro from tbBairro where Bairro = vBairro) then
			insert into tbBairro(Bairro) values (vBairro);
		end if;

		if not exists (select IdUf from tbUF where UF = vUF) then
			insert into tbUF(UF) values (vUF);
		end if;

		if not exists (select IdCidade from tbCidade where Cidade = vCidade) then
			insert into tbCidade(Cidade) values (vCidade);
		end if;
		
        
		set @IdBairro = (select IdBairro from tbBairro where Bairro = vBairro);
		set @IdUf = (select IdUF from tbUF where UF = vUf);
		set @IdCidade = (select IdCidade from tbCidade where Cidade = vCidade);

		insert into tbEndereco(CEP, Logradouro, IdBairro, IdCidade, IdUF) values
		(vCEP, vLogradouro, @IdBairro, @IdCidade, @IdUF); 
	end if;
    
   	if not exists (select CPF from tbClientePF where CPF = vCPF) then
		insert into tbCliente(Nomecli, Cepcli, NumEnd, CompEnd) values (vNome, vCEP, vNumEnd, vCompEnd);
        set @IdCli = (SELECT idcli FROM tbcliente ORDER BY idcli DESC LIMIT 1);
		insert into tbClientePF(IdCli, CPF, RG, Rg_Dig, Nasc) values (@idCli, vCPF, vRG, vRgDig, vNasc);
	end if;
end $$

call spInsertCliente('Pimpão', 325, null, 12345051, 12345678911, 12345678, 0, '2000-12-10', 'Av. Brasil', 'Lapa', 'Campinas', 'SP');
call spInsertCliente('Disney Chaplin', 89, 'Ap. 12', 12345053, 12345678912, 12345679, 0, '2001-11-21', 'Av. Paulista', 'Penha', 'Rio de Janeiro', 'RJ');
call spInsertCliente('Marciano', 744, null, 12345054, 12345678913, 12345680, 0, '2001-06-01', 'Rua Ximbú', 'Penha', 'Rio de Janeiro', 'RJ');
call spInsertCliente('Lança Perfume', 128, null, 12345059, 12345678914, 12345681, 'X', '2004-04-05', 'Rua Veia', 'Jardim Santa Isabel', 'Cuiabá', 'MT');
call spInsertCliente('Remédio Amargo', 2485, null, 12345058, 12345678915, 12345682, 0, '2002-07-15', 'Av. Nova', 'Jardim Santa Isabel', 'Cuiabá', 'MT');

drop procedure spInsertClientePJ;
delimiter $$
create procedure spInsertClientePJ (vNome varchar(50), vCNPJ numeric(14), vIE numeric(11), vCEP decimal(8,0), vLogradouro varchar(200),
				vNumEnd decimal(6,0), vCompEnd varchar(50),
				vBairro varchar(200), vCidade varchar(200), vUF char(2))
begin
    if not exists (select CEP from tbEndereco where CEP = vCEP) then
		if not exists (select IdBairro from tbBairro where Bairro = vBairro) then
			insert into tbBairro(Bairro) values (vBairro);
		end if;

		if not exists (select IdUf from tbUF where UF = vUF) then
			insert into tbUF(UF) values (vUF);
		end if;

		if not exists (select IdCidade from tbCidade where Cidade = vCidade) then
			insert into tbCidade(Cidade) values (vCidade);
		end if;
		
        
		set @IdBairro = (select IdBairro from tbBairro where Bairro = vBairro);
		set @IdUf = (select IdUF from tbUF where UF = vUf);
		set @IdCidade = (select IdCidade from tbCidade where Cidade = vCidade);

		insert into tbEndereco(CEP, Logradouro, IdBairro, IdCidade, IdUF) values
		(vCEP, vLogradouro, @IdBairro, @IdCidade, @IdUF); 
	end if;
    
   	if not exists (select CNPJ from tbClientePJ where CNPJ = vCNPJ) then
		insert into tbCliente(Nomecli, Cepcli, NumEnd, CompEnd) values (vNome, vCEP, vNumEnd, vCompEnd);
        set @IdCli = (SELECT idcli FROM tbcliente ORDER BY idcli DESC LIMIT 1);
		insert into tbClientePJ(IdCli, CNPJ, IE) values (@idCli, vCNPJ, vIE);
	end if;
end $$

call spInsertClientePJ('Paganada', 12345678912345, 98765432198, 12345051, 'Av. Brasil', 159, null, 'Lapa', 'Campinas', 'SP');
call spInsertClientePJ('Caloteando', 12345678912346, 98765432199, 12345053, 'Av. Paulista', 69, null, 'Penha', 'Rio de Janeiro', 'RJ');
call spInsertClientePJ('Semgrana', 12345678912347, 98765432100, 12345060, 'Rua dos Amores', 189, null, 'Sei Lá', 'Recife', 'PE');
call spInsertClientePJ('Cemreais', 12345678912348, 98765432101, 12345060, 'Rua dos Amores', 5024, 'Sala 23', 'Sei Lá', 'Recife', 'PE');
call spInsertClientePJ('Durango', 12345678912349, 98765432102, 12345060, 'Rua dos Amores', 1254, null, 'Sei Lá', 'Recife', 'PE');

SELECT * FROM tbEndereco;
SELECT * FROM tbCidade;
SELECT * FROM tbUF;
SELECT * FROM tbBairro;
SELECT * FROM tbclientepj;
SELECT * FROM tbcliente;

drop procedure spInsertCompra
delimiter $$
create procedure spInsertCompra(vNotaFiscal int, vFornecedor varchar(100), vDataCompra date, vCodigoBarras numeric(14), vValorItem decimal(5,2),
vQtd int, vQtdTotal int, vValorTotal decimal(7,2))
begin
	if not exists (select NotaFiscal from tbNotaFiscal where NotaFiscal = vNotaFiscal) then
		insert into tbNotaFiscal(NotaFiscal	, TotalNota, DataEmissao) values (vNotaFiscal, vValorTotal, vDataCompra);
		insert into tbCompra(NotaFiscal, DataCompra, ValorTotal, QtdTotal, idFornecedor) values (vNotaFiscal, vDataCompra, vValorTotal, vQtdTotal,
        (select idFornecedor from tbFornecedor where NomeFornecedor = vFornecedor));
        insert into tbItemCompra(Qtd, ValorItem, NotaFiscal, CodigoBarras) values (vQtd, vValorItem, vNotaFiscal, vCodigoBarras);
        else

		if not exists (select CodigoBarras from tbItemCompra where CodigoBarras = vCodigoBarras) then
		insert into tbItemCompra(Qtd, ValorItem, NotaFiscal, CodigoBarras) values (vQtd, vValorItem, vNotaFiscal, vCodigoBarras);
	else
		select 'Já existe';
	end if;
	end if;
end $$


call spInsertCompra(8459, 'Amoroso e Doce', '2018-05-01', 12345678910111, 22.22, 200, 700, 21944.00);
call spInsertCompra(2482, 'Revenda Chico Loco', '2020-04-22', 12345678910112, 40.50, 180, 180, 7290.00);
call spInsertCompra(21563, 'Marcelo Dedal', '2020-07-12', 12345678910113, 3.00, 300, 300, 900.00);
call spInsertCompra(8459, 'Amoroso e Doce', '2020-12-04', 12345678910114, 35.00, 500, 700, 21944.00);
call spInsertCompra(156354, 'Revenda Chico Loco', '2021-11-23', 12345678910115, 54.00, 350, 350, 18900.00);


select * from tbProduto;
select * from tbNotaFiscal;
select * from tbCompra;
select * from tbItemCompra;
select * from tbFornecedor;

