--si la base de datos existe la borro------------------------------------------------------
use master
go

if exists(Select * FROM SysDataBases WHERE name='Banco')
BEGIN
	DROP DATABASE Banco
END
go


--creo la base de datos---------------------------------------------------------------------
CREATE DATABASE Banco
ON(
	NAME=Banco,
	FILENAME='C:\Banco.mdf'
)
go


CREATE LOGIN [IIS APPPOOL\DefaultAppPool] FROM WINDOWS 
go

USE Banco
go

 
CREATE USER [IIS APPPOOL\DefaultAppPool] FOR LOGIN [IIS APPPOOL\DefaultAppPool]
go


-- agregar permiso 
GRANT EXECUTE TO [IIS APPPOOL\DefaultAppPool]
go

--creo las tablas --------------------------------------------------------------------------
Create Table Cliente
(
	CICli int Not Null Primary Key,
	NomCli varchar(30) Not Null,
	DirCli varchar(30),
	Activo bit not null Default(1) -- 1 esta activo // 0 tiene baja logica
)
go

Create Table Cuenta
(
	NumCta int Not Null Primary Key Identity(1,1),
	CICli int Not Null Foreign Key References Cliente(CICli),
	SaldoCta money Not Null Default 0
)
go

Create Table CuentaCorriente
(
	NumCta int Not Null Primary Key Foreign Key References Cuenta(NumCta),
	MinimoCta money Not Null Default 0
)
go

Create Table CuentaCAhorro
(
	NumCta int Not Null Primary Key Foreign Key References Cuenta(NumCta),
	MovsCta int Not Null Default 0,  -- cantida de movimientos gratis
	CostoMovCta money Not Null Default 25
)
go

Create Table Movimientos
(
	IdMov int Not Null Primary Key Identity(1,1),
	FechaMov datetime Not Null Default GetDate(),
	MontoMov money Not Null,
	TipoMov varchar(1) Not Null,	--R es un retiro y D es un Deposito
	NumCta int Not Null Foreign Key References Cuenta(NumCta)	
)
go


---Doy de alta Datos de Prueba--------------------------------------------------------------
Insert Cliente (CICli, NomCli, DirCli) Values (1,'Primer Cliente','Primer Direccion')
Insert Cliente (CICli, NomCli, DirCli) Values (2,'Segundo Cliente','Segunda Direccion')
Insert Cliente (CICli, NomCli, DirCli) Values (3,'Tercer Cliente','Tercera Direccion')
go

Insert Cuenta(CICli,SaldoCta) Values (1,1000)
Insert Cuenta(CICli,SaldoCta) Values (2,2000)
Insert Cuenta(CICli,SaldoCta) Values (3,3000)
go

Insert CuentaCorriente(NumCta) Values (1)
insert CuentaCorriente(NumCta,MinimoCta) Values (2,500)
go

Insert CuentaCAhorro(NumCta,MovsCta,CostoMovCta) Values (3,5,100)
go


--SP basicos para manejo del ejemplo------------------------------------------------------
Create Procedure ClienteAlta @CICLI int, @NomCli varchar(30), @DirCli varchar(30) As
Begin
       -- si ya existia y estaba INACTIVO - lo recupero
		if (Exists(Select * From Cliente Where CICli = @CICli AND Activo = 0))
			Begin
				--recordar actualizar datos no solo activar
				update Cliente
				Set DirCli = @DirCli, Activo = 1
				where CICli = @CICLI
				
				return 1 --devolucion clasica, para el usuario final es lo mismo
			end
		
		-- si ya existe y esta activo -- no puedo darlo de alta (validacion de siempre)
		if(Exists(select * From Cliente where CICli = @CICLI AND Activo = 1))
		   return -1
		   
        --No existe la PK - lo puedo agregar
		Insert Cliente (CICli, NomCli, DirCli) values (@CICLI, @NomCli, @DirCli)
		
End
go


Create Procedure ClienteBaja @CICli int As
Begin
		if (Not Exists(Select * From Cliente Where CICli = @CICli))
			Begin
				return -1
			end

		if (Exists(Select * From Movimientos Inner join Cuenta
		       on Movimientos.NumCta = Cuenta.NumCta
		       where CICli = @CICli))
			Begin
			   --baja logica -- se usa update para modificar atributo de activo
			   update Cliente set Activo = 0 where CICli =@CICli
			   return 1
			end
		 Else 
		    Begin
		    --baja fisica --no hay dependencias
		       Begin Transaction
		       Delete From CuentaCAhorro where NumCta in (select NumCta
		                                                  From Cuenta
		                                                  where CICli = @CICli)
	   IF(@@ERROR <> 0)
	   Begin
	       ROLLBACK
	       return -2
	   end
	   
	   Delete From CuentaCorriente where NumCta in(select NumCta
	                                               From Cuenta
	                                               where CICli = @CICli)
	                                               
	   IF(@@ERROR <> 0)
	   Begin
	         Rollback 
	         return -2
	   End
  
       Delete From Cuenta where CICli = @CICli
       if(@@ERROR <>0)
       Begin
          Rollback
          return -2
       end                                   
		                                                
	   Delete From Cliente Where CICli = @CICli
	   if(@@ERROR <> 0)
	   Begin
	       Rollback
	       return -3
	   End
	
	   Commit 
  	   return 1
     End-- fin begin del else
