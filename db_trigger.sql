drop database db_Escola;
create database db_Escola;
use db_Escola;

create table tb_Cliente(
ClienteID int primary key auto_increment,
CliNome varchar(150) not null,
CliEmail varchar(150) not null
);

Delimiter $$
create procedure spInsertCliente(vCliNome varchar(150), vCliEmail varchar(150))
begin 
	insert into tb_Cliente values (default, vCliNome, vCliEmail);
end
$$
Delimiter ;
call spInsertCliente("Carlos", "cc@escola.com");
call spInsertCliente("Davizinho", "zinho@escola.com");
call spInsertCliente("Lindinha", "lindi@escola.com");

create table tb_ClienteHistorico LIKE tb_Cliente;

alter table tb_ClienteHistorico modify ClienteID int not null;

alter table tb_ClienteHistorico DROP PRIMARY KEY;

alter table tb_ClienteHistorico add Momento datetime;
alter table tb_ClienteHistorico add Situacao char(100);

ALTER TABLE tb_ClienteHistorico
ADD CONSTRAINT pk_id_ClienteHistorico PRIMARY KEY(ClienteID, Momento, Situacao);

describe tb_ClienteHistorico

Delimiter //
Create trigger TRG_ClienteHistoricoInsert after insert on tb_Cliente
for each row
begin
	Insert into tb_ClienteHistorico
    set ClienteID = New.ClienteID,
	CliNome = New.CliNome,
	CliEmail = New.CliEmail,
	Momento = current_timestamp(),
	Situacao = "Novo";
end;
//
Delimiter ;

call spInsertCliente("Tontinho", "tonti@escola.com");
-- /*
select * from tb_Cliente;
select * from tb_ClienteHistorico;
-- */
Delimiter //
Create trigger TRG_ClienteHistoricoUpdate after update on tb_Cliente
for each row
begin
	Insert into tb_ClienteHistorico
    set ClienteID = Old.ClienteID,
	CliNome = Old.CliNome,
	CliEmail = Old.CliEmail,
	Momento = current_timestamp(),
	Situacao = "Antes";
    Insert into tb_ClienteHistorico
    set ClienteID = New.ClienteID,
	CliNome = New.CliNome,
	CliEmail = New.CliEmail,
	Momento = current_timestamp(),
	Situacao = "Depois";
end;
//
Delimiter ;

Delimiter //
create procedure spUpdateCliente(vClienteID int, vCliNome varchar(150), vCliEmail varchar(150))
begin
update tb_Cliente set CliNome = vCliNome, CliEmail = vCliEmail where ClienteID = vClienteID;
end
//
Delimiter ;

call spUpdateCliente(4, "Muito Tontinho", "tonti@escola.com");
call spUpdateCliente(3, "Lindinha de Morrer", "lindi@escola.com");