End -- fin begin del SP
go

Create Procedure ClienteModificar @CICli int, @NomCli varchar(30), @DirCli varchar(30) As
Begin
		if (Not Exists(Select * From Cliente Where CICli = @CICli))
			Begin
				return -1
			end
		Else
			Begin
				Update Cliente Set NomCli=@NomCli, DirCli=@DirCli Where CICli = @CICli
				If (@@ERROR = 0)
					return 1
				Else
					return -2
			End
End
go


Create Procedure ClienteListado As 
Begin
	Select * From Cliente
End
go


Create Procedure ClienteBuscar @CICli  int As
Begin
	Select * From Cliente where CICli  = @CICli 
End
go


Create Procedure CuentaCorrienteAlta @CICli int, @MinimoCta money As
Begin
		Begin Transaction
	
		Insert Cuenta (CICli ) Values (@CICli )
		if (@@ERROR <> 0)
		Begin
			RollBack Transaction
			return -1
		End

		Insert CuentaCorriente (NumCta, MinimoCta) Values(IDENT_CURRENT('Cuenta'), @MinimoCta)
		if (@@ERROR<>0)
		Begin
			RollBack Transaction
			return -2
		End

		Commit Transaction
		return 1
End
go


Create Procedure CuentaCorrienteBaja @NumCta int As
Begin
		if (Exists(Select * From Movimientos Where NumCta = @NumCta))
				return -1

		Begin Transaction

		Delete From CuentaCorriente Where NumCta = @NumCta
		if (@@ERROR <> 0)
		Begin
			RollBack Transaction
			return -2
		End

		Delete From Cuenta Where NumCta = @NumCta
		if (@@ERROR <> 0)
		Begin
			RollBack Transaction
			return -3
		End

		Commit Transaction
		return 1

End
go


Create Procedure CuentaCorrienteListado As
Begin
	Select * From Cuenta Cta Inner Join CuentaCorriente CC on Cta.NumCta = CC.NumCta 
End
go


Create Procedure CuentaCorrienteBuscar @NumCta int As
Begin
	Select * 
	From Cuenta Cta Inner Join CuentaCorriente CC on Cta.NumCta = CC.NumCta 
	Where cc.NumCta = @NumCta
End
go


Create Procedure CuentaCAhorroAlta @CICli  int, @MovsCta int, @CostoMovCta money As
Begin
		Begin Transaction
	
		Insert Cuenta (CICli ) Values (@CICli )
		if (@@ERROR <> 0)
		Begin
			RollBack Transaction
			return -1
		End

		Insert CuentaCAhorro(NumCta, MovsCta, CostoMovCta) Values(IDENT_CURRENT('Cuenta'), @MovsCta, @CostoMovCta)
		if (@@ERROR<>0)
		Begin
			RollBack Transaction
			return -2
		End

		Commit Transaction
		return 1
End
go

Create Procedure CuentaCAhorroBaja @NumCta int As
Begin
		if (Exists(Select * From Movimientos Where NumCta = @NumCta))
				return -1

		Begin Transaction

		Delete From CuentaCAhorro Where NumCta = @NumCta
		if (@@ERROR <> 0)
		Begin
			RollBack Transaction
			return -2
		End

		Delete From Cuenta Where NumCta = @NumCta
		if (@@ERROR <> 0)
		Begin
			RollBack Transaction
			return -3
		End

		Commit Transaction
		return 1

End
go


Create Procedure CuentaCAhorroListado As
Begin
	Select * From Cuenta Cta Inner Join CuentaCAhorro CCA on Cta.NumCta = CCA.NumCta 
End
go


Create Procedure CuentaCAhorroBuscar @NumCta int As
Begin
	Select * 
	From Cuenta Cta Inner Join CuentaCAhorro CC on Cta.NumCta = CC.NumCta 
	Where cc.NumCta = @NumCta
End
go


Create Procedure MovimientosAlta @NumCta int, @MontoMov money, @TipoMov varchar(1), @SaldoCta money As
Begin
		--Verifico existencia de datos
		if (Not Exists(Select * From Cuenta where NumCta = @NumCta))
			return -1
		
		--Doy de alta el movimiento y actualizo saldos
		Begin Transaction
		
		Insert Movimientos (MontoMov, TipoMov, NumCta) Values (@MontoMov, @TipoMov, @NumCta)
		if (@@ERROR <> 0)
		Begin
			RollBack Transaction
			return -2
		End																									

		Update Cuenta Set SaldoCta = @SaldoCta Where NumCta = @NumCta		
		if (@@ERROR <> 0)
		Begin
			RollBack Transaction
			return -3
		End	
		
		Commit Transaction
		return 1
		
End
go
